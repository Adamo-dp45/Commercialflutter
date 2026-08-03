/// Configuration applicative résolue au build via `--dart-define`.
///
/// Exemple :
/// ```
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
/// ```
///
/// - [apiBaseUrl] : racine du backend Symfony/API Platform (sans `/api`).
///   Par défaut `10.0.2.2:8000` = l'hôte local vu depuis l'émulateur Android.
///
/// Contrairement à l'app client, il n'y a PAS de `?slug=` : le commercial est
/// authentifié et son périmètre entreprise découle de son compte.
class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
