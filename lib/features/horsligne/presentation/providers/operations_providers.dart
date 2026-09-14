import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/offline/offline_providers.dart';
import '../../../../core/offline/operation_hors_ligne.dart';

/// Le journal local d'un voyage : ce qui attend, ce qui est passé, ce qui a été refusé.
///
/// Il ne vient PAS du serveur, et ne peut pas en venir : une opération refusée n'existe nulle part
/// ailleurs que sur ce téléphone. C'est précisément ce qui rend cet écran nécessaire — sans lui, un
/// billet refusé à la synchronisation disparaîtrait en silence alors que le vendeur a encaissé
/// l'argent et remis un reçu.
final operationsDuVoyageProvider =
    FutureProvider.autoDispose.family<List<OperationHorsLigne>, int>((ref, voyageId) async {
  final file = ref.watch(fileOperationsProvider);
  if (file == null) return const [];

  // Se recalcule à chaque écriture dans la file : mise en file, ou sort rendu par le serveur.
  ref.watch(revisionFileProvider);

  return file.toutes(voyageId);
});

/// Le numéro affiché de chaque siège du car, lu dans l'instantané.
///
/// La file, elle, ne porte que l'IDENTIFIANT du siège — c'est ce que le serveur attend. Afficher
/// « Siège 225 » au vendeur n'aurait aucun sens : il ne connaît que les numéros peints dans le car.
final numeroParSiegeProvider =
    FutureProvider.autoDispose.family<Map<int, int>, int>((ref, voyageId) async {
  final file = ref.watch(fileOperationsProvider);
  final instantane = file == null ? null : await file.instantane(voyageId);
  if (instantane == null) return const {};

  return {
    for (final siege in (instantane['sieges'] as List<dynamic>? ?? const []))
      (siege as Map<String, dynamic>)['id'] as int: siege['numero'] as int? ?? 0,
  };
});
