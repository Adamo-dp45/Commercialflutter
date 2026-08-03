import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/manifeste_remote_datasource.dart';
import '../../data/models/passager_manifeste.dart';
import '../../data/repositories/manifeste_repository_impl.dart';
import '../../domain/repositories/manifeste_repository.dart';

final _manifesteRemoteProvider = Provider<ManifesteRemoteDataSource>(
  (ref) => ManifesteRemoteDataSource(ref.watch(dioProvider)),
);

final manifesteRepositoryProvider = Provider<ManifesteRepository>(
  (ref) => ManifesteRepositoryImpl(ref.watch(_manifesteRemoteProvider)),
);

/// Le manifeste nominatif d'un voyage (passagers triés par siège).
///
/// `autoDispose` : rechargé à chaque ouverture, donc une vente faite dans le
/// tunnel apparaît sans invalidation croisée depuis la feature vente.
final manifesteProvider =
    FutureProvider.autoDispose.family<List<PassagerManifeste>, int>(
        (ref, voyageId) {
  return ref.watch(manifesteRepositoryProvider).manifeste(voyageId);
});
