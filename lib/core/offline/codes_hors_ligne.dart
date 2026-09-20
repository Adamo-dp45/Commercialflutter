import 'file_operations.dart';
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
  const CodesHorsLigne(this._file);

  final FileOperations _file;

  /// Le prochain code de billet pour ce voyage.
  Future<String> billet({required int voyageId, required String codevoyage}) =>
      _suivant(voyageId: voyageId, codevoyage: codevoyage, type: TypeOperation.VENTE, marqueur: 'TCK');

  /// Le prochain code de bagage pour ce voyage.
  Future<String> bagage({required int voyageId, required String codevoyage}) =>
      _suivant(voyageId: voyageId, codevoyage: codevoyage, type: TypeOperation.BAGAGE, marqueur: 'BAG');

  /// Le rang suivant, pris au PLUS HAUT de deux sources.
  ///
  ///  * la FILE locale — les opérations de ce voyage, remontées ou non ;
  ///  * l'INSTANTANÉ — les codes « B » que le serveur connaît déjà.
  ///
  /// La file seule ne suffit pas, et c'est un piège qui coûte cher : elle est la seule mémoire du
  /// compteur, donc une réinstallation ou un effacement des données la ramène à zéro. Le téléphone
  /// réémet alors B1 alors que le serveur détient déjà B1, B2, B3 — le code est refusé, et la vente
  /// encaissée avec lui. L'instantané, lui, porte les billets déjà émis : il rattrape le compteur.
  ///
  /// Chaque type compte SA propre série : un bagage enregistré entre deux ventes ne doit pas décaler
  /// la numérotation des billets, sans quoi un rejeu partiel produirait deux codes identiques.
  Future<String> _suivant({
    required int voyageId,
    required String codevoyage,
    required TypeOperation type,
    required String marqueur,
  }) async {
    final enFile = await _file.nombreOperations(voyageId, type);
    final dejaEmis = await _plusHautRangConnu(voyageId, marqueur);
    final rang = (enFile > dejaEmis ? enFile : dejaEmis) + 1;

    return '$codevoyage-$marqueur-${DateTime.now().year}-B$rang';
  }

  /// Le plus haut rang « B » que l'instantané connaisse pour ce marqueur, 0 s'il n'y en a aucun.
  Future<int> _plusHautRangConnu(int voyageId, String marqueur) async {
    final instantane = await _file.instantane(voyageId);
    if (instantane == null) return 0;

    final cle = marqueur == 'BAG' ? 'bagages' : 'billets';
    final champ = marqueur == 'BAG' ? 'codebagage' : 'codeticket';
    final motif = RegExp('-$marqueur-\\d{4}-B(\\d+)\$');

    var plusHaut = 0;
    for (final ligne in (instantane[cle] as List<dynamic>? ?? const [])) {
      final code = (ligne as Map<String, dynamic>)[champ];
      if (code is! String) continue;

      final rang = int.tryParse(motif.firstMatch(code)?.group(1) ?? '');
      if (rang != null && rang > plusHaut) plusHaut = rang;
    }

    return plusHaut;
  }
}
