import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/offline_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/manifeste_local_datasource.dart';
import '../../data/datasources/manifeste_remote_datasource.dart';
import '../../data/models/passager_manifeste.dart';
import '../../data/repositories/manifeste_repository_impl.dart';
import '../../domain/repositories/manifeste_repository.dart';

final _manifesteRemoteProvider = Provider<ManifesteRemoteDataSource>(
  (ref) => ManifesteRemoteDataSource(ref.watch(dioProvider)),
);

/// La source locale est nullable : tant que la base n'est pas ouverte, le manifeste se comporte
/// exactement comme avant — il exige le réseau.
final manifesteRepositoryProvider = Provider<ManifesteRepository>((ref) {
  final file = ref.watch(fileOperationsProvider);

  return ManifesteRepositoryImpl(
    ref.watch(_manifesteRemoteProvider),
    local: file == null ? null : ManifesteLocalDataSource(file),
  );
});

/// Le manifeste nominatif d'un voyage (passagers triés par siège).
///
/// `autoDispose` : rechargé à chaque ouverture, donc une vente faite dans le
/// tunnel apparaît sans invalidation croisée depuis la feature vente.
final manifesteProvider =
    FutureProvider.autoDispose.family<List<PassagerManifeste>, int>(
        (ref, voyageId) {
  return ref.watch(manifesteRepositoryProvider).manifeste(voyageId);
});
