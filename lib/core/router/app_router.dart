import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/providers/auth_controller.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/gestion/presentation/pages/mes_ventes_page.dart';
import '../../features/manifeste/presentation/pages/manifeste_page.dart';
import '../../features/recette/presentation/pages/ma_recette_page.dart';
import '../../features/vente/presentation/pages/vente_page.dart';
import '../../features/voyages/presentation/pages/home_page.dart';
import '../../features/voyages/presentation/pages/voyage_detail_page.dart';

/// Chemins de l'application (évite les URLs en dur dispersées).
class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const maRecette = '/ma-recette';

  static String voyageDetail(int id) => '/voyage/$id';
  static String vente(int id) => '/voyage/$id/vente';
  static String mesVentes(int id) => '/voyage/$id/ventes';
  static String manifeste(int id) => '/voyage/$id/manifeste';
}

/// Routeur go_router, RÉACTIF à l'état d'authentification :
///  - `unknown`         → splash (auto-login en cours) ;
///  - `unauthenticated` → écran de connexion ;
///  - `authenticated`   → l'app.
///
/// Construit une seule fois : les changements d'état passent par le
/// `refreshListenable`, sans recréer le routeur.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(
    authControllerProvider.select((s) => s.status),
    (_, _) => refresh.value++,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider).status;
      final loc = state.matchedLocation;

      if (status == AuthStatus.unknown) {
        return loc == AppRoutes.splash ? null : AppRoutes.splash;
      }
      if (status == AuthStatus.unauthenticated) {
        return loc == AppRoutes.login ? null : AppRoutes.login;
      }
      // authenticated : on ne reste pas sur splash / login
      if (loc == AppRoutes.login || loc == AppRoutes.splash) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.maRecette,
        builder: (context, state) => const MaRecettePage(),
      ),
      GoRoute(
        path: '/voyage/:id',
        builder: (context, state) => VoyageDetailPage(
          voyageId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
        routes: [
          GoRoute(
            path: 'vente',
            builder: (context, state) => VentePage(
              voyageId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: 'ventes',
            builder: (context, state) => MesVentesPage(
              voyageId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
          GoRoute(
            path: 'manifeste',
            builder: (context, state) => ManifestePage(
              voyageId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
            ),
          ),
        ],
      ),
    ],
  );
});
