import '../../../../core/models/bagage_cree.dart';
import '../../domain/repositories/vente_repository.dart';
import '../datasources/vente_remote_datasource.dart';
import '../models/siege.dart';
import '../models/ticket_vendu.dart';

class VenteRepositoryImpl implements VenteRepository {
  VenteRepositoryImpl(this._remote);

  final VenteRemoteDataSource _remote;

  @override
  Future<List<Siege>> sieges({
    required int carId,
    required int voyageId,
    required int monteeId,
    required int descenteId,
  }) =>
      _remote.sieges(
        carId: carId,
        voyageId: voyageId,
        monteeId: monteeId,
        descenteId: descenteId,
      );

  @override
  Future<int?> tarif({required int monteeId, required int descenteId}) =>
      _remote.tarif(monteeId: monteeId, descenteId: descenteId);

  @override
  Future<TicketVendu> vendreTicket({
    required int voyageId,
    required int siegeId,
    required int monteeGareId,
    required int descenteGareId,
    String? nom,
    String? contact,
    String? remiseType,
    int? remiseValeur,
  }) =>
      _remote.vendreTicket(
        voyageId: voyageId,
        siegeId: siegeId,
        monteeGareId: monteeGareId,
        descenteGareId: descenteGareId,
        nom: nom,
        contact: contact,
        remiseType: remiseType,
        remiseValeur: remiseValeur,
      );

  @override
  Future<BagageCree> ajouterBagage({
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) =>
      _remote.ajouterBagage(
        ticketId: ticketId,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );
}
