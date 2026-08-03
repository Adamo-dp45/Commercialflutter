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

  Future<int?> tarif({required int monteeId, required int descenteId});

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

  Future<BagageCree> ajouterBagage({
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  });
}
