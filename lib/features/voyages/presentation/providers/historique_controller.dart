import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/models/voyage_historique.dart';
import 'voyage_providers.dart';

part 'historique_controller.freezed.dart';

/// L'historique tel que l'écran le connaît : les pages DÉJÀ chargées, bout à
/// bout, plus de quoi savoir s'il en reste.
///
/// `chargeLaSuite` et `erreur` sont portés par l'état plutôt que par
/// `AsyncValue` : passer le provider en `AsyncLoading` pour charger la page
/// suivante effacerait la liste à l'écran — le vendeur verrait disparaître ce
/// qu'il est en train de lire chaque fois qu'il atteint le bas. De même, une
/// panne sur la page 3 ne doit pas emporter les pages 1 et 2 : elle s'affiche
/// EN BAS, avec un bouton pour réessayer.
@freezed
abstract class HistoriqueEtat with _$HistoriqueEtat {
  const HistoriqueEtat._();

  const factory HistoriqueEtat({
    @Default(<VoyageHistorique>[]) List<VoyageHistorique> voyages,
    @Default(0) int page,
    @Default(0) int pages,
    @Default(0) int total,
    @Default(false) bool chargeLaSuite,
    String? erreur,
  }) = _HistoriqueEtat;

  bool get aUneSuite => page < pages;
}

/// Charge l'historique page par page, à mesure que le vendeur descend.
class HistoriqueController extends AsyncNotifier<HistoriqueEtat> {
  @override
  Future<HistoriqueEtat> build() async {
    final page = await ref.watch(voyageRepositoryProvider).historique(page: 1);

    return HistoriqueEtat(
      voyages: page.voyages,
      page: page.page,
      pages: page.pages,
      total: page.total,
    );
  }

  /// Ajoute la page suivante à celles déjà affichées.
  ///
  /// Sans effet si une page est déjà en vol ou si l'on tient la dernière : le
  /// bas d'une liste se franchit plusieurs fois de suite pendant un défilement,
  /// et sans cette garde le même appel partirait en rafale.
  Future<void> chargerSuite() async {
    final courant = state.asData?.value;
    if (courant == null || courant.chargeLaSuite || !courant.aUneSuite) return;

    state = AsyncData(HistoriqueEtat(
      voyages: courant.voyages,
      page: courant.page,
      pages: courant.pages,
      total: courant.total,
      chargeLaSuite: true,
    ));

    try {
      final suite =
          await ref.read(voyageRepositoryProvider).historique(page: courant.page + 1);

      /*
        DÉDUPLICATION PAR IDENTIFIANT, en ceinture. Le serveur départage son tri
        par 'v.id' justement pour qu'une ligne ne puisse pas changer de page
        entre deux requêtes — mais ici les pages sont demandées à des instants
        différents, et un départ créé entre-temps décale tout d'un rang. Sans
        cette garde, le vendeur verrait deux fois le même voyage et compterait
        sa recette deux fois à l'œil.
      */
      final vus = {for (final v in courant.voyages) v.id};
      final nouveaux = [
        for (final v in suite.voyages)
          if (vus.add(v.id)) v,
      ];

      state = AsyncData(HistoriqueEtat(
        voyages: [...courant.voyages, ...nouveaux],
        page: suite.page,
        pages: suite.pages,
        total: suite.total,
      ));
    } on ApiException catch (e) {
      state = AsyncData(HistoriqueEtat(
        voyages: courant.voyages,
        page: courant.page,
        pages: courant.pages,
        total: courant.total,
        erreur: e.message,
      ));
    }
  }
}

/// `autoDispose` : l'historique se relit depuis le début à chaque ouverture de
/// l'écran. Garder les pages d'une visite à l'autre montrerait un passé figé au
/// vendeur qui vient justement de clore un départ.
final historiqueProvider =
    AsyncNotifierProvider.autoDispose<HistoriqueController, HistoriqueEtat>(
  HistoriqueController.new,
);
