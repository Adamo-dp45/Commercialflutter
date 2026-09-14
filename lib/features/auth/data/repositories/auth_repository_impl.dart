import '../../../../core/auth/token_store.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_tokens.dart';
import '../models/auth_user.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._store);

  final AuthRemoteDataSource _remote;
  final TokenStore _store;

  @override
  Future<AuthTokens> login(String email, String password) =>
      _remote.login(email, password);

  /// Le profil vient du serveur, et s'y garde en copie.
  ///
  /// HORS LIGNE, la copie rouvre la session telle qu'elle était — permissions comprises. Sans elle,
  /// un téléphone qui redémarre en route renvoyait le vendeur à l'écran de connexion, où il ne
  /// pouvait rien faire : ni vendre, ni même consulter la file de ses ventes non remontées.
  @override
  Future<AuthUser> fetchProfile() async {
    try {
      final profil = await _remote.me();
      await _store.saveProfil(profil);

      return AuthUser.fromJson(profil);
    } on ApiException catch (e) {
      if (!e.estHorsLigne) rethrow;

      final copie = await _store.readProfil();
      if (copie == null) rethrow;

      return AuthUser.fromJson(copie);
    }
  }

  @override
  Future<void> logout(String refreshToken) => _remote.logout(refreshToken);
}
