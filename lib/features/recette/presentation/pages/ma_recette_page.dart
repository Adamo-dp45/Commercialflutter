import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/bilan_commercial.dart';
import '../providers/recette_providers.dart';

/// « Ma recette » : ce que J'AI vendu entre deux dates, et depuis toujours.
///
/// CE QUE CET ÉCRAN A CESSÉ DE FAIRE : cumuler les seuls voyages ACTIFS. Le
/// chiffre était dérivé de la liste d'accueil, donc un départ clôturé en sortait
/// — le vendeur voyait sa journée s'effacer à l'instant où son car arrivait, et
/// il ne lui restait rien pour se relire. Les deux chiffres viennent maintenant
/// du serveur (`GET /api/commercial/me`), qui sait compter les départs clos.
///
/// LES DEUX SONT MONTRÉS ENSEMBLE, et c'est voulu : la période répond à « qu'ai-je
/// fait cette semaine », le total à « où j'en suis ». Un écran qui ne montrerait
/// que la période laisserait croire, un jour creux, que le compteur est reparti
/// de zéro.
class MaRecettePage extends ConsumerWidget {
  const MaRecettePage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(bilanProvider);
    await ref.read(bilanProvider.future);
  }

  /// Un seul geste pour les deux bornes.
  ///
  /// !! PAS DE DATE FUTURE (`lastDate` = aujourd'hui) : on ne vend pas demain.
  /// Une borne au-delà n'ajouterait que des jours vides et ferait douter d'un
  /// chiffre pourtant juste.
  Future<void> _choisirPeriode(BuildContext context, WidgetRef ref) async {
    final courante = ref.read(periodeBilanProvider);
    final aujourdhui = DateTime.now();

    final choix = await showDateRangePicker(
      context: context,
      firstDate: DateTime(aujourdhui.year - 5),
      lastDate: aujourdhui,
      initialDateRange: DateTimeRange(
        start: courante.debut,
        end: courante.fin.isAfter(aujourdhui) ? aujourdhui : courante.fin,
      ),
      helpText: 'Période du bilan',
      saveText: 'Appliquer',
      locale: const Locale('fr', 'FR'),
    );
    if (choix == null) return;

    ref
        .read(periodeBilanProvider.notifier)
        .changer(debut: choix.start, fin: choix.end);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bilan = ref.watch(bilanProvider);
    final periode = ref.watch(periodeBilanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma recette'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Mes voyages',
            onPressed: () => context.push(AppRoutes.historiqueVoyages),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: AsyncValueWidget(
          value: bilan,
          onRetry: () => ref.invalidate(bilanProvider),
          data: (b) => ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _SelecteurPeriode(
                periode: periode,
                onTap: () => _choisirPeriode(context, ref),
              ),
              const SizedBox(height: 16),
              _TotalCard(
                titre: 'Recette sur la période',
                montant: b.surPeriode.recette,
                icone: Icons.account_balance_wallet,
              ),
              const SizedBox(height: 12),
              _Chiffres(chiffres: b.surPeriode),
              if (b.surPeriode.estVide) ...[
                const SizedBox(height: 12),
                const _Note(
                  'Aucune vente sur cette période. Changez les dates pour '
                  'retrouver vos ventes.',
                ),
              ],
              const SizedBox(height: 28),
              _SectionTitle('Depuis toujours'),
              _TotalCard(
                titre: 'Recette totale',
                montant: b.total.recette,
                icone: Icons.savings_outlined,
                discret: true,
              ),
              const SizedBox(height: 12),
              _Chiffres(chiffres: b.total),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.historiqueVoyages),
                icon: const Icon(Icons.history),
                label: Text(
                  b.total.nbVoyages > 0
                      ? 'Mes ${b.total.nbVoyages} voyages'
                      : 'Mes voyages',
                ),
              ),
              const SizedBox(height: 12),
              const _Note(
                'Une vente faite hors ligne compte le jour où elle remonte au '
                'serveur, pas le jour où elle a été encaissée.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Les bornes retenues PAR LE SERVEUR, pas celles qu'on lui a demandées : il
/// ramène le début au premier instant du jour et la fin au dernier, et c'est son
/// intervalle qui a produit le chiffre affiché juste en dessous.
class _SelecteurPeriode extends StatelessWidget {
  const _SelecteurPeriode({required this.periode, required this.onTap});

  final Periode periode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.date_range_outlined, size: 20, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Période',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(
                      'Du ${Formatters.dateCourte(periode.debut)} '
                      'au ${Formatters.dateCourte(periode.fin)}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Icon(Icons.edit_calendar_outlined,
                  size: 20, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.titre,
    required this.montant,
    required this.icone,
    this.discret = false,
  });

  final String titre;
  final int montant;
  final IconData icone;

  /// Le total « depuis toujours » est volontairement moins appuyé que la
  /// période : c'est un repère, pas le chiffre qu'on vient lire.
  final bool discret;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fond = discret ? scheme.surfaceContainerHighest : scheme.primaryContainer;
    final encre = discret ? scheme.onSurface : scheme.onPrimaryContainer;

    return Card(
      color: fond,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icone, size: 20, color: encre),
                const SizedBox(width: 8),
                Text(titre,
                    style: theme.textTheme.labelLarge?.copyWith(color: encre)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Formatters.money(montant),
              style: (discret
                      ? theme.textTheme.headlineMedium
                      : theme.textTheme.displaySmall)
                  ?.copyWith(fontWeight: FontWeight.w700, color: encre),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chiffres extends StatelessWidget {
  const _Chiffres({required this.chiffres});

  final BilanChiffres chiffres;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.confirmation_number_outlined,
            label: 'Billets',
            value: Formatters.number(chiffres.nbBillets),
            detail: Formatters.money(chiffres.recetteBillets),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.luggage_outlined,
            label: 'Bagages',
            value: Formatters.number(chiffres.nbBagages),
            detail: Formatters.money(chiffres.recetteBagages),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.sell_outlined,
            label: 'Panier moyen',
            value: Formatters.money(chiffres.panierMoyen),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Icon(icon, size: 22, color: scheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (detail != null) ...[
              const SizedBox(height: 2),
              Text(
                detail!,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.texte);

  final String texte;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            texte,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
