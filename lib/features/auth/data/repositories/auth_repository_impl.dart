import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<AuthTokens> login(String email, String password) =>
      _remote.login(email, password);

  @override
  Future<AuthUser> fetchProfile() => _remote.me();

  @override
  Future<void> logout(String refreshToken) => _remote.logout(refreshToken);
}
