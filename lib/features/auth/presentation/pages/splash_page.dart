import 'package:flutter/material.dart';

/// Écran d'attente affiché tant que l'état d'authentification n'est pas tranché
/// (auto-login au lancement). Le routeur redirige ensuite vers la connexion ou
/// l'accueil.
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bus_rounded, size: 56, color: scheme.primary),
            const SizedBox(height: 20),
            const SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(strokeWidth: 2.6),
            ),
          ],
        ),
      ),
    );
  }
}
