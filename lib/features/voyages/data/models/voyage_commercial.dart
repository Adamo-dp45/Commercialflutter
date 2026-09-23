import 'package:freezed_annotation/freezed_annotation.dart';

import 'arret.dart';

part 'voyage_commercial.freezed.dart';
part 'voyage_commercial.g.dart';

/// Voyage ACTIF dont je suis le commercial, tel que renvoyé par
/// `GET /api/voyages/me/commercial` (cf. `CommercialEspaceController`).
///
/// Porte la position courante du car, les arrêts de la ligne, et MA performance
/// propre (billets/bagages vendus par moi sur ce voyage).
@freezed
abstract class VoyageCommercial with _$VoyageCommercial {
  const VoyageCommercial._();

  const factory VoyageCommercial({
    required int id,
    String? codevoyage,
    /// Numéro de départ DU JOUR (« DEPART 4 » sur le reçu) : le repère que le
    /// passager entend au quai. Attribué par le serveur, jamais calculé ici.
    int? numerodepart,
    String? provenance,
    String? destination,
    DateTime? datedepartprevue,
    @Default(false) bool demarre,
    @Default(0) int placestotal,
    @Default(0) int placesoccupees,
    int? garecouranteId,
    String? garecouranteLibelle,
    // Car affecté : nécessaire au plan de sièges lors de la vente (/api/sieges?car=…).
    int? carId,
    String? carMatricule,
    @Default(false) bool peutRepartir,
    @Default(<Arret>[]) List<Arret> arrets,
    // Ma performance PROPRE sur ce voyage (canal commercial).
    @Default(0) int maRecette,
    @Default(0) int mesTickets,
    @Default(0) int mesBagages,
  }) = _VoyageCommercial;

  factory VoyageCommercial.fromJson(Map<String, dynamic> json) =>
      _$VoyageCommercialFromJson(json);

  String get trajet => '${provenance ?? '?'} → ${destination ?? '?'}';

  /// Comment on NOMME ce départ à l'écran : « Départ 2 · LI-ABI-KOR-0001-V3 ».
  ///
  /// Le numéro d'abord, parce que c'est celui que le vendeur entend et annonce ; le code ensuite,
  /// pour retrouver le voyage côté exploitation. Un cache d'avant cette version n'a pas le numéro —
  /// on retombe alors sur le code seul plutôt que d'afficher « Départ null ».
  String get libelleDepart {
    final code = codevoyage ?? 'Voyage #$id';
    return numerodepart == null ? code : 'Départ $numerodepart · $code';
  }

  int get placesLibres =>
      (placestotal - placesoccupees).clamp(0, placestotal);

  double? get tauxRemplissage =>
      placestotal > 0 ? placesoccupees / placestotal : null;

  /// Arrêts triés par ordre de passage.
  List<Arret> get arretsOrdonnes {
    final copy = [...arrets]..sort((a, b) => a.ordre.compareTo(b.ordre));
    return copy;
  }

  /// L'arrêt où se trouve actuellement le car (position courante), s'il est connu.
  Arret? get arretCourant {
    for (final a in arrets) {
      if (a.id == garecouranteId) return a;
    }
    return null;
  }

  /// Prochain arrêt en aval de la position courante (le suivant à desservir),
  /// ou `null` si le car est déjà au terminus (ou position inconnue).
  Arret? get prochainArret {
    final courant = arretCourant;
    if (courant == null) return null;
    Arret? next;
    for (final a in arretsOrdonnes) {
      if (a.ordre > courant.ordre) {
        next = a;
        break;
      }
    }
    return next;
  }

  /// Le commercial peut-il déclarer que le car a atteint l'arrêt suivant ?
  /// (voyage parti, position connue, un arrêt en aval existe).
  bool get peutAvancer => demarre && prochainArret != null;

  /// Le commercial peut-il vendre depuis ici ? Il faut un car (plan de sièges),
  /// une position connue (= gare de montée forcée côté serveur) et au moins un
  /// arrêt en aval (destination possible).
  bool get peutVendre =>
      carId != null && garecouranteId != null && prochainArret != null;

  /// Arrêts situés STRICTEMENT après la position courante : destinations vendables.
  List<Arret> get descentesPossibles {
    final courant = arretCourant;
    if (courant == null) return const [];
    return arretsOrdonnes.where((a) => a.ordre > courant.ordre).toList();
  }
}
