import 'package:flutter/material.dart';

import '../../../../core/formatting/formatters.dart';
import '../../data/models/voyage_commercial.dart';

/// Carte résumant un voyage dans la liste « mes voyages » : trajet, statut,
/// position du car et MA performance propre (recette + billets).
class VoyageCard extends StatelessWidget {
  const VoyageCard({super.key, required this.voyage, required this.onTap});

  final VoyageCommercial voyage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
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
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFeatures: const [],
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  _StatusBadge(demarre: voyage.demarre),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                voyage.trajet,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.directions_bus_filled_outlined,
                      size: 18, color: scheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      voyage.garecouranteLibelle == null
                          ? 'Position non renseignée'
                          : 'Position : ${voyage.garecouranteLibelle}',
                      style: theme.textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Divider(height: 22),
              Row(
                children: [
                  _Metric(
                    icon: Icons.payments_outlined,
                    label: 'Ma recette',
                    value: Formatters.money(voyage.maRecette),
                  ),
                  const SizedBox(width: 20),
                  _Metric(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Mes billets',
                    value: '${voyage.mesTickets}',
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.demarre});

  final bool demarre;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, label) = demarre
        ? (scheme.primaryContainer, scheme.onPrimaryContainer, 'En route')
        : (scheme.surfaceContainerHighest, scheme.onSurfaceVariant, 'À venir');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: scheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: scheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
