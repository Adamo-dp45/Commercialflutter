import 'bagage_detail.dart';
import 'ticket_detail.dart';

/// Mes ventes sur un voyage (billets + bagages), telles que renvoyées par
/// `GET /api/voyages/{id}/me/ventes` — ou reconstituées depuis l'instantané embarqué.
class MesVentes {
  const MesVentes({
    required this.tickets,
    required this.bagages,
    this.horsLigne = false,
  });

  final List<TicketDetail> tickets;
  final List<BagageDetail> bagages;

  /// Vrai quand la liste vient de l'instantané et non du serveur.
  ///
  /// La page s'en sert pour désactiver les CORRECTIONS. Sans ce drapeau, les boutons resteraient
  /// offerts et chaque tentative se solderait par « Impossible de joindre le serveur » — un bouton
  /// qui échoue vaut moins qu'un bouton grisé qui dit pourquoi.
  final bool horsLigne;

  static const empty = MesVentes(tickets: [], bagages: []);
}
