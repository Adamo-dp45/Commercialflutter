import 'package:flutter/material.dart';

import '../../data/models/voyage_commercial.dart';

/// Frise verticale des arrêts de la ligne, avec la POSITION du car mise en avant.
/// Les arrêts déjà dépassés sont estompés, l'arrêt courant porte l'icône du car,
/// les arrêts à venir restent neutres.
class ProgressionView extends StatelessWidget {
  const ProgressionView({super.key, required this.voyage});

  final VoyageCommercial voyage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final arrets = voyage.arretsOrdonnes;
    final courantOrdre = voyage.arretCourant?.ordre;

    if (arrets.isEmpty) {
      return Text('Itinéraire non renseigné.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: scheme.onSurfaceVariant));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < arrets.length; i++)
          _ArretRow(
            libelle: arrets[i].libelle,
            isFirst: i == 0,
            isLast: i == arrets.length - 1,
            state: _stateFor(arrets[i].ordre, courantOrdre),
          ),
      ],
    );
  }

  _ArretState _stateFor(int ordre, int? courantOrdre) {
    if (courantOrdre == null) return _ArretState.upcoming;
    if (ordre == courantOrdre) return _ArretState.current;
    if (ordre < courantOrdre) return _ArretState.passed;
    return _ArretState.upcoming;
  }
}

enum _ArretState { passed, current, upcoming }

class _ArretRow extends StatelessWidget {
  const _ArretRow({
    required this.libelle,
    required this.isFirst,
    required this.isLast,
    required this.state,
  });

  final String libelle;
  final bool isFirst;
  final bool isLast;
  final _ArretState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final passed = state == _ArretState.passed;
    final current = state == _ArretState.current;
    final lineColor = passed || current ? scheme.primary : scheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colonne indicateur (connecteurs + pastille/bus)
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : lineColor,
                  ),
                ),
                _Marker(state: state),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : (passed ? scheme.primary : scheme.outlineVariant),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                libelle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: current ? FontWeight.w700 : FontWeight.w400,
                  color: passed ? scheme.onSurfaceVariant : scheme.onSurface,
                ),
              ),
            ),
          ),
          if (current)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('Car ici',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.primary, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({required this.state});

  final _ArretState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (state) {
      case _ArretState.current:
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
          child: Icon(Icons.directions_bus_filled,
              size: 16, color: scheme.onPrimary),
        );
      case _ArretState.passed:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
        );
      case _ArretState.upcoming:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: scheme.surface,
            shape: BoxShape.circle,
            border: Border.all(color: scheme.outlineVariant, width: 2),
          ),
        );
    }
  }
}
