import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/bagage_cree.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../voyages/presentation/providers/voyage_providers.dart';
import '../../data/datasources/gestion_remote_datasource.dart';
import '../../data/models/mes_ventes.dart';
import '../../data/repositories/gestion_repository_impl.dart';
import '../../domain/repositories/gestion_repository.dart';

// -- Injection de dépendances (Dio partagé porté par la feature auth) -- //

final _gestionRemoteProvider = Provider<GestionRemoteDataSource>(
  (ref) => GestionRemoteDataSource(ref.watch(dioProvider)),
);

final gestionRepositoryProvider = Provider<GestionRepository>(
  (ref) => GestionRepositoryImpl(ref.watch(_gestionRemoteProvider)),
);

// -- Données : mes ventes d'un voyage (billets + bagages) -- //

/// Endpoint dédié `/api/voyages/{id}/me/ventes` : scopé au commercial connecté
/// côté serveur, hors périmètre gare (le vendeur opère hors de sa gare d'attache).
///
/// `autoDispose` : la page se recharge à chaque ouverture, donc une vente/bagage
/// faite ailleurs (tunnel de vente) est reflétée sans invalidation croisée.
final mesVentesProvider =
    FutureProvider.autoDispose.family<MesVentes, int>((ref, voyageId) {
  return ref.watch(gestionRepositoryProvider).ventesDuVoyage(voyageId);
});

// -- Actions -- //

/// Pilote les corrections ; l'état booléen indique qu'une action est en cours.
/// Rafraîchit « mes ventes » après succès ; les [ApiException] remontent.
class GestionActionsController extends Notifier<bool> {
  @override
  bool build() => false;

  GestionRepository get _repo => ref.read(gestionRepositoryProvider);

  Future<void> _refresh(int voyageId) async {
    ref.invalidate(mesVentesProvider(voyageId));
    // La recette du commercial (bagage ajouté, siège libéré, montant corrigé)
    // vit dans « mes voyages » : on la rafraîchit aussi, sinon l'affichage
    // (détail voyage / ma recette) reste figé.
    ref.invalidate(mesVoyagesProvider);
    await ref.read(mesVentesProvider(voyageId).future);
  }

  Future<void> modifierClient({
    required int voyageId,
    required int ticketId,
    String? nom,
    String? contact,
  }) async {
    state = true;
    try {
      await _repo.modifierClientTicket(
          ticketId: ticketId, nom: nom, contact: contact);
      await _refresh(voyageId);
    } finally {
      state = false;
    }
  }

  Future<void> descendrePassager({
    required int voyageId,
    required int ticketId,
    required int gareId,
  }) async {
    state = true;
    try {
      await _repo.descendreTicket(ticketId: ticketId, gareId: gareId);
      await _refresh(voyageId);
    } finally {
      state = false;
    }
  }

  Future<BagageCree> ajouterBagage({
    required int voyageId,
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    state = true;
    try {
      final cree = await _repo.ajouterBagage(
        ticketId: ticketId,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );
      await _refresh(voyageId);
      return cree;
    } finally {
      state = false;
    }
  }

  Future<void> modifierBagage({
    required int voyageId,
    required int bagageId,
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    state = true;
    try {
      await _repo.modifierBagage(
        bagageId: bagageId,
        ticketId: ticketId,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );
      await _refresh(voyageId);
    } finally {
      state = false;
    }
  }

  Future<void> annulerBagage({
    required int voyageId,
    required int bagageId,
  }) async {
    state = true;
    try {
      await _repo.annulerBagage(bagageId);
      await _refresh(voyageId);
    } finally {
      state = false;
    }
  }
}

final gestionActionsProvider =
    NotifierProvider<GestionActionsController, bool>(
        GestionActionsController.new);
