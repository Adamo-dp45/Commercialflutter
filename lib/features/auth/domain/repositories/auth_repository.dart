import '../../data/models/auth_tokens.dart';
import '../../data/models/auth_user.dart';

/// Contrat d'authentification consommé par la présentation (l'UI ne connaît ni
/// Dio ni la source distante).
abstract interface class AuthRepository {
  Future<AuthTokens> login(String email, String password);

  Future<AuthUser> fetchProfile();

  Future<void> logout(String refreshToken);
}
