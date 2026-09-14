import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../offline/offline_providers.dart';

/// Dit au vendeur, en permanence, ce qui n'est pas encore remonté.
///
/// C'est la contrepartie du choix fait côté serveur : une vente hors ligne est ACCEPTÉE même si le
/// siège a été vendu ailleurs entre-temps, et c'est l'éviction qui tranchera. Le vendeur doit donc
/// pouvoir constater ce qui reste en attente — un compteur muet transformerait une file bloquée en
/// mauvaise surprise à la clôture.
///
/// Ne s'affiche que lorsqu'il y a quelque chose à dire : rien en attente et réseau présent, le
/// bandeau disparaît.
class BandeauHorsLigne extends ConsumerWidget {
  const BandeauHorsLigne({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enAttente = ref.watch(operationsEnAttenteProvider).asData?.value ?? 0;
    final reseau = ref.watch(reseauDisponibleProvider).asData?.value ?? true;

    if (enAttente == 0 && reseau) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final (couleur, icone, texte) = switch ((reseau, enAttente)) {
      (false, 0) => (
          theme.colorScheme.outline,
          Icons.cloud_off_outlined,
          'Hors ligne — les ventes seront enregistrées et remontées au retour du réseau',
        ),
      (false, final n) => (
          theme.colorScheme.error,
          Icons.cloud_off_outlined,
          'Hors ligne — $n ${_operation(n)} en attente',
        ),
      (true, final n) => (
          theme.colorScheme.primary,
          Icons.cloud_sync_outlined,
          '$n ${_operation(n)} en cours de remontée…',
        ),
    };

    return Material(
      color: couleur.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icone, size: 18, color: couleur),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                texte,
                style: theme.textTheme.bodySmall?.copyWith(color: couleur),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _operation(int n) => n > 1 ? 'opérations' : 'opération';
}
