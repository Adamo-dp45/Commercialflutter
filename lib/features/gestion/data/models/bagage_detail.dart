import 'package:freezed_annotation/freezed_annotation.dart';

part 'bagage_detail.freezed.dart';
part 'bagage_detail.g.dart';

/// Un bagage enregistré par le commercial, tel que renvoyé (à plat) par
/// `GET /api/voyages/{id}/me/ventes`. `ticketId` est requis pour toute
/// modification (BagageInput exige le billet rattaché) ; les libellés
/// trajet/client alimentent le reçu bagage.
@freezed
abstract class BagageDetail with _$BagageDetail {
  const BagageDetail._();

  const factory BagageDetail({
    required int id,
    String? codebagage,
    String? nature,
    String? type,
    @Default(0) int poids,
    @Default(0) int montant,
    @JsonKey(name: 'montantforce') @Default(false) bool montantForce,
    @Default('ENREGISTRE') String statut,
    int? ticketId,
    String? codeticket,
    String? nomclient,
    String? contactclient,
    String? monteeLibelle,
    String? descenteLibelle,
  }) = _BagageDetail;

  factory BagageDetail.fromJson(Map<String, dynamic> json) =>
      _$BagageDetailFromJson(json);

  bool get estEnregistre => statut == 'ENREGISTRE';
}
