import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/voyage_commercial.dart';

/// Accès HTTP à l'espace commercial. Le Bearer est ajouté par l'AuthInterceptor.
///
/// Les PATCH d'API Platform exigent `Content-Type: application/merge-patch+json`
/// (le défaut `application/json` est refusé) — d'où l'override par requête.
class VoyageRemoteDataSource {
  VoyageRemoteDataSource(this._dio);

  final Dio _dio;

  static final _mergePatch =
      Options(contentType: 'application/merge-patch+json');

  /// `GET /api/voyages/me/commercial` → mes voyages actifs.
  Future<List<VoyageCommercial>> mesVoyages() async {
    try {
      final res = await _dio.get<dynamic>('/api/voyages/me/commercial');
      final data = res.data;
      final list = (data is Map ? data['voyages'] : data) ?? const [];
      if (list is! List) return const [];
      return list
          .map((e) => VoyageCommercial.fromJson(_asMap(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// `PATCH /api/voyages/{id}/avancer` : déclare que le car a atteint la gare [gareId].
  Future<void> avancer({required int voyageId, required int gareId}) async {
    try {
      await _dio.patch<dynamic>(
        '/api/voyages/$voyageId/avancer',
        data: {'gare': '/api/gares/$gareId'},
        options: _mergePatch,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// `PATCH /api/voyages/{id}/repartir` : le car repart de sa position courante.
  Future<void> repartir(int voyageId) async {
    try {
      await _dio.patch<dynamic>(
        '/api/voyages/$voyageId/repartir',
        data: const <String, dynamic>{},
        options: _mergePatch,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw const ApiException('Réponse inattendue du serveur.');
  }
}
