import 'package:uuid/uuid.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/offline/base_locale.dart';
import '../../../../core/offline/file_operations.dart';
import '../../../../core/offline/operation_hors_ligne.dart';
import '../../../../core/offline/synchronisateur.dart';
import '../../domain/repositories/voyage_repository.dart';
import '../datasources/voyage_remote_datasource.dart';
import '../models/voyage_commercial.dart';

/// La liste des départs vient du serveur, et s'y garde en copie ; les gestes de progression
/// s'enregistrent en file quand le réseau manque.
///
/// La copie de la liste sert un cas précis : le téléphone qui REDÉMARRE en route — batterie vide,
/// application tuée. Sans elle, l'écran d'accueil est vide, aucun voyage ne s'ouvre, et le vendeur
/// ne peut pas atteindre son tunnel de vente alors que l'instantané qui lui permettrait de vendre
/// est sur l'appareil. La vente hors ligne ne tiendrait que tant que l'application reste allumée.
///
/// Ce que la copie ne prétend pas être : à jour. Recette et places libres datent du dernier
/// chargement avec réseau. La POSITION, elle, est corrigée localement à chaque avance déclarée —
/// c'est la seule donnée dont dépend la suite du travail du vendeur.
class VoyageRepositoryImpl implements VoyageRepository {
  // ignore_for_file: prefer_initializing_formals
  VoyageRepositoryImpl(
    this._remote, {
    FileOperations? file,
    Synchronisateur? synchronisateur,
  })  : _file = file,
        _synchronisateur = synchronisateur;

  final VoyageRemoteDataSource _remote;
  final FileOperations? _file;
  final Synchronisateur? _synchronisateur;

  static const _uuid = Uuid();

  @override
  Future<List<VoyageCommercial>> mesVoyages() async {
    final file = _file;

    try {
      final voyages = await _remote.mesVoyages();
      if (file != null) {
        await file.enregistrerVoyages([for (final v in voyages) v.toJson()]);
      }

      return voyages;
    } on ApiException catch (e) {
      if (!e.estHorsLigne || file == null) rethrow;

      final cache = await file.voyages();
      if (cache.isEmpty) rethrow;

      return [for (final v in cache) VoyageCommercial.fromJson(v)];
    }
  }

  /// Déclare que le car a atteint [gareId].
  ///
  /// Hors ligne, le geste est mis en file ET appliqué au voyage en cache. Les deux comptent : la file
  /// pour que le serveur l'apprenne, le cache pour que le vendeur puisse continuer à travailler —
  /// vendre depuis la nouvelle gare, déclarer l'arrêt suivant — sans attendre le réseau.
  @override
  Future<void> avancer({required int voyageId, required int gareId}) async {
    try {
      await _remote.avancer(voyageId: voyageId, gareId: gareId);
    } on ApiException catch (e) {
      if (!e.estHorsLigne) rethrow;

      await _deposer(
        voyageId: voyageId,
        type: TypeOperation.POSITION,
        payload: {'gare': gareId},
        geste: 'L\'avance de position hors ligne',
      );

      // La position courante détermine tout ce qui suit : destinations vendables, prochain arrêt,
      // droit de vendre. Sans cette correction, le vendeur resterait bloqué à la gare précédente.
      await _file?.modifierVoyageEnCache(voyageId, (voyage) {
        final arrets = (voyage['arrets'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
        final arret = arrets.where((a) => a['id'] == gareId).firstOrNull;

        return {
          ...voyage,
          'garecouranteId': gareId,
          if (arret != null) 'garecouranteLibelle': arret['libelle'],
          /*
            Le car vient d'arriver : il n'est pas encore reparti de cette gare — SAUF au terminus,
            d'où il ne repart pas du tout. La règle est celle du serveur
            ('CommercialEspaceController') : une gare INTERMÉDIAIRE seulement. La proposer au terminus
            offrirait au vendeur un geste que la synchronisation refusera à coup sûr, après lui avoir
            affiché « Départ enregistré ».

            L'origine, que le serveur exclut aussi, n'a pas à être testée ici : une avance va toujours
            vers un arrêt strictement en aval, on ne peut donc jamais y revenir.
          */
          'peutRepartir': !_estTerminus(arrets, gareId),
        };
      });
    }
  }

  /// Déclare que le car a quitté sa position courante.
  ///
  /// La gare n'est pas transmise : le serveur repart de la position courante du voyage, comme en
  /// ligne. Dans un lot, c'est celle que les opérations précédentes viennent d'établir — l'ordre
  /// d'émission suffit donc à désigner la bonne gare.
  @override
  Future<void> repartir(int voyageId) async {
    try {
      await _remote.repartir(voyageId);
    } on ApiException catch (e) {
      if (!e.estHorsLigne) rethrow;

      await _deposer(
        voyageId: voyageId,
        type: TypeOperation.DEPART,
        payload: const {},
        geste: 'Le départ de gare hors ligne',
      );

      await _file?.modifierVoyageEnCache(
        voyageId,
        (voyage) => {...voyage, 'peutRepartir': false},
      );
    }
  }

  /// La gare est-elle le dernier arrêt de la ligne ?
  ///
  /// Le terminus se déduit de l'ordre des arrêts embarqués, faute de le recevoir tel quel. Sans
  /// arrêts — cache incomplet — on répond `false` : mieux vaut offrir un bouton que le serveur
  /// refusera poliment que retirer un geste légitime au vendeur.
  static bool _estTerminus(List<Map<String, dynamic>> arrets, int gareId) {
    if (arrets.isEmpty) return false;

    final ordres = {
      for (final a in arrets)
        if (a['id'] is int && a['ordre'] is int) a['id'] as int: a['ordre'] as int,
    };
    final ordre = ordres[gareId];
    if (ordre == null) return false;

    return ordre >= ordres.values.reduce((a, b) => a > b ? a : b);
  }

  /// Met le geste en file, avec l'horodatage du TÉLÉPHONE.
  ///
  /// Il fait foi : pour une arrivée comme pour un départ, l'heure de la synchronisation ferait croire
  /// à un car immobile pendant des heures puis téléporté, et fausserait le temps d'arrêt en gare —
  /// qui est justement ce que ces deux gestes servent à mesurer.
  Future<void> _deposer({
    required int voyageId,
    required TypeOperation type,
    required Map<String, dynamic> payload,
    required String geste,
  }) async {
    final synchronisateur = _synchronisateur;
    if (synchronisateur == null) {
      throw ApiException('$geste est indisponible : la préparation du voyage n\'a pas été faite.',
          estHorsLigne: true);
    }

    await synchronisateur.deposer(OperationHorsLigne(
      reference: _uuid.v4(),
      voyageId: voyageId,
      type: type,
      instant: DateTime.now(),
      payload: payload,
      statut: BaseLocale.enAttente,
      creeLe: DateTime.now(),
    ));
  }
}
