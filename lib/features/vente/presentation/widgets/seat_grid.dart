import 'package:flutter/material.dart';

import '../../data/models/siege.dart';

/// Plan de sièges du car pour le tronçon en cours. Disposition « bus » simple :
/// par rangée, sièges de gauche · couloir · sièges de droite. Les sièges occupés
/// sont grisés ; le siège choisi est mis en avant ; un siège « revendu » ou en
/// « conflit » (billet évincé) est signalé sans bloquer la vente.
class SeatGrid extends StatelessWidget {
  const SeatGrid({
    super.key,
    required this.sieges,
    required this.selectedId,
    required this.onTap,
  });

  final List<Siege> sieges;
  final int? selectedId;
  final void Function(Siege siege) onTap;

  @override
  Widget build(BuildContext context) {
    if (sieges.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('Aucun siège pour ce véhicule.')),
      );
    }

    // Regroupement par rangée (ordre croissant).
    final byRangee = <int, List<Siege>>{};
    for (final s in sieges) {
      byRangee.putIfAbsent(s.rangee, () => []).add(s);
    }
    final rangees = byRangee.keys.toList()..sort();

    return Column(
      children: [
        for (final r in rangees) _RangeeRow(sieges: byRangee[r]!, selectedId: selectedId, onTap: onTap),
        const SizedBox(height: 16),
        const _Legend(),
      ],
    );
  }
}

class _RangeeRow extends StatelessWidget {
  const _RangeeRow({
    required this.sieges,
    required this.selectedId,
    required this.onTap,
  });

  final List<Siege> sieges;
  final int? selectedId;
  final void Function(Siege siege) onTap;

  @override
  Widget build(BuildContext context) {
    final gauche = sieges.where((s) => s.cote == 'GAUCHE').toList()
      ..sort((a, b) => a.colonne.compareTo(b.colonne));
    final droite = sieges.where((s) => s.cote != 'GAUCHE').toList()
      ..sort((a, b) => a.colonne.compareTo(b.colonne));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (final s in gauche)
            _SeatBox(siege: s, selected: s.id == selectedId, onTap: onTap),
          const SizedBox(width: 26), // couloir
          for (final s in droite)
            _SeatBox(siege: s, selected: s.id == selectedId, onTap: onTap),
        ],
      ),
    );
  }
}

class _SeatBox extends StatelessWidget {
  const _SeatBox({
    required this.siege,
    required this.selected,
    required this.onTap,
  });

  final Siege siege;
  final bool selected;
  final void Function(Siege siege) onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final libre = siege.estLibre;

    late final Color bg;
    late final Color fg;
    late final Color border;
    if (selected) {
      bg = scheme.primary;
      fg = scheme.onPrimary;
      border = scheme.primary;
    } else if (!libre) {
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant.withValues(alpha: 0.6);
      border = scheme.outlineVariant;
    } else if (siege.revendu) {
      bg = scheme.surface;
      fg = scheme.tertiary;
      border = scheme.tertiary;
    } else {
      bg = scheme.surface;
      fg = scheme.onSurface;
      border = scheme.outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: libre ? () => onTap(siege) : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${siege.numero}',
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  decoration:
                      libre ? null : TextDecoration.lineThrough,
                ),
              ),
              if (siege.conflit)
                Positioned(
                  top: 2,
                  right: 2,
                  child: Icon(Icons.warning_amber_rounded,
                      size: 12, color: scheme.error),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget item(Color color, String label, {bool outline = false}) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: outline ? scheme.surface : color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color, width: 1.5),
              ),
            ),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        );

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        item(scheme.outline, 'Libre', outline: true),
        item(scheme.primary, 'Choisi'),
        item(scheme.outlineVariant, 'Occupé'),
        item(scheme.tertiary, 'Revendu', outline: true),
      ],
    );
  }
}
