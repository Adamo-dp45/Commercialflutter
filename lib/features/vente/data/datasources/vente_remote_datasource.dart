import 'package:dio/dio.dart';

import '../../../../core/models/bagage_cree.dart';
import '../../../../core/network/api_exception.dart';
import '../models/siege.dart';
import '../models/ticket_vendu.dart';

/// Accès HTTP à la vente à bord (sièges, tarif, émission du billet, bagage).
/// Le Bearer est ajouté par l'AuthInterceptor ; le backend force la gare de
/// montée à la position du car et rattache le commercial (cf. TicketProcessor).
class VenteRemoteDataSource {
  VenteRemoteDataSource(this._dio);

  final Dio _dio;

  /// Plan des sièges du car, avec l'état PAR TRONÇON (montée → descente).
  Future<List<Siege>> sieges({
    required int carId,
    required int voyageId,
    required int monteeId,
    required int descenteId,
  }) async {
    try {
      final res = await _dio.get<dynamic>('/api/sieges', queryParameters: {
        'car': '/api/cars/$carId',
        'voyage': voyageId,
        'montee': monteeId,
        'descente': descenteId,
      });
      final list = res.data;
      if (list is! List) return const [];
      return list
          .map((e) => Siege.fromJson(_asMap(e)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Tarif (FCFA) du couple de gares dans la grille GLOBALE de l'entreprise.
  /// `null` si aucun tarif n'est défini pour ce trajet.
  Future<int?> tarif({required int monteeId, required int descenteId}) async {
    try {
      final res = await _dio.get<dynamic>('/api/tarifs', queryParameters: {
        'garedepart.id': monteeId,
        'garearrivee.id': descenteId,
      });
      final list = res.data;
      if (list is List && list.isNotEmpty) {
        final montant = _asMap(list.first)['montant'];
        if (montant is num) return montant.toInt();
      }
      return null;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Émet le billet. La gare de montée = position du car (forcée côté serveur) ;
  /// la descente est un arrêt en aval. Références sous forme d'IRI.
  ///
  /// Remise optionnelle : [remiseType] = 'POURCENTAGE' | 'MONTANT', [remiseValeur]
  /// en % ou FCFA. Le serveur calcule le prix net et applique le plafond
  /// (config remise de la compagnie) — une remise trop élevée est refusée (400).
  Future<TicketVendu> vendreTicket({
    required int voyageId,
    required int siegeId,
    required int monteeGareId,
    required int descenteGareId,
    String? nom,
    String? contact,
    String? remiseType,
    int? remiseValeur,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>('/api/tickets', data: {
        'voyage': '/api/voyages/$voyageId',
        'siege': '/api/sieges/$siegeId',
        'gare': '/api/gares/$monteeGareId',
        'garedescente': '/api/gares/$descenteGareId',
        if (nom != null && nom.trim().isNotEmpty) 'nomclient': nom.trim(),
        if (contact != null && contact.trim().isNotEmpty)
          'contactclient': contact.trim(),
        if (remiseType != null && remiseValeur != null && remiseValeur > 0) ...{
          'remisetype': remiseType,
          'remisevaleur': remiseValeur,
        },
      });
      return TicketVendu.fromJson(res.data ?? const {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Enregistre un bagage rattaché au billet. Par défaut le montant est calculé
  /// côté serveur (grille de poids) ; si [montant] est fourni, il est FORCÉ
  /// (BagageInput.montant). Nécessite la permission `Bagage/CREER`.
  Future<BagageCree> ajouterBagage({
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    try {
      final res = await _dio.post<dynamic>('/api/bagages', data: {
        'ticket': ticketId,
        'nature': nature.trim(),
        'type': type,
        'poids': poids,
        'montant': ?montant,
      });
      return bagageCreeFromJson(res.data);
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
