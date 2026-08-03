import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../voyages/presentation/providers/voyage_providers.dart';
import '../../domain/recette_synthese.dart';

/// Ma recette cumulée, dérivée en direct de `mesVoyagesProvider` : partage son
/// chargement/erreur, se recalcule après chaque vente ou action de progression
/// (qui invalident déjà la liste). Aucun appel réseau propre.
final maRecetteProvider = Provider<AsyncValue<RecetteSynthese>>((ref) {
  return ref.watch(mesVoyagesProvider).whenData(RecetteSynthese.fromVoyages);
});
