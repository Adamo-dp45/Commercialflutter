import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/offline/vidange_automatique.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Racine de l'application : thème, localisation (fr) et navigation (go_router
/// piloté par l'état d'authentification).
class CommercialApp extends ConsumerWidget {
  const CommercialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Monté à la racine, et seulement là : la file doit repartir au retour du réseau quel que soit
    // l'écran affiché — y compris si le vendeur est resté sur son tunnel de vente.
    ref.watch(vidangeAutomatiqueProvider);

    return MaterialApp.router(
      title: 'Espace commercial',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      /*
          LA BARRE DE NAVIGATION DU TÉLÉPHONE MANGEAIT LE BAS DES ÉCRANS (19/10/2026).

          Android dessine l'application bord à bord : le contenu passe SOUS la barre système. Avec
          la navigation par gestes, le trait fin ne gêne personne ; avec les TROIS TOUCHES, ce sont
          48 dp opaques posés sur le bas de l'écran — assez pour recouvrir « Le car est arrivé à … »,
          c'est-à-dire le geste que le vendeur fait à chaque gare.

          Le correctif est posé ICI, à la racine, et pas écran par écran : les neuf 'Scaffold' de
          l'application ont le même bas à protéger, et un dixième écrit demain l'aurait oublié.
          Seul le BAS est pris en charge — le haut reste l'affaire des 'AppBar', qui le gèrent déjà.

          Sans effet secondaire sur le clavier : à son ouverture, le système bascule la hauteur de
          'padding' vers 'viewInsets', et 'SafeArea' cesse donc d'en tenir compte. Les 'SafeArea'
          déjà posés dans la connexion et la vente deviennent neutres — l'encart est consommé une
          seule fois, jamais deux.
      */
      builder: (context, child) => SafeArea(
        top: false,
        left: false,
        right: false,
        child: child ?? const SizedBox.shrink(),
      ),
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
