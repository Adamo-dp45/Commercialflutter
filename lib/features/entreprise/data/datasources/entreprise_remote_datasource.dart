import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/entreprise.dart';

/// Accès HTTP à la compagnie du commercial connecté (`/api/me/entreprise`).
class EntrepriseRemoteDataSource {
  EntrepriseRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Entreprise> moi() async {
    try {
      final res = await _dio.get<Map<String, dynamic>>('/api/me/entreprise');
      return Entreprise.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
