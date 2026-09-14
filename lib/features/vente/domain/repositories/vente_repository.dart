import '../../../../core/models/bagage_cree.dart';
import '../../data/models/siege.dart';
import '../../data/models/ticket_vendu.dart';

/// Contrat de la vente à bord.
abstract interface class VenteRepository {
  Future<List<Siege>> sieges({
    required int carId,
    required int voyageId,
    required int monteeId,
    required int descenteId,
  });

  /// `voyageId` sert au repli HORS LIGNE : il désigne l'instantané où lire la grille embarquée.
  Future<int?> tarif({required int monteeId, required int descenteId, int? voyageId});

  Future<TicketVendu> vendreTicket({
    required int voyageId,
    required int siegeId,
    required int monteeGareId,
    required int descenteGareId,
    String? nom,
    String? contact,
    String? remiseType,
    int? remiseValeur,
  });

  /// Rattache un bagage au billet qui vient d'être vendu.
  ///
  /// Le billet est désigné DEUX FOIS, et ce n'est pas une redondance : [ticketId] est ce que
  /// l'API attend, [codeticket] est la seule désignation qui existe encore quand la vente est
  /// elle-même en attente de remontée. Hors ligne, [ticketId] est nul — le billet n'a pas encore
  /// d'identifiant serveur — et c'est le code, déjà imprimé sur le reçu, qui fait le lien.
  Future<BagageCree> ajouterBagage({
    required int voyageId,
    required String codeticket,
    int? ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  });
}
