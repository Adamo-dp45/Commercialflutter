import 'package:freezed_annotation/freezed_annotation.dart';

part 'siege.freezed.dart';
part 'siege.g.dart';

/// Un siège du car, avec son état SUR LE TRONÇON demandé (`/api/sieges`,
/// `SiegeStateProvider`).
///
/// `statut` vaut `LIBRE` / `OCCUPE` pour le tronçon montée→descente. `revendu`
/// (violet) = siège réutilisé sur des tronçons disjoints ; `conflit` = un billet
/// évincé existe sur ce siège (repère non bloquant).
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
  }) = _Siege;

  factory Siege.fromJson(Map<String, dynamic> json) => _$SiegeFromJson(json);

  /// Disponible à la vente sur le tronçon demandé.
  bool get estLibre => statut == 'LIBRE';
}
