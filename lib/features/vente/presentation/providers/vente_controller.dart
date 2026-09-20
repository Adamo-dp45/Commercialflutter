import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/bagage_cree.dart';
import '../../../../core/network/api_exception.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../voyages/data/models/arret.dart';
import '../../../voyages/data/models/voyage_commercial.dart';
import '../../../voyages/presentation/providers/voyage_providers.dart';
import '../../data/datasources/vente_remote_datasource.dart';
import '../../data/models/siege.dart';
import '../../data/models/ticket_vendu.dart';
import '../../../../core/offline/codes_hors_ligne.dart';
import '../../../../core/offline/offline_providers.dart';
import '../../data/datasources/vente_local_datasource.dart';
import '../../data/repositories/vente_repository_impl.dart';
import '../../domain/repositories/vente_repository.dart';

part 'vente_controller.freezed.dart';

// -- Injection de dépendances -- //

final _venteRemoteProvider = Provider<VenteRemoteDataSource>(
  (ref) => VenteRemoteDataSource(ref.watch(dioProvider)),
);

/// Le repository sait vendre EN LIGNE et, à l'échec réseau, basculer sur l'instantané embarqué.
/// Les trois dépendances hors ligne sont nullables : tant que la base locale n'est pas ouverte
/// (quelques millisecondes au démarrage), l'application se comporte exactement comme avant.
final venteRepositoryProvider = Provider<VenteRepository>((ref) {
  final file = ref.watch(fileOperationsProvider);

  return VenteRepositoryImpl(
    ref.watch(_venteRemoteProvider),
    local: file == null ? null : VenteLocalDataSource(file),
    synchronisateur: ref.watch(synchronisateurProvider),
    codes: file == null ? null : CodesHorsLigne(file),
    file: file,
  );
});

// -- État du tunnel de vente -- //

/// Étapes de la vente à bord.
enum VenteStep { descente, siege, client, confirmation, done }

@freezed
abstract class VenteState with _$VenteState {
  const VenteState._();

  const factory VenteState({
    VoyageCommercial? voyage,
    @Default(VenteStep.descente) VenteStep step,
    Arret? descente,
    @Default(<Siege>[]) List<Siege> sieges,
    @Default(false) bool loadingSieges,
    Siege? siege,
    int? tarif,
    @Default('') String nom,
    @Default('') String contact,
    // Remise saisie par le commercial (comme sur le web). 'AUCUNE' = plein tarif.
    @Default('AUCUNE') String remiseType, // AUCUNE | POURCENTAGE | MONTANT
    @Default(0) int remiseValeur, // % ou FCFA selon le type
    @Default(false) bool submitting,
    String? error,
    TicketVendu? ticket,
  }) = _VenteState;

  /// Gare de montée = position courante du car (forcée côté serveur).
  Arret? get montee => voyage?.arretCourant;

  bool get pretAConfirmer =>
      voyage != null && descente != null && siege != null;

  /// Remise ESTIMÉE localement (le serveur reste seul maître du montant final,
  /// notamment du plafond) : sert l'aperçu du net avant confirmation.
  int get remiseEstimee {
    final t = tarif ?? 0;
    if (remiseType == 'AUCUNE' || remiseValeur <= 0 || t <= 0) return 0;
    final r = remiseType == 'POURCENTAGE'
        ? (t * remiseValeur.clamp(0, 100) / 100).round()
        : remiseValeur;
    return r > t ? t : r;
  }

  /// Net estimé = tarif - remise estimée.
  int get netEstime => (tarif ?? 0) - remiseEstimee;
}

/// Pilote la vente : sélection descente → siège → client → confirmation.
/// Tout l'état du tunnel vit ici, la navigation ne perd donc pas le contexte.
/// Un seul tunnel à la fois (le commercial vend un billet à la fois).
class VenteController extends Notifier<VenteState> {
  /// Rafraîchit le plan de sièges tant qu'on est à l'étape « siège » (ventes
  /// concurrentes d'autres gares / du guichet).
  Timer? _seatTimer;

  @override
  VenteState build() {
    ref.onDispose(() => _seatTimer?.cancel());
    return const VenteState();
  }

  VenteRepository get _repo => ref.read(venteRepositoryProvider);

  /// (Ré)initialise le tunnel pour [voyage].
  void start(VoyageCommercial voyage) {
    state = VenteState(voyage: voyage);
    _syncSeatPolling();
  }

  void goTo(VenteStep step) {
    state = state.copyWith(step: step, error: null);
    _syncSeatPolling();
  }

  void back() {
    const order = VenteStep.values;
    final i = order.indexOf(state.step);
    if (i > 0) goTo(order[i - 1]);
  }

  /// Choix de la destination → charge le plan de sièges et le tarif du tronçon.
  Future<void> selectDescente(Arret descente) async {
    state = state.copyWith(
      descente: descente,
      siege: null,
      sieges: const [],
      tarif: null,
      step: VenteStep.siege,
      loadingSieges: true,
      error: null,
    );
    await _loadSieges();
  }

  Future<void> reloadSieges() async {
    state = state.copyWith(loadingSieges: true, error: null);
    await _loadSieges();
  }

  Future<void> _loadSieges() async {
    final v = state.voyage;
    final montee = state.montee;
    final descente = state.descente;
    if (v == null || v.carId == null || montee == null || descente == null) {
      state = state.copyWith(loadingSieges: false);
      return;
    }
    try {
      final siegesFuture = _repo.sieges(
        carId: v.carId!,
        voyageId: v.id,
        monteeId: montee.id,
        descenteId: descente.id,
      );
      final tarifFuture =
          _repo.tarif(monteeId: montee.id, descenteId: descente.id, voyageId: v.id);
      final sieges = await siegesFuture;
      final tarif = await tarifFuture;
      state = state.copyWith(
        sieges: sieges,
        tarif: tarif,
        loadingSieges: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(loadingSieges: false, error: e.message);
    }
    _syncSeatPolling();
  }

  void selectSiege(Siege siege) {
    if (!siege.estLibre) return;
    state = state.copyWith(siege: siege, step: VenteStep.client, error: null);
    _syncSeatPolling();
  }

  void setClient({required String nom, required String contact}) {
    state = state.copyWith(nom: nom, contact: contact);
  }

  /// Définit la remise ('AUCUNE' | 'POURCENTAGE' | 'MONTANT').
  void setRemise({required String type, required int valeur}) {
    state = state.copyWith(
      remiseType: type,
      remiseValeur: type == 'AUCUNE' ? 0 : valeur,
    );
  }

  /// Émet le billet ; en cas de succès, passe à l'étape « reçu ».
  Future<void> confirmer() async {
    final v = state.voyage;
    final montee = state.montee;
    final descente = state.descente;
    final siege = state.siege;
    if (v == null || montee == null || descente == null || siege == null) {
      return;
    }

    state = state.copyWith(submitting: true, error: null);
    try {
      final aRemise = state.remiseType != 'AUCUNE' && state.remiseValeur > 0;
      final ticket = await _repo.vendreTicket(
        voyageId: v.id,
        siegeId: siege.id,
        monteeGareId: montee.id,
        descenteGareId: descente.id,
        nom: state.nom,
        contact: state.contact,
        remiseType: aRemise ? state.remiseType : null,
        remiseValeur: aRemise ? state.remiseValeur : null,
      );
      // Rafraîchit « mes voyages » (recette + places à jour).
      ref.invalidate(mesVoyagesProvider);
      state = state.copyWith(
        submitting: false,
        ticket: ticket,
        step: VenteStep.done,
      );
    } on ApiException catch (e) {
      state = state.copyWith(submitting: false, error: e.message);
    }
  }

  /// Rattache un bagage au billet vendu. Propage l'[ApiException] à l'appelant.
  ///
  /// On n'exige plus d'identifiant serveur : un billet vendu hors ligne n'en a pas, et le refus
  /// aurait laissé le vendeur avec un bagage à bord et aucun moyen de l'enregistrer. Le CODE du
  /// billet suffit — il est imprimé sur le reçu du client et le serveur sait le retrouver.
  Future<BagageCree> ajouterBagage({
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    final voyageId = state.voyage?.id;
    final codeticket = state.ticket?.codeticket;
    if (voyageId == null || codeticket == null) {
      throw const ApiException('Aucun billet à rattacher.');
    }
    final cree = await _repo.ajouterBagage(
      voyageId: voyageId,
      codeticket: codeticket,
      ticketId: state.ticket?.id,
      nature: nature,
      type: type,
      poids: poids,
      montant: montant,
    );
    ref.invalidate(mesVoyagesProvider);
    return cree;
  }

  void reset() {
    state = const VenteState();
    _syncSeatPolling();
  }

  // ── Polling du plan de sièges (étape « siège ») ──────────────────────────

  /// Démarre le rafraîchissement périodique si l'on est sur le plan de sièges,
  /// l'arrête sinon. Idempotent (ne recrée pas un timer déjà actif).
  void _syncSeatPolling() {
    if (state.step == VenteStep.siege) {
      _seatTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
        if (state.step == VenteStep.siege && !state.loadingSieges) {
          _refreshSiegesSilencieux();
        }
      });
    } else {
      _seatTimer?.cancel();
      _seatTimer = null;
    }
  }

  /// Recharge les sièges SANS spinner ni changement d'étape : reflète les ventes
  /// concurrentes. Silencieux en cas d'erreur (ne perturbe pas la vente).
  Future<void> _refreshSiegesSilencieux() async {
    final v = state.voyage;
    final montee = state.montee;
    final descente = state.descente;
    if (v == null || v.carId == null || montee == null || descente == null) {
      return;
    }
    try {
      final sieges = await _repo.sieges(
        carId: v.carId!,
        voyageId: v.id,
        monteeId: montee.id,
        descenteId: descente.id,
      );
      // Ne pas écraser si l'agent a quitté l'étape entre-temps.
      if (state.step == VenteStep.siege) {
        state = state.copyWith(sieges: sieges);
      }
    } catch (_) {
      // rafraîchissement de fond : on ignore les erreurs
    }
  }
}

final venteControllerProvider =
    NotifierProvider<VenteController, VenteState>(VenteController.new);
