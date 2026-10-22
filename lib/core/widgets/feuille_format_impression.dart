import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pdf/format_impression.dart';
import '../pdf/impression_providers.dart';

/// « MON IMPRIMANTE » — le choix du papier, par appareil (21/10/2026).
///
/// Une feuille et non un écran : le réglage se fait une fois, le jour où le vendeur reçoit son
/// matériel, et n'a pas à occuper une route ni une entrée de navigation. Il reste atteignable
/// depuis le menu du compte, à l'accueil, où l'on cherche ce genre de chose.
///
/// !! PAS DE `RadioListTile` : ses paramètres `groupValue` / `onChanged` sont dépréciés depuis
///    Flutter 3.32 au profit de `RadioGroup`, et l'application tourne sur 3.47. Deux lignes
///    cochables disent la même chose sans dette d'API.
Future<void> ouvrirFeuilleFormatImpression(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const _FeuilleFormatImpression(),
    );

class _FeuilleFormatImpression extends ConsumerWidget {
  const _FeuilleFormatImpression();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actuel = ref.watch(formatImpressionProvider);
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text('Mon imprimante', style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              'Le format du billet imprimé par cet appareil.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          for (final format in FormatImpression.values)
            ListTile(
              leading: Icon(
                format.estLarge ? Icons.receipt_long_outlined : Icons.receipt_outlined,
                color: format == actuel ? scheme.primary : scheme.onSurfaceVariant,
              ),
              title: Text(format.libelle),
              subtitle: Text(format.detail),
              trailing: format == actuel ? Icon(Icons.check, color: scheme.primary) : null,
              selected: format == actuel,
              onTap: () async {
                await ref.read(formatImpressionProvider.notifier).definir(format);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
