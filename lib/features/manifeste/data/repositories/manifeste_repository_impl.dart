import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/manifeste_repository.dart';
import '../datasources/manifeste_local_datasource.dart';
import '../datasources/manifeste_remote_datasource.dart';
import '../models/passager_manifeste.dart';

/// Le manifeste vient du serveur quand il répond, de l'instantané sinon.
///
/// Comme pour la vente, le choix se fait à l'échec RÉEL de l'appel et non sur l'état déclaré du
/// réseau : un téléphone accroché à une antenne sans débit se dit connecté.
class ManifesteRepositoryImpl implements ManifesteRepository {
  // Champ privé, paramètre public : une formelle d'initialisation exposerait '_local' comme nom de
  // paramètre à l'appelant. D'où l'affectation explicite — même parti pris que VenteRepositoryImpl.
  // ignore_for_file: prefer_initializing_formals
  const ManifesteRepositoryImpl(this._remote, {ManifesteLocalDataSource? local}) : _local = local;

  final ManifesteRemoteDataSource _remote;
  final ManifesteLocalDataSource? _local;

  @override
  Future<List<PassagerManifeste>> manifeste(int voyageId) async {
    try {
      return await _remote.manifeste(voyageId);
    } on ApiException catch (e) {
      final local = _local;
      if (!e.estHorsLigne || local == null) rethrow;

      return local.manifeste(voyageId);
    }
  }
}
