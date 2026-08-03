import '../../../../core/models/bagage_cree.dart';
import '../../domain/repositories/gestion_repository.dart';
import '../datasources/gestion_remote_datasource.dart';
import '../models/mes_ventes.dart';

class GestionRepositoryImpl implements GestionRepository {
  GestionRepositoryImpl(this._remote);

  final GestionRemoteDataSource _remote;

  @override
  Future<MesVentes> ventesDuVoyage(int voyageId) =>
      _remote.ventesDuVoyage(voyageId);

  @override
  Future<void> modifierClientTicket({
    required int ticketId,
    String? nom,
    String? contact,
  }) =>
      _remote.modifierClientTicket(
          ticketId: ticketId, nom: nom, contact: contact);

  @override
  Future<void> descendreTicket({
    required int ticketId,
    required int gareId,
  }) =>
      _remote.descendreTicket(ticketId: ticketId, gareId: gareId);

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

  @override
  Future<void> modifierBagage({
    required int bagageId,
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) =>
      _remote.modifierBagage(
        bagageId: bagageId,
        ticketId: ticketId,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );

  @override
  Future<void> annulerBagage(int bagageId) => _remote.annulerBagage(bagageId);
}
