import '../../domain/repositories/bilan_repository.dart';
import '../datasources/bilan_remote_datasource.dart';
import '../models/bilan_commercial.dart';

/// Le bilan vient du serveur, et de lui seul (cf. le contrat pour le pourquoi
/// de l'absence de cache).
class BilanRepositoryImpl implements BilanRepository {
  BilanRepositoryImpl(this._remote);

  final BilanRemoteDataSource _remote;

  @override
  Future<BilanCommercial> bilan({String? debut, String? fin}) =>
      _remote.bilan(debut: debut, fin: fin);
}
