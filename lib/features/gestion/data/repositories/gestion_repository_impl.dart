import '../../../../core/models/bagage_cree.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/gestion_repository.dart';
import '../datasources/gestion_local_datasource.dart';
import '../datasources/gestion_remote_datasource.dart';
import '../models/mes_ventes.dart';

/// La LECTURE retombe sur l'instantané embarqué ; les CORRECTIONS restent en ligne.
///
/// Cette asymétrie est voulue. Relire ses ventes pour réimprimer un reçu perdu est le service que le
/// vendeur doit pouvoir rendre en pleine route, sans couverture. Corriger un billet, à l'inverse,
/// touche des données que le serveur arbitre : le faire à l'aveugle sur une copie vieillissante
/// créerait des divergences qu'aucune synchronisation ne saurait départager.
class GestionRepositoryImpl implements GestionRepository {
  // ignore_for_file: prefer_initializing_formals
  GestionRepositoryImpl(this._remote, {GestionLocalDataSource? local}) : _local = local;

  final GestionRemoteDataSource _remote;
  final GestionLocalDataSource? _local;

  @override
  Future<MesVentes> ventesDuVoyage(int voyageId) async {
    try {
      return await _remote.ventesDuVoyage(voyageId);
    } on ApiException catch (e) {
      final local = _local;
      if (!e.estHorsLigne || local == null) rethrow;

      return local.ventesDuVoyage(voyageId);
    }
  }

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
