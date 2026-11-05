import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/voyage_historique.dart';
import '../providers/historique_controller.dart';

/// « Mes voyages » : TOUT ce que j'ai conduit comme vendeur à bord, du plus
/// récent au plus ancien, page par page.
///
/// POURQUOI UN ÉCRAN À PART de l'accueil : l'accueil porte les départs ACTIFS,
/// ceux sur lesquels on agit — il est armé pour le hors ligne et se garde en
/// copie locale. Ici on consulte, et le réseau est exigé. Mélanger les deux
/// mettrait toute la carrière du vendeur dans le cache de son téléphone.
///
/// LA LISTE CONTIENT AUSSI LES DÉPARTS EN COURS, signalés par un badge. Ce n'est
/// pas un filtre oublié : la somme des recettes de cette liste doit retomber sur
/// le total affiché par « Ma recette ». Un historique qui s'arrêterait aux
/// voyages clos montrerait moins que le total qu'il accompagne.
class HistoriqueVoyagesPage extends ConsumerWidget {
  const HistoriqueVoyagesPage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(historiqueProvider);
    await ref.read(historiqueProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historique = ref.watch(historiqueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes voyages'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(18),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              switch (historique.asData?.value.total) {
                null || 0 => '',
                1 => '1 voyage',
                final n => '$n voyages',
              },
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: AsyncValueWidget(
          value: historique,
          onRetry: () => ref.invalidate(historiqueProvider),
          data: (etat) {
            if (etat.voyages.isEmpty) {
              return ListView(
                // ListView (et non Center) pour garder le pull-to-refresh actif.
                children: const [
                  SizedBox(height: 120),
                  AppEmptyView(
                    icon: Icons.history,
                    message: 'Aucun voyage à votre nom pour le moment.\n'
                        'Vos départs apparaîtront ici dès qu\'une gare vous '
                        'désignera commercial à bord.',
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: etat.voyages.length + 1,
              itemBuilder: (context, i) {
                if (i == etat.voyages.length) {
                  return _PiedDeListe(
                    etat: etat,
                    onCharger: () =>
                        ref.read(historiqueProvider.notifier).chargerSuite(),
                  );
                }

                return _CarteVoyage(voyage: etat.voyages[i]);
              },
            );
          },
        ),
      ),
    );
  }
}

/// Le pied de liste dit TOUJOURS où l'on en est : il reste des pages, une page
/// est en vol, une page a échoué, ou l'on tient la fin.
///
/// LE CHARGEMENT EST UN GESTE, pas un effet du défilement. Sur une connexion
/// irrégulière — le quotidien de ces gares —, une liste qui part chercher toute
/// seule dépense le réseau du vendeur sans le lui demander, et échoue sans qu'il
/// comprenne pourquoi. Un bouton dit ce qu'il va faire et ce qu'il reste.
class _PiedDeListe extends StatelessWidget {
  const _PiedDeListe({required this.etat, required this.onCharger});

  final HistoriqueEtat etat;
  final VoidCallback onCharger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (etat.chargeLaSuite) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (etat.erreur != null) {
      // L'ÉCHEC NE REMPLACE PAS CE QUI EST DÉJÀ AFFICHÉ : les pages chargées
      // restent lisibles, et le défaut se répare là où il s'est produit.
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              etat.erreur!,
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.error),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onCharger,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (etat.aUneSuite) {
      final reste = etat.total - etat.voyages.length;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: OutlinedButton.icon(
          onPressed: onCharger,
          icon: const Icon(Icons.expand_more),
          label: Text(
            reste > 0 ? 'Charger la suite ($reste restants)' : 'Charger la suite',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          'Fin de votre historique.',
          style: theme.textTheme.labelSmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

class _CarteVoyage extends StatelessWidget {
  const _CarteVoyage({required this.voyage});

  final VoyageHistorique voyage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    /*
      SEUL UN DÉPART EN COURS S'OUVRE. La fiche du détail se compose à partir des
      voyages ACTIFS (`voyageByIdProvider`) : y envoyer un départ clôturé
      afficherait « ce voyage n'est plus actif » — une impasse, et le vendeur
      croirait à un défaut. Une carte qui ne mène nulle part ne doit pas donner
      l'impression qu'elle le pourrait, d'où l'absence de chevron.
    */
    final ouvrable = !voyage.cloture;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: ouvrable
            ? () => context.push(AppRoutes.voyageDetail(voyage.id))
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      voyage.libelleDepart,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  // LES DEUX ÉTATS SE DISENT, pas seulement l'un. Ne marquer que « En cours »
                  // laissait le reste de la liste sans qualificatif : l'absence de badge se lit
                  // comme une information manquante, pas comme un départ terminé.
                  _BadgeEtat(cloture: voyage.cloture),
                  if (ouvrable)
                    Icon(Icons.chevron_right,
                        size: 20, color: scheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 6),
              Text(voyage.trajet, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.schedule, size: 15, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      Formatters.dateTime(voyage.datedepartprevue),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                  if (voyage.carMatricule != null) ...[
                    Icon(Icons.directions_bus_filled_outlined,
                        size: 15, color: scheme.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      voyage.carMatricule!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
              const Divider(height: 22),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ma recette',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant)),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.money(voyage.maRecette),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _Compteur(
                    icone: Icons.confirmation_number_outlined,
                    valeur: voyage.mesTickets,
                    libelle: 'billets',
                  ),
                  const SizedBox(width: 14),
                  _Compteur(
                    icone: Icons.luggage_outlined,
                    valeur: voyage.mesBagages,
                    libelle: 'bagages',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// L'état du départ, dit dans les deux sens.
///
/// « En cours » est mis en avant (couleur d'accent) et « Clôturé » reste sobre : le premier
/// appelle un geste — il reste des ventes à faire, une caisse à compter —, le second ne demande
/// rien. Deux badges de même poids visuel donneraient à une liste d'historique l'air d'une liste
/// de tâches.
class _BadgeEtat extends StatelessWidget {
  const _BadgeEtat({required this.cloture});

  final bool cloture;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: cloture ? scheme.surfaceContainerHighest : scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            cloture ? Icons.check_circle_outline : Icons.directions_bus_filled_outlined,
            size: 12,
            color: cloture ? scheme.onSurfaceVariant : scheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Text(
            cloture ? 'Clôturé' : 'En cours',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cloture ? scheme.onSurfaceVariant : scheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({
    required this.icone,
    required this.valeur,
    required this.libelle,
  });

  final IconData icone;
  final int valeur;
  final String libelle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$valeur',
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 3),
        Text(
          libelle,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
