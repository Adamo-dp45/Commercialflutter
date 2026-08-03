import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../voyages/presentation/providers/voyage_providers.dart';
import '../../domain/recette_synthese.dart';
import '../providers/recette_providers.dart';

/// « Ma recette » : la synthèse cumulée de ce que J'AI vendu sur mes voyages en
/// cours (recette, billets, bagages, panier moyen). Dérivée des mêmes données
/// que la home, mais agrégée — ce que la liste voyage-par-voyage ne montre pas.
class MaRecettePage extends ConsumerWidget {
  const MaRecettePage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(mesVoyagesProvider);
    await ref.read(mesVoyagesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recette = ref.watch(maRecetteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ma recette')),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: AsyncValueWidget(
          value: recette,
          onRetry: () => ref.invalidate(mesVoyagesProvider),
          data: (synthese) {
            if (synthese.estVide) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  AppEmptyView(
                    icon: Icons.account_balance_wallet_outlined,
                    message: 'Aucun voyage en cours.\n'
                        'Votre recette s\'affichera ici dès vos premières ventes '
                        'à bord.',
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              children: [
                _TotalCard(synthese: synthese),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.confirmation_number_outlined,
                        label: 'Billets',
                        value: Formatters.number(synthese.nbBillets),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.luggage_outlined,
                        label: 'Bagages',
                        value: Formatters.number(synthese.nbBagages),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.sell_outlined,
                        label: 'Panier moyen',
                        value: Formatters.money(synthese.panierMoyen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ScopeNote(nbVoyages: synthese.nbVoyages),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.synthese});

  final RecetteSynthese synthese;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet,
                    size: 20, color: scheme.onPrimaryContainer),
                const SizedBox(width: 8),
                Text('Recette sur mes voyages en cours',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: scheme.onPrimaryContainer)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              Formatters.money(synthese.recetteTotale),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
          ],
        ),
      ),
    );
  }
}

/// Rappel honnête du périmètre : le cumul ne porte que sur les voyages actifs ;
/// un voyage clôturé n'y figure plus.
class _ScopeNote extends StatelessWidget {
  const _ScopeNote({required this.nbVoyages});

  final int nbVoyages;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final pluriel = nbVoyages > 1 ? 'voyages actifs' : 'voyage actif';
    return Row(
      children: [
        Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Cumul sur $nbVoyages $pluriel. Les voyages clôturés n\'y '
            'figurent plus.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
