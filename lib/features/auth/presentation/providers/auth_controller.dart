import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/auth/token_store.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';

part 'auth_controller.freezed.dart';

/// État global d'authentification.
/// - `unknown` : au lancement, tant qu'on n'a pas tranché (splash) ;
/// - `authenticated` : session valide (profil chargé) ;
/// - `unauthenticated` : à connecter.
enum AuthStatus { unknown, authenticated, unauthenticated }

@freezed
abstract class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    AuthUser? user,
    @Default(false) bool submitting,
    String? error,
  }) = _AuthState;

  bool get isAuthenticated => status == AuthStatus.authenticated;
}

/// Pilote l'authentification : bootstrap (auto-login), connexion, déconnexion,
/// et fin de session forcée (signalée par l'AuthInterceptor).
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    _bootstrap();
    return const AuthState();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);
  TokenStore get _store => ref.read(tokenStoreProvider);

  /// Au démarrage : s'il existe un refresh token, on tente de recharger le profil
  /// (l'intercepteur rafraîchit le token d'accès si besoin) → auto-login.
  Future<void> _bootstrap() async {
    if (!await _store.hasSession()) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await _repo.fetchProfile();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on ApiException catch (e) {
      /*
        UNE PANNE DE RÉSEAU N'EST PAS UNE SESSION PERDUE. Purger les jetons ici renvoyait le vendeur
        à l'écran de connexion au premier redémarrage hors couverture — et l'y bloquait, avec ses
        ventes encaissées prisonnières d'une file qu'il ne pouvait plus atteindre. On ne purge que
        lorsque le SERVEUR a répondu que la session ne vaut plus rien.
      */
      if (!e.estHorsLigne) await _store.clear();
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(submitting: true, error: null);
    try {
      final tokens = await _repo.login(email.trim(), password);
      await _store.save(token: tokens.token, refreshToken: tokens.refreshToken);
      final user = await _repo.fetchProfile();
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        submitting: false,
        error: null,
      );
    } on ApiException catch (e) {
      await _store.clear();
      state = state.copyWith(submitting: false, error: e.message);
    }
  }

  Future<void> logout() async {
    final refresh = await _store.readRefreshToken();
    if (refresh != null) await _repo.logout(refresh);
    await _store.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Session définitivement perdue (refresh impossible) : l'AuthInterceptor a déjà
  /// purgé les jetons ; on renvoie l'utilisateur vers la connexion.
  void onSessionExpired() {
    if (state.status == AuthStatus.unauthenticated) return;
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
