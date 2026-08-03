import 'package:dio/dio.dart';

import '../../../../core/models/bagage_cree.dart';
import '../../../../core/network/api_exception.dart';
import '../models/bagage_detail.dart';
import '../models/mes_ventes.dart';
import '../models/ticket_detail.dart';

/// Accès HTTP à la gestion des ventes du commercial : relire ses billets/bagages
/// d'un voyage (pour réimprimer / corriger) et les modifier selon ses droits.
/// La lecture passe par l'endpoint dédié `/api/voyages/{id}/me/ventes` (scopé au
/// commercial, hors périmètre gare) ; les PATCH d'item exigent
/// `application/merge-patch+json`.
class GestionRemoteDataSource {
  GestionRemoteDataSource(this._dio);

  final Dio _dio;

  static final _mergePatch =
      Options(contentType: 'application/merge-patch+json');

  /// Mes billets + bagages sur un voyage.
  Future<MesVentes> ventesDuVoyage(int voyageId) async {
    try {
      final res = await _dio.get<dynamic>('/api/voyages/$voyageId/me/ventes');
      final data = res.data;
      final map = data is Map ? data : const <String, dynamic>{};
      final tickets = (map['tickets'] as List? ?? const [])
          .map((e) => TicketDetail.fromJson(_asMap(e)))
          .toList(growable: false);
      final bagages = (map['bagages'] as List? ?? const [])
          .map((e) => BagageDetail.fromJson(_asMap(e)))
          .toList(growable: false);
      return MesVentes(tickets: tickets, bagages: bagages);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Corrige l'identité client d'un billet (groupe `write:Ticket:update`).
  Future<void> modifierClientTicket({
    required int ticketId,
    String? nom,
    String? contact,
  }) async {
    try {
      await _dio.patch<dynamic>(
        '/api/tickets/$ticketId',
        data: {
          'nomclient': nom?.trim().isEmpty ?? true ? null : nom!.trim(),
          'contactclient':
              contact?.trim().isEmpty ?? true ? null : contact!.trim(),
        },
        options: _mergePatch,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Modifie un bagage (BagageInput). `ticket` est obligatoire côté DTO : on le
  /// renvoie tel quel. [montant] renseigné → montant forcé.
  Future<void> modifierBagage({
    required int bagageId,
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    try {
      await _dio.patch<dynamic>(
        '/api/bagages/$bagageId',
        data: {
          'ticket': ticketId,
          'nature': nature.trim(),
          'type': type,
          'poids': poids,
          'montant': ?montant,
        },
        options: _mergePatch,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Le passager descend en route : enregistre la gare de descente RÉELLE
  /// (= position courante du car pour le commercial) → libère le siège pour
  /// une revente en aval.
  Future<void> descendreTicket({
    required int ticketId,
    required int gareId,
  }) async {
    try {
      await _dio.patch<dynamic>(
        '/api/tickets/$ticketId/descendre',
        data: {'gare': '/api/gares/$gareId'},
        options: _mergePatch,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Ajoute un bagage à un billet DÉJÀ vendu (montant forcé si [montant] fourni).
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

  /// Annule un bagage encore ENREGISTRE (non embarqué).
  Future<void> annulerBagage(int bagageId) async {
    try {
      await _dio.patch<dynamic>(
        '/api/bagages/$bagageId/annuler',
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
