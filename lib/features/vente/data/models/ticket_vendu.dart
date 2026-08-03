import 'package:freezed_annotation/freezed_annotation.dart';

part 'ticket_vendu.freezed.dart';
part 'ticket_vendu.g.dart';

/// Résultat d'une vente (`POST /api/tickets`). On ne retient que l'essentiel du
/// billet créé (identifiant, code, prix net) ; le reste du reçu est construit à
/// partir du contexte de vente déjà connu (trajet, siège, client).
@freezed
abstract class TicketVendu with _$TicketVendu {
  const factory TicketVendu({
    int? id,
    String? codeticket,
    int? prix,
    @Default(0) int remise,
  }) = _TicketVendu;

  factory TicketVendu.fromJson(Map<String, dynamic> json) =>
      _$TicketVenduFromJson(json);
}
