import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/voyage_remote_datasource.dart';
import '../../data/models/voyage_commercial.dart';
import '../../data/repositories/voyage_repository_impl.dart';
import '../../domain/repositories/voyage_repository.dart';

// -- Injection de dépendances (Dio partagé porté par la feature auth) -- //

final _voyageRemoteProvider = Provider<VoyageRemoteDataSource>(
  (ref) => VoyageRemoteDataSource(ref.watch(dioProvider)),
);

final voyageRepositoryProvider = Provider<VoyageRepository>(
  (ref) => VoyageRepositoryImpl(ref.watch(_voyageRemoteProvider)),
);

// -- Données -- //

/// Mes voyages actifs (rafraîchi après chaque action de progression).
final mesVoyagesProvider = FutureProvider<List<VoyageCommercial>>(
  (ref) => ref.watch(voyageRepositoryProvider).mesVoyages(),
);

/// Un voyage précis depuis la liste chargée (source unique : `mesVoyagesProvider`).
/// `null` si le voyage n'est plus actif (clôturé entre-temps).
final voyageByIdProvider = Provider.family<VoyageCommercial?, int>((ref, id) {
  final list = ref.watch(mesVoyagesProvider).asData?.value ?? const [];
  for (final v in list) {
    if (v.id == id) return v;
  }
  return null;
});

// -- Actions de progression -- //

/// Pilote les actions « avancer » / « le car repart » ; l'état booléen indique
/// qu'une action est en cours (désactive les boutons). Rafraîchit la liste après
/// succès. Les [ApiException] remontent à l'appelant pour l'affichage.
class VoyageActionsController extends Notifier<bool> {
  @override
  bool build() => false;

  VoyageRepository get _repo => ref.read(voyageRepositoryProvider);

  Future<void> avancer({required int voyageId, required int gareId}) async {
    state = true;
    try {
      await _repo.avancer(voyageId: voyageId, gareId: gareId);
      ref.invalidate(mesVoyagesProvider);
      await ref.read(mesVoyagesProvider.future);
    } finally {
      state = false;
    }
  }

  Future<void> repartir(int voyageId) async {
    state = true;
    try {
      await _repo.repartir(voyageId);
      ref.invalidate(mesVoyagesProvider);
      await ref.read(mesVoyagesProvider.future);
    } finally {
      state = false;
    }
  }
}

final voyageActionsProvider =
    NotifierProvider<VoyageActionsController, bool>(VoyageActionsController.new);
