/// Couple de jetons renvoyé par `/api/login_check` et `/api/token/refresh`.
///
/// Objet simple (pas de codegen) : purement transitoire entre la source
/// distante et le `TokenStore`.
class AuthTokens {
  const AuthTokens({required this.token, required this.refreshToken});

  final String token;
  final String refreshToken;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        token: json['token'] as String,
        refreshToken: json['refresh_token'] as String,
      );
}
