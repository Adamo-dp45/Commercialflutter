import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Base locale du vendeur à bord — le premier stockage MÉTIER de l'application.
///
/// Jusqu'ici seuls les jetons d'authentification étaient persistés : tout le reste vivait en mémoire
/// et disparaissait au redémarrage. Vendre sans réseau impose l'inverse — une vente encaissée doit
/// survivre à une coupure, à un écran éteint, à une batterie vide.
///
/// Deux tables, et une seule raison à chacune :
///
///  * `instantanes` — ce que le serveur a envoyé pendant qu'il y avait du réseau : la ligne, les
///    sièges, les billets en cours, la grille tarifaire. C'est avec ça, et rien d'autre, que le
///    téléphone calcule un prix et dessine un plan de sièges hors ligne.
///
///  * `operations` — la file des gestes encaissés sans réseau. L'`id` auto-incrémenté donne l'ordre
///    FIFO, et c'est un ordre qui compte : les ventes faites depuis une gare précèdent l'arrivée à la
///    suivante. La `reference` est unique — c'est la clé d'idempotence que le serveur utilise pour
///    qu'un rejeu ne duplique rien.
///
///  * `voyages` — la dernière liste de départs reçue du serveur. Sans elle, un téléphone qui
///    redémarre en route (batterie vide, application tuée) n'affiche plus aucun voyage et le vendeur
///    ne peut même plus atteindre l'écran de vente — alors que l'instantané, lui, est toujours là.
///    Une seule ligne, remplacée à chaque chargement réussi.
class BaseLocale {
  BaseLocale._(this._db);

  final Database _db;

  Database get db => _db;

  static const String tableInstantanes = 'instantanes';
  static const String tableOperations = 'operations';
  static const String tableVoyages = 'voyages';

  /// Statuts d'une opération en file.
  static const String enAttente = 'EN_ATTENTE';
  static const String synchronisee = 'SYNCHRONISEE';
  static const String refusee = 'REFUSEE';

  static Future<BaseLocale> ouvrir({String? chemin}) async {
    final dossier = chemin ?? p.join(await getDatabasesPath(), 'commercial_hors_ligne.db');

    final db = await openDatabase(
      dossier,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableInstantanes (
            voyage_id     INTEGER PRIMARY KEY,
            payload       TEXT    NOT NULL,
            telecharge_le TEXT    NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tableOperations (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            reference TEXT    NOT NULL UNIQUE,
            voyage_id INTEGER NOT NULL,
            type      TEXT    NOT NULL,
            instant   TEXT    NOT NULL,
            payload   TEXT    NOT NULL,
            statut    TEXT    NOT NULL,
            motif     TEXT,
            cree_le   TEXT    NOT NULL
          )
        ''');

        // La vidange lit toujours « ce qui reste à envoyer pour ce voyage, dans l'ordre ».
        await db.execute(
          'CREATE INDEX idx_operations_attente ON $tableOperations (voyage_id, statut, id)',
        );

        await db.execute(_creationVoyages);
      },
      onUpgrade: (db, ancienne, nouvelle) async {
        // v1 → v2 : cache de la liste des départs. Rien à migrer, la table part vide et se remplit
        // au prochain chargement avec réseau.
        if (ancienne < 2) {
          await db.execute(_creationVoyages);
        }
      },
    );

    return BaseLocale._(db);
  }

  Future<void> fermer() => _db.close();

  static const String _creationVoyages = '''
    CREATE TABLE $tableVoyages (
      id             INTEGER PRIMARY KEY CHECK (id = 1),
      payload        TEXT    NOT NULL,
      enregistre_le  TEXT    NOT NULL
    )
  ''';
}
