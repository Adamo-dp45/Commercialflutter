import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/router/app_router.dart';
import '../providers/voyage_providers.dart';
import '../widgets/voyage_card.dart';

/// Accueil : la liste de mes voyages actifs, avec accès au profil / déconnexion.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(mesVoyagesProvider);
    await ref.read(mesVoyagesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voyages = ref.watch(mesVoyagesProvider);
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes voyages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            tooltip: 'Ma recette',
            onPressed: () => context.push(AppRoutes.maRecette),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') {
                ref.read(authControllerProvider.notifier).logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                enabled: false,
                child: Text(user?.displayName ?? 'Commercial'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Se déconnecter'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: AsyncValueWidget(
          value: voyages,
          onRetry: () => ref.invalidate(mesVoyagesProvider),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                // ListView (et non Center) pour garder le pull-to-refresh actif.
                children: const [
                  SizedBox(height: 120),
                  AppEmptyView(
                    icon: Icons.directions_bus_outlined,
                    message: 'Aucun voyage en cours.\n'
                        'Vos voyages apparaîtront ici dès qu\'une gare vous '
                        'désignera commercial à bord.',
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final v = list[i];
                return VoyageCard(
                  voyage: v,
                  onTap: () => context.push(AppRoutes.voyageDetail(v.id)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
