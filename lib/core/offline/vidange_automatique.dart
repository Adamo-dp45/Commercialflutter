import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/voyages/presentation/providers/voyage_providers.dart';
import 'offline_providers.dart';

/// Fait repartir la file toute seule, sans que le vendeur ait à le demander.
///
/// Ce qui manquait : `Connectivite` annonce dans sa propre docstring qu'elle sert à « savoir QUAND
/// retenter une vidange »… et personne ne l'écoutait. La file ne partait qu'à trois moments — juste
/// après avoir mis une opération en file, à l'ouverture d'un voyage, ou sur le bouton de
/// synchronisation. Un vendeur qui retrouve du réseau en restant sur son écran de vente ne voyait
/// rien remonter.
///
/// QUATRE DÉCLENCHEURS, parce qu'aucun ne suffit seul :
///
///  1. l'**ouverture de la base locale** — au démarrage, la première tentative part avant que
///     SQLite soit prêt ; sans ce déclencheur elle échoue en silence et la file attend deux minutes ;
///  2. le **changement de connectivité** — le tunnel, la zone blanche, le mode avion. Il ne couvre
///     QUE les cas où l'interface réseau disparaît puis revient ;
///  3. le **retour au premier plan** — le vendeur rouvre son téléphone, moment naturel pour réessayer ;
///  4. une **retentative périodique tant que la file n'est pas vide** — et c'est celui qui couvre le
///     cas le plus fréquent en brousse : l'antenne reste « connectée » sans débit, puis le débit
///     revient. Aucun changement d'interface, donc aucun événement (2). Sans ce quatrième
///     déclencheur, la file attendrait le prochain geste du vendeur.
///
/// Le sondage est borné à ce qui sert : file vide, la tentative se solde par une lecture SQLite et
/// s'arrête là — aucun appel réseau. Et un réseau retrouvé ne prouve pas le serveur joignable : un
/// échec est sans conséquence, la file reste intacte.
class VidangeAutomatique extends Notifier<void> {
  /// Assez court pour que le vendeur ne l'attende pas, assez long pour ne pas peser sur la batterie
  /// d'un téléphone qui roule toute la journée.
  static const _intervalle = Duration(minutes: 2);

  bool _enCours = false;

  @override
  void build() {
    // Surveillé, pas seulement lu : tant que la base locale n'est pas ouverte il n'y a rien à
    // vider, et c'est son ouverture qui donne le premier moment utile.
    final synchronisateur = ref.watch(synchronisateurProvider);

    ref.listen(reseauDisponibleProvider, (_, apres) {
      if (apres.asData?.value == true) _vider();
    });

    final cycle = AppLifecycleListener(onResume: _vider);
    final minuterie = Timer.periodic(_intervalle, (_) => _vider());

    ref.onDispose(cycle.dispose);
    ref.onDispose(minuterie.cancel);

    if (synchronisateur != null) scheduleMicrotask(_vider);
  }

  /// Une seule vidange à la fois : les déclencheurs peuvent tomber ensemble (réseau qui revient
  /// pendant que l'application repasse au premier plan), et rejouer le même lot deux fois en
  /// parallèle n'apporterait rien.
  Future<void> _vider() async {
    if (_enCours) return;

    final synchronisateur = ref.read(synchronisateurProvider);
    if (synchronisateur == null) return;

    _enCours = true;
    try {
      final remontees = await synchronisateur.viderTout();
      if (remontees == 0) return;

      ref.invalidate(operationsEnAttenteProvider);
      // Le serveur redevient la référence : ses chiffres remplacent nos corrections locales.
      ref.invalidate(mesVoyagesProvider);
    } finally {
      _enCours = false;
    }
  }
}

final vidangeAutomatiqueProvider = NotifierProvider<VidangeAutomatique, void>(
  VidangeAutomatique.new,
);
