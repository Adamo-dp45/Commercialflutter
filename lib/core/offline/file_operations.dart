import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'base_locale.dart';
import 'operation_hors_ligne.dart';

/// La file des opérations encaissées sans réseau, et les instantanés qui les rendent possibles.
///
/// Tout passe par ici : mettre en file une vente, relire ce qui reste à envoyer, marquer le sort
/// rendu par le serveur. La règle qui gouverne l'ensemble est simple — **une opération mise en file
/// n'est jamais perdue ni modifiée** : elle est déjà payée et imprimée. On ne fait que lui attribuer
/// un sort.
class FileOperations {
  FileOperations(this._base);

  final BaseLocale _base;

  Database get _db => _base.db;

  final _changements = StreamController<void>.broadcast();

  /// Émet à chaque écriture dans la file.
  ///
  /// Sans ce signal, les compteurs de l'interface — le bandeau d'état, le journal des opérations —
  /// restent figés sur ce qu'ils ont lu à leur première construction : le vendeur encaisse trois
  /// billets hors ligne et l'écran continue d'annoncer qu'il n'y a rien en attente. Une file qui
  /// change en silence est pire qu'une file visible.
  Stream<void> get changements => _changements.stream;

  void fermer() => _changements.close();

  void _signaler() {
    if (!_changements.isClosed) _changements.add(null);
  }

  // ─────────────────────────────────────────── Instantanés ───────────────────────────────────────

  /// Enregistre l'instantané d'un voyage : c'est lui qui ARME le mode hors ligne.
  ///
  /// Tant qu'il n'est pas là, le téléphone ne peut ni calculer un prix, ni dessiner un plan de
  /// sièges, ni imprimer un reçu à l'en-tête de la compagnie — il ne doit donc pas vendre.
  Future<void> enregistrerInstantane(int voyageId, Map<String, dynamic> payload) async {
    await _db.insert(
      BaseLocale.tableInstantanes,
      {
        'voyage_id': voyageId,
        'payload': jsonEncode(payload),
        'telecharge_le': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> instantane(int voyageId) async {
    final lignes = await _db.query(
      BaseLocale.tableInstantanes,
      where: 'voyage_id = ?',
      whereArgs: [voyageId],
      limit: 1,
    );
    if (lignes.isEmpty) return null;

    return jsonDecode(lignes.first['payload']! as String) as Map<String, dynamic>;
  }

  /// L'en-tête de compagnie du dernier instantané téléchargé, pour imprimer sans réseau.
  ///
  /// Pourquoi « le dernier » suffit, sans préciser de voyage : un commercial appartient à UNE
  /// compagnie. Tous ses instantanés portent donc le même en-tête, et le plus récent est simplement
  /// le mieux à jour. Nul tant qu'aucun voyage n'a été armé — le reçu retombe alors sur ses valeurs
  /// par défaut, comme avant.
  Future<Map<String, dynamic>?> entrepriseEmbarquee() async {
    final lignes = await _db.query(
      BaseLocale.tableInstantanes,
      orderBy: 'telecharge_le DESC',
      limit: 1,
    );
    if (lignes.isEmpty) return null;

    final payload = jsonDecode(lignes.first['payload']! as String) as Map<String, dynamic>;

    return payload['entreprise'] as Map<String, dynamic>?;
  }

  /// Le voyage est clôturé, ou le vendeur n'est plus dessus : on rend la place.
  Future<void> oublierInstantane(int voyageId) async {
    await _db.delete(BaseLocale.tableInstantanes, where: 'voyage_id = ?', whereArgs: [voyageId]);
  }

  // ─────────────────────────────────────────── Départs ───────────────────────────────────────────

  /// Garde la dernière liste de départs reçue du serveur.
  ///
  /// Le cas qu'elle couvre : le téléphone redémarre EN ROUTE. Sans elle, l'écran d'accueil est vide,
  /// aucun voyage n'est ouvrable, et le vendeur ne peut pas atteindre son tunnel de vente — alors que
  /// l'instantané qui lui permettrait de vendre est bel et bien sur l'appareil.
  Future<void> enregistrerVoyages(List<Map<String, dynamic>> voyages) async {
    await _db.insert(
      BaseLocale.tableVoyages,
      {
        'id': 1,
        'payload': jsonEncode(voyages),
        'enregistre_le': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// La liste en cache, vide si aucun chargement n'a jamais abouti.
  Future<List<Map<String, dynamic>>> voyages() async {
    final lignes = await _db.query(BaseLocale.tableVoyages, where: 'id = 1', limit: 1);
    if (lignes.isEmpty) return const [];

    final decode = jsonDecode(lignes.first['payload']! as String);

    return decode is List ? decode.cast<Map<String, dynamic>>() : const [];
  }

  /// Applique une modification au voyage en cache, sans attendre le serveur.
  ///
  /// C'est ce qui rend une avance de position UTILISABLE hors ligne. La mettre en file ne suffit
  /// pas : tout ce que le vendeur peut faire ensuite — les destinations proposées, le droit de
  /// vendre, le prochain arrêt — se déduit de `garecouranteId`. Sans cette écriture, il déclarerait
  /// l'arrivée à Korhogo et l'application continuerait de le croire à Bouaké, refusant les trajets
  /// qu'il doit justement vendre à partir de là.
  ///
  /// Une correction locale, donc, que la prochaine lecture réussie du serveur écrasera — c'est bien
  /// ainsi : le serveur reste la référence dès qu'il est joignable.
  Future<void> modifierVoyageEnCache(
    int voyageId,
    Map<String, dynamic> Function(Map<String, dynamic> voyage) modification,
  ) async {
    final liste = await voyages();
    if (liste.isEmpty) return;

    final maj = [
      for (final v in liste)
        if (v['id'] == voyageId) modification(Map<String, dynamic>.from(v)) else v,
    ];

    await enregistrerVoyages(maj);
    _signaler();
  }

  // ──────────────────────────────────────────── File ─────────────────────────────────────────────

  Future<OperationHorsLigne> mettreEnFile(OperationHorsLigne operation) async {
    final id = await _db.insert(BaseLocale.tableOperations, operation.versLigne());
    _signaler();

    return OperationHorsLigne(
      id: id,
      reference: operation.reference,
      voyageId: operation.voyageId,
      type: operation.type,
      instant: operation.instant,
      payload: operation.payload,
      statut: operation.statut,
      motif: operation.motif,
      creeLe: operation.creeLe,
    );
  }

  /// Ce qui reste à envoyer pour un voyage, DANS L'ORDRE D'ÉMISSION.
  ///
  /// L'ordre n'est pas un détail : une vente faite depuis Bouaké doit remonter avant l'arrivée à
  /// Korhogo, sinon la position serait posée trop loin avant que le billet ne soit enregistré.
  Future<List<OperationHorsLigne>> enAttente(int voyageId) async {
    final lignes = await _db.query(
      BaseLocale.tableOperations,
      where: 'voyage_id = ? AND statut = ?',
      whereArgs: [voyageId, BaseLocale.enAttente],
      orderBy: 'id ASC',
    );

    return lignes.map(OperationHorsLigne.depuisLigne).toList();
  }

  /// Tout ce qui attend, tous voyages confondus — pour le bandeau d'état.
  Future<int> nombreEnAttente() async {
    final r = await _db.rawQuery(
      'SELECT COUNT(*) AS n FROM ${BaseLocale.tableOperations} WHERE statut = ?',
      [BaseLocale.enAttente],
    );

    return Sqflite.firstIntValue(r) ?? 0;
  }

  /// L'historique d'un voyage : ce qui est passé, ce qui attend, ce qui a été refusé.
  Future<List<OperationHorsLigne>> toutes(int voyageId) async {
    final lignes = await _db.query(
      BaseLocale.tableOperations,
      where: 'voyage_id = ?',
      whereArgs: [voyageId],
      orderBy: 'id DESC',
    );

    return lignes.map(OperationHorsLigne.depuisLigne).toList();
  }

  /// Consigne le sort rendu par le serveur.
  ///
  /// Un REFUS n'efface rien : l'opération reste en base avec son motif. Le vendeur a encaissé de
  /// l'argent — il doit pouvoir montrer ce qui s'est passé à sa gare, pas découvrir un trou.
  Future<void> marquer(String reference, {required String statut, String? motif}) async {
    await _db.update(
      BaseLocale.tableOperations,
      {'statut': statut, 'motif': motif},
      where: 'reference = ?',
      whereArgs: [reference],
    );
    _signaler();
  }
}
