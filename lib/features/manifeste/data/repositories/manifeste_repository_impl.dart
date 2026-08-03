import '../../domain/repositories/manifeste_repository.dart';
import '../datasources/manifeste_remote_datasource.dart';
import '../models/passager_manifeste.dart';

class ManifesteRepositoryImpl implements ManifesteRepository {
  ManifesteRepositoryImpl(this._remote);

  final ManifesteRemoteDataSource _remote;

  @override
  Future<List<PassagerManifeste>> manifeste(int voyageId) =>
      _remote.manifeste(voyageId);
}
