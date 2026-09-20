import 'package:freezed_annotation/freezed_annotation.dart';

part 'siege.freezed.dart';
part 'siege.g.dart';

/// Un siège du car, avec son état SUR LE TRONÇON demandé (`/api/sieges`,
/// `SiegeStateProvider`).
///
/// `statut` vaut `LIBRE` / `OCCUPE` pour le tronçon montée→descente. `revendu`
/// (violet) = siège réutilisé sur des tronçons disjoints ; `conflit` = un billet
/// évincé existe sur ce siège (repère non bloquant).
///
/// `venduAval` est le troisième repère, et le seul PRÉVENTIF : le siège est libre
/// — la priorité amont n'est pas remise en cause — mais une gare située plus bas
/// sur la ligne l'a déjà vendu, et ce passager monte à l'intérieur du tronçon
/// affiché. Le prendre l'évincerait. Contrairement à `conflit`, qui constate une
/// éviction déjà produite, celui-ci désigne une éviction qui n'a pas encore eu
/// lieu : elle disparaît si le vendeur choisit un autre siège.
@freezed
abstract class Siege with _$Siege {
  const Siege._();

  const factory Siege({
    required int id,
    required int numero,
    @Default(0) int rangee,
    @Default(0) int colonne,
    @Default('GAUCHE') String cote,
    @Default('LIBRE') String statut,
    @Default(false) bool revendu,
    @Default(false) bool conflit,
    String? occupantNom,
    int? occupantTicketId,
    @Default(false) bool venduAval,
    String? avalNom,
    String? avalMontee,
    String? avalDescente,
    @Default(0) int avalNombre,
  }) = _Siege;

  factory Siege.fromJson(Map<String, dynamic> json) => _$SiegeFromJson(json);

  /// Disponible à la vente sur le tronçon demandé.
  bool get estLibre => statut == 'LIBRE';

  /// Le repère d'alerte ne vaut que sur un siège LIBRE : sur un siège occupé, la
  /// vente est de toute façon impossible et l'avertissement n'aurait pas d'objet.
  /// Même arbitrage que `PlanCar` côté web.
  bool get alerteAval => venduAval && estLibre;

  /// « Ferké → Korhogo, M. Koffi (et 2 autres) » — de quoi décider sans quitter le plan.
  String get resumeAval {
    final autres = (avalNombre <= 0 ? 1 : avalNombre) - 1;
    final trajet = '${avalMontee ?? '?'} → ${avalDescente ?? '?'}';
    final nom = avalNom == null || avalNom!.isEmpty ? '' : ', $avalNom';
    final reste = autres > 0 ? ' (et $autres autre${autres > 1 ? 's' : ''})' : '';

    return '$trajet$nom$reste';
  }
}
