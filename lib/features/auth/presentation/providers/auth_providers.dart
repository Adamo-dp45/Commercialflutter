import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/token_store.dart';
import '../../../../core/network/auth_interceptor.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';

/// Coffre des jetons (secure storage).
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

/// Dio « nu » (sans intercepteur d'auth) : refresh du token + rejeu de la requête,
/// sans risque de ré-entrance.
final refreshDioProvider = Provider<Dio>((ref) {
  final dio = createDio();
  ref.onDispose(dio.close);
  return dio;
});

/// Dio applicatif PARTAGÉ par toutes les features : porte l'AuthInterceptor
/// (Bearer + refresh 401). `onSessionExpired` est lu paresseusement pour éviter
/// tout cycle d'initialisation avec l'AuthController.
final dioProvider = Provider<Dio>((ref) {
  final dio = createDio(
    interceptors: [
      AuthInterceptor(
        tokenStore: ref.watch(tokenStoreProvider),
        refreshDio: ref.watch(refreshDioProvider),
        onSessionExpired: () =>
            ref.read(authControllerProvider.notifier).onSessionExpired(),
      ),
    ],
  );
  ref.onDispose(dio.close);
  return dio;
});

final _authRemoteProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(_authRemoteProvider)),
);

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
