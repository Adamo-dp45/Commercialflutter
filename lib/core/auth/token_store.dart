import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Coffre de la session, chiffré au niveau du système (Keychain iOS /
/// EncryptedSharedPreferences Android) : les jetons JWT et une copie du profil.
///
/// LE PROFIL Y EST GARDÉ pour la vente hors ligne. Il était auparavant rechargé à chaque démarrage
/// depuis `/api/me` ; un téléphone qui redémarre sans réseau — batterie vide en route — ne pouvait
/// alors plus passer l'écran de connexion, et perdait du même coup l'accès à sa file de ventes non
/// remontées. La copie permet de rouvrir la session telle qu'elle était, avec ses permissions.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _kToken = 'jwt_token';
  static const _kRefresh = 'jwt_refresh_token';
  static const _kProfil = 'profil_json';

  Future<String?> readToken() => _storage.read(key: _kToken);

  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  /// Y a-t-il une session persistée (un refresh token) à tenter au démarrage ?
  Future<bool> hasSession() async => (await readRefreshToken()) != null;

  Future<void> save({
    required String token,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kToken, value: token);
    await _storage.write(key: _kRefresh, value: refreshToken);
  }

  /// Met à jour le seul token d'accès (après un refresh qui ne renouvelle pas
  /// le refresh token).
  Future<void> saveToken(String token) =>
      _storage.write(key: _kToken, value: token);

  /// La dernière réponse de `/api/me`, telle quelle. On garde le JSON BRUT plutôt que l'objet :
  /// les permissions sont aplaties à la lecture depuis `userRoles[]` et ne se re-sérialisent pas.
  Future<Map<String, dynamic>?> readProfil() async {
    final brut = await _storage.read(key: _kProfil);
    if (brut == null) return null;

    try {
      final decode = jsonDecode(brut);

      return decode is Map<String, dynamic> ? decode : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> saveProfil(Map<String, dynamic> profil) =>
      _storage.write(key: _kProfil, value: jsonEncode(profil));

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kProfil);
  }
}
