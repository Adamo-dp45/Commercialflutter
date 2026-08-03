import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';

/// Accès HTTP brut à l'API d'authentification. Ne fait QUE l'appel + le mapping ;
/// toute [DioException] est convertie en [ApiException].
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  /// `POST /api/login_check` → jetons. `username` = e-mail (cf. `security.yaml`).
  Future<AuthTokens> login(String email, String password) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/login_check',
        data: {'username': email, 'password': password},
      );
      return AuthTokens.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// `GET /api/me` → profil de l'utilisateur courant (Bearer ajouté par l'intercepteur).
  Future<AuthUser> me() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/me');
      return AuthUser.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// `POST /api/token/invalidate` → invalide le refresh token (déconnexion).
  /// Best-effort : un échec réseau ne doit pas empêcher la déconnexion locale.
  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/api/token/invalidate', data: {'refresh_token': refreshToken});
    } on DioException {
      // ignoré : on purge les jetons localement de toute façon
    }
  }
}
