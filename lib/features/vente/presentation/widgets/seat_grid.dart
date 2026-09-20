import 'package:flutter/material.dart';

import '../../data/models/siege.dart';

/// Plan de sièges du car pour le tronçon en cours. Disposition « bus » simple :
/// par rangée, sièges de gauche · couloir · sièges de droite. Les sièges occupés
/// sont grisés ; le siège choisi est mis en avant ; un siège « revendu » ou en
/// « conflit » (billet évincé) est signalé sans bloquer la vente.
///
/// Un siège « vendu par une gare en aval » est signalé en AMBRE avec une flèche
/// descendante, et reste PARFAITEMENT VENDABLE : la priorité amont est la règle,
/// on prévient sans interdire. Le repère existe pour que le vendeur qui a le
/// choix prenne un autre siège — la plupart des évictions ne viennent pas d'un
/// car plein, mais d'un siège pris au hasard alors qu'un autre était libre.
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
        // Légende ADAPTATIVE sur l'alerte : elle n'a de sens que le jour où un siège la porte, et
        // une ligne de plus sur un écran de téléphone se paie.
        _Legend(avecAval: sieges.any((s) => s.alerteAval)),
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
    final aval = siege.alerteAval;

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
    } else if (aval) {
      // Passe AVANT « revendu » : la revente est un constat, l'alerte est une décision à prendre
      // maintenant. Teinte de fond assumée — il faut que l'œil s'y arrête avant le doigt.
      bg = _ambre.withValues(alpha: 0.12);
      fg = _ambreTexte;
      border = _ambre;
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
      child: Tooltip(
        // Un appui long donne le détail : qui monte, d'où à où. Sur un téléphone, c'est le seul
        // endroit où loger ce texte sans encombrer un plan de cinquante cases.
        message: aval
            ? 'Siège ${siege.numero} — déjà vendu par une gare en aval '
                '(${siege.resumeAval}). Vous restez prioritaire, mais ce passager ne montera pas.'
            : 'Siège ${siege.numero} — ${libre ? 'libre' : 'occupé'}',
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
                // Flèche descendante = « vendu plus bas sur la ligne ». En bas à gauche : le coin
                // haut-droit appartient déjà au repère de conflit, et les deux peuvent coexister.
                if (aval)
                  const Positioned(
                    bottom: 2,
                    left: 2,
                    child: Icon(Icons.south_rounded, size: 12, color: _ambre),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/*
  Ambre EN DUR, et non une couleur du thème : les rôles de `ColorScheme` sont déjà pris — `error`
  par le conflit, `tertiary` par la revente, `primary` par la sélection. Reprendre l'un d'eux
  rendrait deux états indiscernables sur le plan. C'est la même teinte que le repère du web
  (`amber-500`), pour qu'un vendeur passant du guichet au téléphone reconnaisse le signal.
*/
const _ambre = Color(0xFFF59E0B);
const _ambreTexte = Color(0xFFB45309);

class _Legend extends StatelessWidget {
  const _Legend({this.avecAval = false});

  final bool avecAval;

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
        if (avecAval) item(_ambre, 'Vendu en aval — ce passager sera évincé', outline: true),
      ],
    );
  }
}
