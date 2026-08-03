import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_detail.freezed.dart';
part 'ticket_detail.g.dart';

/// Un billet vendu par le commercial, tel que renvoyé (à plat) par
/// `GET /api/voyages/{id}/me/ventes` (CommercialVentesController).
@freezed
abstract class TicketDetail with _$TicketDetail {
  const TicketDetail._();

  const factory TicketDetail({
    required int id,
    String? codeticket,
    @Default(0) int prix,
    @Default(0) int remise,
    String? nomclient,
    String? contactclient,
    @Default('VALIDE') String statut,
    int? siegeNumero,
    int? monteeGareId,
    String? monteeLibelle,
    int? descenteGareId,
    String? descenteLibelle,
    DateTime? dateEmission,
  }) = _TicketDetail;

  factory TicketDetail.fromJson(Map<String, dynamic> json) =>
      _$TicketDetailFromJson(json);

  bool get estValide => statut == 'VALIDE';

  String get clientAffiche =>
      (nomclient?.trim().isNotEmpty ?? false) ? nomclient!.trim() : 'Anonyme';

  String get trajet => '${monteeLibelle ?? '?'} → ${descenteLibelle ?? '?'}';
}
