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
        /*
          LÉGENDE ADAPTATIVE, et sur LES TROIS repères — pas seulement l'alerte aval. Une ligne de
          plus sur un écran de téléphone se paie, donc chacun n'apparaît que le jour où un siège le
          porte RÉELLEMENT.

          !! LA CONDITION DOIT ÊTRE CELLE DU RENDU, pas celle de la donnée. Pour la REVENTE, les
          deux coïncident désormais : le repère se voit sur un siège occupé comme sur un siège
          libre, donc `s.revendu` suffit — c'est aussi la condition du plan du web. Elle ne le
          suffisait pas tant que la revente ne se peignait que sur un siège libre : la ligne de
          légende restait alors absente d'un plan qui portait pourtant des sièges revendus.
        */
        _Legend(
          avecRevendu: sieges.any((s) => s.revendu),
          // La revente se peint en DEUX variantes (libre, occupée). La pastille montre celle que
          // ce plan-ci porte réellement : afficher la variante libre devant un plan où tous les
          // sièges revendus sont occupés donnerait à chercher une couleur qui n'y est pas — le
          // défaut même qu'on vient de fermer, à une nuance près.
          revenduOccupe: sieges.any((s) => s.revendu) &&
              !sieges.any((s) => s.revendu && s.estLibre && !s.alerteAval),
          avecAval: sieges.any((s) => s.alerteAval),
          avecConflit: sieges.any((s) => s.conflit),
        ),
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

    final (:bg, :fg, :border) = _apparence(
      scheme,
      selected: selected,
      libre: libre,
      aval: aval,
      revendu: siege.revendu,
    );

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

/// LA couleur d'un état de siège — LE SEUL ENDROIT où elle se décide.
///
/// POURQUOI UNE FONCTION PARTAGÉE : le siège et sa légende se peignaient chacun de leur côté, et
/// ils avaient déjà divergé. La pastille « Occupé » était remplie d'`outlineVariant` quand le siège
/// l'est de `surfaceContainerHighest`, et celle de l'alerte aval n'avait aucun fond alors que le
/// siège en porte un. Une légende qui ne montre pas ce que montre le plan ne se lit pas comme un
/// défaut : elle se lit comme une couleur de plus, et le vendeur cherche un état qui n'existe pas.
///
/// L'ORDRE DES CAS EST LA RÈGLE MÉTIER, pas un détail d'écriture : la sélection d'abord (c'est le
/// geste en cours), l'occupation ensuite (on ne vend pas), puis l'ALERTE AVAL avant la REVENTE —
/// la revente est un constat, l'alerte est une décision à prendre maintenant.
///
/// !! LA REVENTE SE VOIT AUSSI SUR UN SIÈGE OCCUPÉ, et c'est son cas PRINCIPAL (corrigé le
/// 05/11/2026). Un siège revendu porte deux billets sur des tronçons disjoints : dès que l'un des
/// deux recouvre le tronçon affiché, le siège y est OCCUPÉ. En plaçant la revente après
/// l'occupation, le repère ne pouvait se montrer que sur le cas rare — le siège libre pour qui
/// regarde — et la légende qui en dépend ne s'affichait jamais. Le plan du web le peint dans les
/// deux cas (`revendu && isOccupe` y a sa propre règle) : c'est le mobile qui en était resté à une
/// moitié de la règle.
({Color bg, Color fg, Color border}) _apparence(
  ColorScheme scheme, {
  required bool selected,
  required bool libre,
  required bool aval,
  required bool revendu,
}) {
  if (selected) {
    return (bg: scheme.primary, fg: scheme.onPrimary, border: scheme.primary);
  }
  if (!libre && revendu) {
    // Occupé ET revendu : la BORDURE reste celle de la revente — c'est elle qui porte le signal —
    // et le fond dit l'occupation. Les deux informations sont vraies, aucune n'efface l'autre.
    return (
      bg: scheme.tertiaryContainer.withValues(alpha: 0.45),
      fg: scheme.onSurfaceVariant.withValues(alpha: 0.6),
      border: scheme.tertiary.withValues(alpha: 0.55),
    );
  }
  if (!libre) {
    return (
      bg: scheme.surfaceContainerHighest,
      fg: scheme.onSurfaceVariant.withValues(alpha: 0.6),
      border: scheme.outlineVariant,
    );
  }
  if (aval) {
    // Teinte de fond assumée — il faut que l'œil s'y arrête avant le doigt.
    return (
      bg: _ambre.withValues(alpha: 0.12),
      fg: _ambreTexte,
      border: _ambre,
    );
  }
  if (revendu) {
    return (bg: scheme.surface, fg: scheme.tertiary, border: scheme.tertiary);
  }

  return (bg: scheme.surface, fg: scheme.onSurface, border: scheme.outline);
}

/// La légende du plan.
///
/// CHAQUE PASTILLE EST PEINTE PAR `_apparence`, la fonction qui peint les sièges : elle ne décrit
/// donc pas le plan, elle en est faite. C'est la seule façon de garantir qu'elle ne puisse plus
/// annoncer une couleur que le plan n'emploie pas.
class _Legend extends StatelessWidget {
  const _Legend({
    this.avecRevendu = false,
    this.revenduOccupe = false,
    this.avecAval = false,
    this.avecConflit = false,
  });

  final bool avecRevendu;

  /// Vrai quand les sièges revendus de ce plan sont TOUS occupés : la pastille prend alors leur
  /// variante, et non celle du siège revendu libre.
  final bool revenduOccupe;

  final bool avecAval;

  /// Le CONFLIT manquait entièrement à cette légende, alors que le plan pose un triangle rouge sur
  /// les sièges concernés : un repère qui apparaît sans être expliqué fait hésiter le vendeur sur
  /// un siège qu'il a pourtant le droit de vendre.
  final bool avecConflit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget item({
      required String label,
      bool selected = false,
      bool libre = true,
      bool aval = false,
      bool revendu = false,
      Widget? marque,
    }) {
      final a = _apparence(
        scheme,
        selected: selected,
        libre: libre,
        aval: aval,
        revendu: revendu,
      );

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: a.bg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: a.border, width: 1.5),
            ),
            child: marque,
          ),
          const SizedBox(width: 5),
          Text(label, style: theme.textTheme.labelSmall),
        ],
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        item(label: 'Libre'),
        item(label: 'Choisi', selected: true),
        item(label: 'Occupé', libre: false),
        if (avecRevendu)
          item(label: 'Revendu', revendu: true, libre: !revenduOccupe),
        if (avecAval)
          item(
            label: 'Vendu en aval — ce passager sera évincé',
            aval: true,
            // La flèche aussi est sur le siège : l'omettre ici laisserait croire à deux repères.
            marque: const Icon(Icons.south_rounded, size: 11, color: _ambre),
          ),
        if (avecConflit)
          item(
            label: 'Conflit — un billet évincé, passager à reloger',
            marque: Icon(
              Icons.warning_amber_rounded,
              size: 11,
              color: scheme.error,
            ),
          ),
      ],
    );
  }
}
