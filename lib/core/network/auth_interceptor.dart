// Champs PRIVÉS injectés via des paramètres NOMMÉS (DI lisible) : les formals
// privés nommés (`this._x`) sont interdits en Dart, l'initializer list est donc
// la seule forme possible — on neutralise le lint pour ce seul fichier.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:dio/dio.dart';

import '../auth/token_store.dart';

/// Appelé quand la session est définitivement perdue (refresh impossible) :
/// l'`AuthController` bascule alors sur l'écran de connexion.
typedef SessionExpiredCallback = void Function();

/// Intercepteur d'authentification :
///  1. attache `Authorization: Bearer <token>` à chaque requête (hors endpoints publics) ;
///  2. sur un `401`, tente UN refresh (`/api/token/refresh`) puis REJOUE la requête ;
///  3. si le refresh échoue, purge les jetons et signale la fin de session.
///
/// Les appels de refresh CONCURRENTS sont mutualisés via un [Completer] : plusieurs
/// requêtes qui échouent en même temps ne déclenchent qu'un seul refresh.
///
/// Le refresh ET le rejeu passent par un Dio SÉPARÉ ([_refreshDio], sans cet
/// intercepteur) pour éviter toute ré-entrance / boucle.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStore tokenStore,
    required Dio refreshDio,
    required SessionExpiredCallback onSessionExpired,
  })  : _store = tokenStore,
        _refreshDio = refreshDio,
        _onSessionExpired = onSessionExpired;

  final TokenStore _store;
  final Dio _refreshDio;
  final SessionExpiredCallback _onSessionExpired;

  /// Endpoints qui ne portent JAMAIS de Bearer et ne déclenchent pas de refresh.
  static const _publicPaths = ['/api/login_check', '/api/token/refresh'];

  static const _retriedFlag = '__auth_retried__';

  Completer<String?>? _refreshing;

  bool _isPublic(String path) => _publicPaths.any(path.contains);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await _store.readToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final is401 = err.response?.statusCode == 401;
    final alreadyRetried = options.extra[_retriedFlag] == true;

    // On ne rejoue que le 401 d'une requête AUTHENTIFIÉE, une seule fois.
    if (!is401 || _isPublic(options.path) || alreadyRetried) {
      return handler.next(err);
    }

    final newToken = await _refresh();
    if (newToken == null) {
      _onSessionExpired();
      return handler.next(err);
    }

    try {
      options.extra[_retriedFlag] = true;
      options.headers['Authorization'] = 'Bearer $newToken';
      final response = await _refreshDio.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Rafraîchit le token d'accès, en mutualisant les appels concurrents.
  /// Retourne le nouveau token, ou `null` si le refresh est impossible.
  Future<String?> _refresh() {
    final pending = _refreshing;
    if (pending != null) return pending.future;

    final completer = Completer<String?>();
    _refreshing = completer;

    Future(() async {
      try {
        final refresh = await _store.readRefreshToken();
        if (refresh == null) {
          completer.complete(null);
          return;
        }
        final res = await _refreshDio.post<Map<String, dynamic>>(
          '/api/token/refresh',
          data: {'refresh_token': refresh},
        );
        final data = res.data ?? const {};
        final token = data['token'] as String?;
        final newRefresh = data['refresh_token'] as String?;
        if (token == null) {
          await _store.clear();
          completer.complete(null);
          return;
        }
        await _store.save(token: token, refreshToken: newRefresh ?? refresh);
        completer.complete(token);
      } catch (_) {
        await _store.clear();
        completer.complete(null);
      } finally {
        _refreshing = null;
      }
    });

    return completer.future;
  }
}
