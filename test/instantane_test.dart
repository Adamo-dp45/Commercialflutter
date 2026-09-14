import 'package:commercialflutter/core/offline/base_locale.dart';
import 'package:commercialflutter/core/offline/file_operations.dart';
import 'package:commercialflutter/core/offline/operation_hors_ligne.dart';
import 'package:commercialflutter/features/gestion/data/datasources/gestion_local_datasource.dart';
import 'package:commercialflutter/features/manifeste/data/datasources/manifeste_local_datasource.dart';
import 'package:commercialflutter/features/vente/data/datasources/vente_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

/// Ce que le téléphone recalcule seul, à partir de l'instantané.
///
/// Ces tests protègent une propriété précise : **le téléphone applique les mêmes règles que le
/// serveur.** Plan de sièges, grille de poids, manifeste — chacun de ces calculs existe déjà côté
/// serveur et se trouve ici rejoué. S'ils divergent, le vendeur encaisse sur une réalité qui n'est
/// pas celle du système, et l'écart n'apparaît qu'à la synchronisation.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late BaseLocale base;
  late FileOperations file;

  setUp(() async {
    base = await BaseLocale.ouvrir(chemin: inMemoryDatabasePath);
    file = FileOperations(base);
    await file.enregistrerInstantane(7, _instantane);
  });

  tearDown(() async => base.fermer());

  group('grille de poids', () {
    test('la première tranche qui couvre le poids gagne', () async {
      final source = VenteLocalDataSource(file);

      expect(await source.tarifBagage(voyageId: 7, poids: 5), 1000);
      expect(await source.tarifBagage(voyageId: 7, poids: 10), 1000, reason: 'borne haute incluse');
      expect(await source.tarifBagage(voyageId: 7, poids: 11), 2500, reason: 'borne basse incluse');
      expect(await source.tarifBagage(voyageId: 7, poids: 25), 2500);
    });

    test('la dernière tranche est illimitée', () async {
      final source = VenteLocalDataSource(file);

      expect(await source.tarifBagage(voyageId: 7, poids: 26), 5000);
      expect(await source.tarifBagage(voyageId: 7, poids: 500), 5000);
    });

    test('un voyage non armé ne facture rien plutôt que d\'inventer un prix', () async {
      final source = VenteLocalDataSource(file);

      expect(await source.tarifBagage(voyageId: 99, poids: 12), isNull);
    });
  });

  group('plan de sièges', () {
    test('la disposition du car est restituée, pas une simple liste', () async {
      // Sans rangée / côté, le plan se dessine sur une seule ligne de cinquante cases : le vendeur
      // ne retrouve plus ses sièges, et la vue déborde de l'écran.
      final sieges = await VenteLocalDataSource(file)
          .sieges(voyageId: 7, monteeId: 3, descenteId: 4);

      expect(sieges, hasLength(2));
      expect(sieges.first.rangee, 1);
      expect(sieges.map((s) => s.cote), ['GAUCHE', 'DROITE']);
    });

    test('un siège déjà vendu dans l\'instantané est occupé', () async {
      final sieges = await VenteLocalDataSource(file)
          .sieges(voyageId: 7, monteeId: 3, descenteId: 4);

      expect(
        sieges.every((s) => s.statut == 'OCCUPE'),
        isTrue,
        reason: 'les deux sièges portent un billet Bouaké → Korhogo dans l\'instantané',
      );
    });
  });

  group('mes ventes', () {
    test('la liste se reconstitue depuis l\'instantané, et se dit hors ligne', () async {
      final ventes = await GestionLocalDataSource(file).ventesDuVoyage(7);

      expect(ventes.horsLigne, isTrue, reason: 'la page s\'en sert pour désactiver les corrections');
      expect(ventes.tickets, hasLength(1));
      expect(ventes.tickets.first.prix, 8000, reason: 'de quoi réimprimer un reçu fidèle');
      expect(ventes.tickets.first.trajet, 'Bouaké → Korhogo');
      expect(ventes.bagages, hasLength(1));
      expect(ventes.bagages.first.codebagage, 'BAG-2026-41');
    });

    test('seules MES ventes apparaissent, pas celles du guichet', () async {
      // Le périmètre est dit par le serveur ('aMoi'), pas déduit du canal : le billet évincé
      // appartient au guichet et n'a rien à faire dans cette page.
      final ventes = await GestionLocalDataSource(file).ventesDuVoyage(7);

      expect(ventes.tickets.map((t) => t.codeticket), isNot(contains('LI-V1-TCK-2026-9')));
    });

    test('les ventes encore en file s\'ajoutent, sans identifiant serveur', () async {
      await file.mettreEnFile(OperationHorsLigne(
        reference: 'ref-1',
        voyageId: 7,
        type: TypeOperation.VENTE,
        instant: DateTime(2026, 9, 12, 8, 30),
        payload: {
          'codeticket': 'LI-V1-TCK-2026-B1',
          'siege': 22,
          'gare': 3,
          'garedescente': 4,
          'nomclient': 'Konan Aya',
          'montantEncaisse': 8000,
        },
        statut: BaseLocale.enAttente,
        creeLe: DateTime(2026, 9, 12, 8, 30),
      ));

      final ventes = await GestionLocalDataSource(file).ventesDuVoyage(7);
      final vendu = ventes.tickets.firstWhere((t) => t.codeticket == 'LI-V1-TCK-2026-B1');

      expect(
        vendu.id,
        0,
        reason: 'sans identifiant serveur, aucune correction ne peut viser ce billet — la page le lit',
      );
      expect(vendu.prix, 8000);
      expect(vendu.siegeNumero, 2);
    });

    test('un voyage non armé ne rend rien plutôt qu\'une liste fausse', () async {
      final ventes = await GestionLocalDataSource(file).ventesDuVoyage(99);

      expect(ventes.tickets, isEmpty);
      expect(ventes.bagages, isEmpty);
    });
  });

  group('manifeste', () {
    test('les évincés sont écartés, comme le fait le serveur', () async {
      final passagers = await ManifesteLocalDataSource(file).manifeste(7);

      expect(
        passagers.map((p) => p.codeticket),
        isNot(contains('LI-V1-TCK-2026-9')),
        reason: 'ce passager ne montera pas : l\'annoncer décrirait un car que personne n\'occupe',
      );
    });

    test('les libellés de gare se résolvent depuis les arrêts embarqués', () async {
      final passagers = await ManifesteLocalDataSource(file).manifeste(7);

      expect(passagers.first.trajet, 'Bouaké → Korhogo');
    });

    test('les ventes de ce téléphone encore en file apparaissent au manifeste', () async {
      // Elles n'existent nulle part ailleurs — et le passager est pourtant assis dans le car.
      await file.mettreEnFile(OperationHorsLigne(
        reference: 'ref-1',
        voyageId: 7,
        type: TypeOperation.VENTE,
        instant: DateTime(2026, 9, 12, 8, 30),
        payload: {
          'codeticket': 'LI-V1-TCK-2026-B1',
          'siege': 22,
          'gare': 3,
          'garedescente': 4,
          'nomclient': 'Konan Aya',
        },
        statut: BaseLocale.enAttente,
        creeLe: DateTime(2026, 9, 12, 8, 30),
      ));

      final passagers = await ManifesteLocalDataSource(file).manifeste(7);
      final vendu = passagers.firstWhere((p) => p.codeticket == 'LI-V1-TCK-2026-B1');

      expect(vendu.ticketId, isNull, reason: 'aucun identifiant serveur avant la synchronisation');
      expect(vendu.siegeNumero, 2, reason: 'le numéro vient du plan de sièges embarqué');
      expect(vendu.clientAffiche, 'Konan Aya');
      expect(vendu.aBord, isTrue);
    });

    test('le manifeste est trié par siège', () async {
      final passagers = await ManifesteLocalDataSource(file).manifeste(7);
      final numeros = passagers.map((p) => p.siegeNumero ?? 0).toList();

      expect(numeros, List.of(numeros)..sort());
    });
  });
}

/// Un instantané minimal mais complet : 2 arrêts, 2 sièges, 2 billets dont un évincé, la grille.
const _instantane = <String, dynamic>{
  'voyage': {'id': 7, 'codevoyage': 'LI-V1'},
  'arrets': [
    {'gareId': 3, 'libelle': 'Bouaké', 'ordre': 2},
    {'gareId': 4, 'libelle': 'Korhogo', 'ordre': 3},
  ],
  'sieges': [
    {'id': 21, 'numero': 1, 'rangee': 1, 'colonne': 1, 'cote': 'GAUCHE'},
    {'id': 22, 'numero': 2, 'rangee': 1, 'colonne': 1, 'cote': 'DROITE'},
  ],
  'billets': [
    {
      'siegeId': 21,
      'monteeId': 3,
      'descenteId': 4,
      'descenteAfficheeId': 4,
      'ticketId': 100,
      'codeticket': 'LI-V1-TCK-2026-8',
      'siegeNumero': 1,
      'nomclient': 'Traoré Sali',
      'contactclient': '+225 07 00 00 00 01',
      'aBord': true,
      'aMoi': true,
      'evince': false,
      'prix': 8000,
      'remise': 0,
      'statut': 'VALIDE',
      'dateEmission': '2026-09-12T07:10:00+00:00',
    },
    {
      'siegeId': 22,
      'monteeId': 3,
      'descenteId': 4,
      'descenteAfficheeId': 4,
      'ticketId': 101,
      'codeticket': 'LI-V1-TCK-2026-9',
      'siegeNumero': 2,
      'nomclient': 'Évincé',
      'aBord': false,
      'aMoi': false,
      'evince': true,
    },
  ],
  'bagages': [
    {
      'id': 55,
      'codebagage': 'BAG-2026-41',
      'nature': 'Carton',
      'type': 'LEGER',
      'poids': 8,
      'montant': 1000,
      'montantforce': false,
      'statut': 'ENREGISTRE',
      'ticketId': 100,
      'codeticket': 'LI-V1-TCK-2026-8',
      'nomclient': 'Traoré Sali',
      'monteeId': 3,
      'descenteId': 4,
    },
  ],
  'tarifs': [
    {'departId': 3, 'arriveeId': 4, 'montant': 8000},
  ],
  'tarifsBagage': [
    {'poidsmin': 0, 'poidsmax': 10, 'montant': 1000},
    {'poidsmin': 11, 'poidsmax': 25, 'montant': 2500},
    {'poidsmin': 26, 'poidsmax': null, 'montant': 5000},
  ],
  'entreprise': {'libelle': 'IRA Transport', 'sigle': 'IRA', 'contact1': '+225 27 20 30 40 50'},
};
