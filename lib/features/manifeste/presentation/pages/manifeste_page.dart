import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../data/models/passager_manifeste.dart';
import '../providers/manifeste_providers.dart';

/// Manifeste des passagers à bord d'un voyage : liste nominative (siège, client,
/// trajet) pour le contrôle. Réservé au commercial du voyage.
class ManifestePage extends ConsumerWidget {
  const ManifestePage({super.key, required this.voyageId});

  final int voyageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passagers = ref.watch(manifesteProvider(voyageId));

    return Scaffold(
      appBar: AppBar(title: const Text('Manifeste')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(manifesteProvider(voyageId));
          await ref.read(manifesteProvider(voyageId).future);
        },
        child: AsyncValueWidget(
          value: passagers,
          onRetry: () => ref.invalidate(manifesteProvider(voyageId)),
          data: (list) {
            if (list.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                AppEmptyView(
                  icon: Icons.people_outline,
                  message: 'Aucun passager sur ce voyage.',
                ),
              ]);
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: list.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) return _Compteur(nb: list.length);
                return _PassagerTile(passager: list[i - 1]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({required this.nb});

  final int nb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      child: Text(
        '$nb passager${nb > 1 ? 's' : ''} à bord',
        style:
            theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _PassagerTile extends StatelessWidget {
  const _PassagerTile({required this.passager});

  final PassagerManifeste passager;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: scheme.primaryContainer,
          child: Text('${passager.siegeNumero ?? '?'}',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer)),
        ),
        title: Text(passager.clientAffiche,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${passager.trajet}\n${passager.codeticket ?? ''}'),
        isThreeLine: true,
        trailing: _CanalBadge(aBord: passager.aBord),
      ),
    );
  }
}

class _CanalBadge extends StatelessWidget {
  const _CanalBadge({required this.aBord});

  final bool aBord;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = aBord ? scheme.primary : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        aBord ? 'À bord' : 'Guichet',
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
