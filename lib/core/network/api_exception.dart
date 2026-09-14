import 'package:dio/dio.dart';

/// Exception métier normalisée, exposée à la couche présentation.
///
/// Elle traduit une [DioException] (réseau/HTTP bas niveau) en un message
/// affichable et un éventuel code HTTP, pour que l'UI n'ait jamais à connaître
/// Dio. La fabrique [ApiException.fromDio] extrait le message renvoyé par le
/// backend (API Platform) quand il existe.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.estHorsLigne = false});

  final String message;
  final int? statusCode;

  /// Le serveur n'a pas répondu — coupure réseau ou délai dépassé, PAS un refus métier.
  ///
  /// Sans ce drapeau, la seule façon de distinguer « hors ligne » de « erreur serveur » était de
  /// comparer des chaînes de caractères. C'est lui qui décide si une vente part en file d'attente
  /// ou si l'on affiche une erreur au vendeur.
  final bool estHorsLigne;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;
  bool get isValidation => statusCode == 400 || statusCode == 422;

  factory ApiException.fromDio(DioException e) {
    // Pas de réponse du serveur : problème réseau / délai dépassé.
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return const ApiException(
        'Connexion trop lente. Vérifiez votre réseau et réessayez.',
        estHorsLigne: true,
      );
    }
    if (e.type == DioExceptionType.connectionError || e.response == null) {
      return const ApiException(
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
        estHorsLigne: true,
      );
    }

    final status = e.response?.statusCode;
    if (status == 401) {
      return ApiException(
        _extractMessage(e.response?.data) ?? 'Identifiants invalides ou session expirée.',
        statusCode: 401,
      );
    }
    if (status == 429) {
      return const ApiException(
        'Trop de tentatives. Patientez un instant avant de réessayer.',
        statusCode: 429,
      );
    }

    return ApiException(
      _extractMessage(e.response?.data) ?? 'Une erreur est survenue ($status).',
      statusCode: status,
    );
  }

  /// Extrait un message lisible d'une réponse d'erreur API Platform, quel que
  /// soit le format (`hydra:description`, `description`, `detail`, `message`…).
  static String? _extractMessage(dynamic data) {
    if (data is String && data.trim().isNotEmpty) return data;
    if (data is Map) {
      for (final key in const [
        'hydra:description',
        'description',
        'detail',
        'message',
        'error',
      ]) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    return null;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
