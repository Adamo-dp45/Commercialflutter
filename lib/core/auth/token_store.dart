import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Coffre des jetons JWT, chiffré au niveau du système (Keychain iOS /
/// EncryptedSharedPreferences Android). Ne stocke QUE les jetons ; le profil
/// utilisateur est rechargé depuis `/api/me`.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const _kToken = 'jwt_token';
  static const _kRefresh = 'jwt_refresh_token';

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

  Future<void> clear() async {
    await _storage.delete(key: _kToken);
    await _storage.delete(key: _kRefresh);
  }
}
