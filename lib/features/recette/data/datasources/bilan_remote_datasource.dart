import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/bilan_commercial.dart';

/// Accès HTTP à MON bilan de vendeur (`GET /api/commercial/me`).
///
/// Aucun identifiant de commercial n'est envoyé : le serveur lit l'acteur du
/// jeton. Il n'y a donc rien à falsifier depuis l'appareil — et rien à tenir à
/// jour ici le jour où le vendeur change de gare ou de compagnie.
class BilanRemoteDataSource {
  BilanRemoteDataSource(this._dio);

  final Dio _dio;

  /// [debut] et [fin] au format `AAAA-MM-JJ`. Omis, le serveur retient le MOIS
  /// COURANT ENTIER — c'est sa convention pour tous les écrans de période, pas
  /// une valeur choisie ici.
  Future<BilanCommercial> bilan({String? debut, String? fin}) async {
    try {
      final res = await _dio.get<dynamic>(
        '/api/commercial/me',
        queryParameters: {'debut': ?debut, 'fin': ?fin},
      );
      final data = res.data;
      if (data is! Map) {
        throw const ApiException('Réponse inattendue du serveur.');
      }

      return BilanCommercial.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
