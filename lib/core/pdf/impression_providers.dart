import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'bagage_recu_pdf.dart';
import 'format_impression.dart';
import 'impression_distante.dart';
import 'recu_pdf.dart';

final impressionDistanteProvider = Provider<ImpressionDistante>(
  (ref) => ImpressionDistante(ref.watch(dioProvider)),
);

final reglageFormatProvider = Provider<ReglageFormatImpression>(
  (ref) => const ReglageFormatImpression(),
);

/// Comment on apprend le format au moment d'imprimer.
///
/// Une fonction, et non la valeur : le format est LU À CHAQUE IMPRESSION, directement dans le
/// stockage. Un état gardé en mémoire aurait une valeur initiale — le thermique — pendant le
/// temps de son chargement, et un billet imprimé dans cet intervalle sortirait au mauvais format
/// sans que rien ne le signale. La lecture coûte une poignée de millisecondes, contre un appel
/// réseau juste derrière.
///
/// C'est aussi le point de surcharge des sentinelles : elles branchent un format sans toucher au
/// coffre du téléphone.
final lectureFormatProvider = Provider<Future<FormatImpression> Function()>(
  (ref) => ref.watch(reglageFormatProvider).lire,
);

/// Le format réglé, pour les ÉCRANS qui l'affichent et le changent.
///
/// L'impression, elle, ne passe pas par là (cf. `lectureFormatProvider`) : cet état sert à cocher
/// la bonne ligne dans la feuille de réglage, pas à décider d'un papier.
final formatImpressionProvider =
    NotifierProvider<FormatImpressionController, FormatImpression>(FormatImpressionController.new);

class FormatImpressionController extends Notifier<FormatImpression> {
  @override
  FormatImpression build() {
    _charger();

    return FormatImpression.thermique80;
  }

  Future<void> _charger() async {
    state = await ref.read(lectureFormatProvider)();
  }

  Future<void> definir(FormatImpression format) async {
    await ref.read(reglageFormatProvider).definir(format);
    state = format;
  }
}

/// Le document à imprimer : celui du SERVEUR, et à défaut celui composé ici.
///
/// Un seul endroit décide, pour que les deux écrans qui impriment — la vente et « mes ventes » —
/// ne puissent pas diverger dans leur façon de choisir. Le détail du raisonnement est dans
/// `ImpressionDistante` ; en deux mots : sans identifiant serveur (vente hors ligne) ou sans
/// réseau, on compose localement ; sur toute autre erreur, on laisse remonter plutôt que
/// d'imprimer ce que le serveur vient de refuser.
final recuImprimableProvider = Provider<RecuImprimable>(
  (ref) => RecuImprimable(
    ref.watch(impressionDistanteProvider),
    format: ref.watch(lectureFormatProvider),
  ),
);

class RecuImprimable {
  const RecuImprimable(this._distante, {this.format});

  final ImpressionDistante _distante;

  /// Le format réglé sur l'appareil. Nul en sentinelle, où le thermique suffit.
  final Future<FormatImpression> Function()? format;

  /// Le billet. `id` est nul pour une vente hors ligne encore en file de synchronisation.
  ///
  /// !! LE FORMAT SE DÉCIDE ICI, et non chez les appelants. Les trois écrans qui impriment un
  ///    billet n'ont pas à le savoir : un oubli dans l'un d'eux sortirait un papier étroit sur un
  ///    terminal large sans qu'aucun test ne puisse le voir, et personne ne s'en apercevrait avant
  ///    le comptoir.
  Future<Uint8List> billet({required int? id, required RecuData repli}) async {
    final regle = await _regle();

    if (id != null) {
      final distant = await _distante.billet(id, large: regle.estLarge);
      if (distant != null) {
        return distant;
      }
    }

    /*
      LE REPLI SUIT LE MÊME RÉGLAGE (21/10/2026). Il sortait toujours en 80 mm, et le vendeur réglé
      sur un terminal large retrouvait donc le billet minuscule du 20/10/2026 dès qu'il perdait le
      réseau — c'est-à-dire en route, là où il vend le plus.
    */
    return buildRecuPdf(repli, format: regle);
  }

  /// Le reçu de bagage. `id` est nul tant que le bagage n'est pas remonté.
  ///
  /// Même support que le billet : un agent qui règle « terminal large » et récupère un billet
  /// lisible accompagné d'un reçu minuscule n'y verrait qu'un défaut, pas une subtilité.
  Future<Uint8List> bagage({required int? id, required BagageRecuData repli}) async {
    final regle = await _regle();

    if (id != null) {
      final distant = await _distante.bagage(id, large: regle.estLarge);
      if (distant != null) {
        return distant;
      }
    }

    return buildBagageRecuPdf(repli, format: regle);
  }

  /// Le format réglé, ou le thermique quand rien ne le fournit (sentinelles).
  Future<FormatImpression> _regle() async =>
      format?.call() ?? Future.value(FormatImpression.thermique80);
}
