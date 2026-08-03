import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/voyage_commercial.dart';
import '../providers/voyage_providers.dart';
import '../widgets/progression_view.dart';

/// Détail d'un voyage : itinéraire + position du car, ma performance, et les
/// actions de progression (déclarer l'arrivée à l'arrêt suivant, faire repartir).
class VoyageDetailPage extends ConsumerWidget {
  const VoyageDetailPage({super.key, required this.voyageId});

  final int voyageId;

  Future<bool> _confirm(BuildContext context, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    String successMessage,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voyage = ref.watch(voyageByIdProvider(voyageId));
    final busy = ref.watch(voyageActionsProvider);
    // La vente exige la permission Ticket/CREER (imposée au POST) en plus des
    // conditions métier (car, position, arrêt en aval).
    final peutVendre = (voyage?.peutVendre ?? false) &&
        (ref.watch(authControllerProvider).user?.can('Ticket', 'CREER') ??
            false);

    if (voyage == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Ce voyage n\'est plus actif (clôturé ou terminé).',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(voyage.codevoyage ?? 'Voyage #${voyage.id}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _HeaderCard(voyage: voyage),
          const SizedBox(height: 16),
          if (peutVendre) ...[
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.vente(voyage.id)),
              icon: const Icon(Icons.point_of_sale),
              label: const Text('Vendre un billet'),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.mesVentes(voyage.id)),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('Mes ventes (réimprimer / corriger)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.manifeste(voyage.id)),
            icon: const Icon(Icons.people_outline),
            label: const Text('Manifeste des passagers'),
          ),
          const SizedBox(height: 16),
          _SectionTitle('Ma performance'),
          _PerfCard(voyage: voyage),
          const SizedBox(height: 16),
          _SectionTitle('Itinéraire'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ProgressionView(voyage: voyage),
            ),
          ),
          const SizedBox(height: 20),
          _Actions(
            voyage: voyage,
            busy: busy,
            onAvancer: () async {
              final next = voyage.prochainArret;
              if (next == null) return;
              if (!await _confirm(
                context,
                'Confirmer que le car est arrivé à ${next.libelle} ?',
              )) {
                return;
              }
              if (!context.mounted) return;
              await _run(
                context,
                ref,
                () => ref.read(voyageActionsProvider.notifier).avancer(
                      voyageId: voyage.id,
                      gareId: next.id,
                    ),
                'Position mise à jour : ${next.libelle}.',
              );
            },
            onRepartir: () async {
              if (!await _confirm(
                context,
                'Confirmer le départ du car de ${voyage.garecouranteLibelle ?? 'cette gare'} ?',
              )) {
                return;
              }
              if (!context.mounted) return;
              await _run(
                context,
                ref,
                () =>
                    ref.read(voyageActionsProvider.notifier).repartir(voyage.id),
                'Départ enregistré.',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.voyage});

  final VoyageCommercial voyage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(voyage.trajet,
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: scheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text('Départ prévu ${Formatters.dateTime(voyage.datedepartprevue)}',
                    style: theme.textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.directions_bus_filled_outlined,
                    size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    voyage.demarre
                        ? 'En route · position : ${voyage.garecouranteLibelle ?? '—'}'
                        : 'Pas encore parti',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PerfCard extends StatelessWidget {
  const _PerfCard({required this.voyage});

  final VoyageCommercial voyage;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _Stat(label: 'Ma recette', value: Formatters.money(voyage.maRecette)),
            _Stat(label: 'Mes billets', value: '${voyage.mesTickets}'),
            _Stat(label: 'Mes bagages', value: '${voyage.mesBagages}'),
            _Stat(
              label: 'Places libres',
              value: '${voyage.placesLibres}/${voyage.placestotal}',
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ],
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

class _Actions extends StatelessWidget {
  const _Actions({
    required this.voyage,
    required this.busy,
    required this.onAvancer,
    required this.onRepartir,
  });

  final VoyageCommercial voyage;
  final bool busy;
  final VoidCallback onAvancer;
  final VoidCallback onRepartir;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    if (!voyage.demarre) {
      return _InfoBanner(
        text: 'Le voyage démarre depuis sa gare d\'origine. '
            'Vous pourrez suivre sa progression une fois parti.',
      );
    }

    final next = voyage.prochainArret;
    final spinner = busy
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (voyage.peutRepartir)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FilledButton.icon(
              onPressed: busy ? null : onRepartir,
              icon: spinner ?? const Icon(Icons.play_arrow_rounded),
              label: Text(
                  'Le car repart de ${voyage.garecouranteLibelle ?? 'cette gare'}'),
            ),
          ),
        if (next != null)
          FilledButton.icon(
            onPressed: busy ? null : onAvancer,
            style: voyage.peutRepartir
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.secondaryContainer,
                    foregroundColor: scheme.onSecondaryContainer,
                  )
                : null,
            icon: spinner ?? const Icon(Icons.location_on_outlined),
            label: Text('Le car est arrivé à ${next.libelle}'),
          )
        else
          _InfoBanner(
            text: 'Le car est au terminus. La clôture se fait à la gare '
                'd\'arrivée.',
          ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
