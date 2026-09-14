import 'package:sqflite/sqflite.dart';

import 'base_locale.dart';
import 'operation_hors_ligne.dart';

/// Génère les codes des documents émis HORS LIGNE : billets et étiquettes de bagage.
///
/// Pourquoi le téléphone doit les produire lui-même : le reçu et l'étiquette sont imprimés et remis
/// au client sur le champ, code encodé en QR pour le billet. Attendre le serveur reviendrait à
/// remettre un papier portant un code provisoire, qui changerait à la synchronisation — un papier qui
/// ne correspondrait plus à rien.
///
/// Pourquoi c'est sûr : un voyage n'a **qu'un seul commercial**. Ses deux séries ne peuvent donc
/// entrer en collision ni avec celles du guichet (préfixées différemment), ni avec un autre appareil.
/// Le serveur reprend les codes tels quels, et un index unique le protège d'une éventuelle erreur.
///
/// ```
/// guichet     : LI-ABI-KOR-0004-V37-TCK-2026-8      BAG-2026-41
/// à bord      : LI-ABI-KOR-0004-V37-TCK-2026-B3     LI-ABI-KOR-0004-V37-BAG-2026-B2
/// ```
///
/// Le code de bagage porte le code voyage alors que celui du guichet ne le porte pas : l'unicité d'un
/// `codebagage` est portée PAR ENTREPRISE côté serveur, donc une série « B » nue entrerait en
/// collision entre deux commerciaux de la même compagnie roulant le même jour.
class CodesHorsLigne {
  const CodesHorsLigne(this._base);

  final BaseLocale _base;

  /// Le prochain code de billet pour ce voyage.
  Future<String> billet({required int voyageId, required String codevoyage}) async =>
      _suivant(voyageId: voyageId, codevoyage: codevoyage, type: TypeOperation.VENTE, marqueur: 'TCK');

  /// Le prochain code de bagage pour ce voyage.
  Future<String> bagage({required int voyageId, required String codevoyage}) async =>
      _suivant(voyageId: voyageId, codevoyage: codevoyage, type: TypeOperation.BAGAGE, marqueur: 'BAG');

  /// Le compteur se déduit des opérations DÉJÀ EN FILE plutôt que d'être stocké à part : une seule
  /// source, impossible à désynchroniser de la file elle-même. Il ne redémarre donc jamais à 1 tant
  /// que les opérations du voyage sont là — y compris après un redémarrage de l'application.
  ///
  /// Chaque type compte SA propre série : un bagage enregistré entre deux ventes ne doit pas décaler
  /// la numérotation des billets, sans quoi un rejeu partiel produirait deux codes identiques.
  Future<String> _suivant({
    required int voyageId,
    required String codevoyage,
    required TypeOperation type,
    required String marqueur,
  }) async {
    final r = await _base.db.rawQuery(
      'SELECT COUNT(*) AS n FROM ${BaseLocale.tableOperations} WHERE voyage_id = ? AND type = ?',
      [voyageId, type.name],
    );
    final rang = (Sqflite.firstIntValue(r) ?? 0) + 1;

    return '$codevoyage-$marqueur-${DateTime.now().year}-B$rang';
  }
}
