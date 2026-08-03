import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Options de base communes à toutes les instances Dio de l'app.
///
/// `Accept: application/json` force API Platform à renvoyer du JSON simple (pas
/// de Hydra). Les statuts d'erreur (>= 400) sont laissés remonter en
/// [DioException] pour être traduits en `ApiException` par la couche data.
BaseOptions _baseOptions() => BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      validateStatus: (status) => status != null && status < 400,
    );

/// Fabrique une instance [Dio] avec les [interceptors] fournis.
///
/// Deux usages :
///  - un Dio « nu » (sans intercepteur) sert au refresh du token et au rejeu ;
///  - le Dio applicatif reçoit l'`AuthInterceptor` (cf. providers d'auth).
///
/// Un intercepteur de log n'est actif qu'en mode debug.
Dio createDio({List<Interceptor> interceptors = const []}) {
  final dio = Dio(_baseOptions());
  dio.interceptors.addAll(interceptors);

  assert(() {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => developer.log(o.toString(), name: 'dio'),
      ),
    );
    return true;
  }());

  return dio;
}
