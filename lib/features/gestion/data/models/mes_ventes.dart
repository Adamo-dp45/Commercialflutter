import 'bagage_detail.dart';
import 'ticket_detail.dart';

/// Mes ventes sur un voyage (billets + bagages), telles que renvoyées par
/// `GET /api/voyages/{id}/me/ventes`.
class MesVentes {
  const MesVentes({required this.tickets, required this.bagages});

  final List<TicketDetail> tickets;
  final List<BagageDetail> bagages;

  static const empty = MesVentes(tickets: [], bagages: []);
}
