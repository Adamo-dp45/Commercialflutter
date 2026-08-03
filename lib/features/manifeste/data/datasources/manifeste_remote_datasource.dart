import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/passager_manifeste.dart';

/// Accès HTTP au manifeste nominatif d'un voyage
/// (`GET /api/voyages/{id}/me/manifeste`, réservé au commercial du voyage).
class ManifesteRemoteDataSource {
  ManifesteRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<PassagerManifeste>> manifeste(int voyageId) async {
    try {
      final res =
          await _dio.get<dynamic>('/api/voyages/$voyageId/me/manifeste');
      final data = res.data;
      final list = (data is Map ? data['passagers'] : data) ?? const [];
      if (list is! List) return const [];
      return list
          .map((e) => PassagerManifeste.fromJson(_asMap(e)))
          .toList(growable: false);
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
