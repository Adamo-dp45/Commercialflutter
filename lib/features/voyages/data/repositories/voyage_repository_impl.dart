import '../../domain/repositories/voyage_repository.dart';
import '../datasources/voyage_remote_datasource.dart';
import '../models/voyage_commercial.dart';

class VoyageRepositoryImpl implements VoyageRepository {
  VoyageRepositoryImpl(this._remote);

  final VoyageRemoteDataSource _remote;

  @override
  Future<List<VoyageCommercial>> mesVoyages() => _remote.mesVoyages();

  @override
  Future<void> avancer({required int voyageId, required int gareId}) =>
      _remote.avancer(voyageId: voyageId, gareId: gareId);

  @override
  Future<void> repartir(int voyageId) => _remote.repartir(voyageId);
}
