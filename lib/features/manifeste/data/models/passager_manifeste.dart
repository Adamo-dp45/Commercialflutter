import 'package:freezed_annotation/freezed_annotation.dart';

part 'passager_manifeste.freezed.dart';
part 'passager_manifeste.g.dart';

/// Un passager du voyage (billet VALIDE, tout canal), tel que renvoyé par
/// `GET /api/voyages/{id}/me/manifeste` — pour le contrôle à bord.
@freezed
abstract class PassagerManifeste with _$PassagerManifeste {
  const PassagerManifeste._();

  const factory PassagerManifeste({
    int? ticketId,
    String? codeticket,
    int? siegeNumero,
    String? nomclient,
    String? contactclient,
    String? monteeLibelle,
    String? descenteLibelle,
    @Default(false) bool aBord,
  }) = _PassagerManifeste;

  factory PassagerManifeste.fromJson(Map<String, dynamic> json) =>
      _$PassagerManifesteFromJson(json);

  String get clientAffiche =>
      (nomclient?.trim().isNotEmpty ?? false) ? nomclient!.trim() : 'Anonyme';

  String get trajet => '${monteeLibelle ?? '?'} → ${descenteLibelle ?? '?'}';
}
