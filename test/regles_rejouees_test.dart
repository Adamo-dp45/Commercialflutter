import 'package:commercialflutter/core/network/api_exception.dart';
import 'package:commercialflutter/core/offline/base_locale.dart';
import 'package:commercialflutter/core/offline/codes_hors_ligne.dart';
import 'package:commercialflutter/core/offline/file_operations.dart';
import 'package:commercialflutter/core/offline/synchronisateur.dart';
import 'package:commercialflutter/features/vente/data/datasources/vente_local_datasource.dart';
import 'package:commercialflutter/features/vente/data/datasources/vente_remote_datasource.dart';
import 'package:commercialflutter/features/vente/data/models/siege.dart';
import 'package:commercialflutter/features/vente/data/models/ticket_vendu.dart';
import 'package:commercialflutter/features/vente/data/repositories/vente_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

/// Les règles du serveur que le téléphone REJOUE, et leurs refus.
///
/// Une règle rejouée peut diverger de son original — c'est le risque propre au mode hors ligne, et il
/// ne se voit pas : les deux codes marchent, simplement pas pareil. Ces tests fixent les points où la
/// divergence coûte cher, et tous obéissent au même principe :
///
/// **on refuse AVANT d'encaisser, jamais après.** Un refus avant la vente est un message au vendeur ;
/// le même refus à la synchronisation, c'est un passager parti avec un billet qui n'existera jamais.
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late BaseLocale base;
  late FileOperations file;
  late VenteRepositoryImpl repository;

  setUp(() async {
    base = await BaseLocale.ouvrir(chemin: inMemoryDatabasePath);
    file = FileOperations(base);
    repository = VenteRepositoryImpl(
      _RemoteHorsLigne(),
      local: VenteLocalDataSource(file),
      synchronisateur: Synchronisateur(Dio(), file),
      codes: CodesHorsLigne(file),
      file: file,
    );
    await file.enregistrerInstantane(7, _instantane);
    await file.enregistrerVoyages([
      {
        'id': 7,
        'codevoyage': 'LI-V1',
        'maRecette': 10000,
        'mesTickets': 2,
        'mesBagages': 1,
        'placestotal': 50,
        'placesoccupees': 4,
        'arrets': <dynamic>[],
      },
    ]);
  });

  tearDown(() async => base.fermer());

  Future<TicketVendu> vendre({String? type, int? valeur}) => repository.vendreTicket(
        voyageId: 7,
        siegeId: 23,
        monteeGareId: 3,
        descenteGareId: 4,
        remiseType: type,
        remiseValeur: valeur,
      );

  group('remise — les mêmes refus que le serveur', () {
    test('une remise ordinaire passe et se déduit du prix', () async {
      final ticket = await vendre(type: 'POURCENTAGE', valeur: 10);

      expect(ticket.remise, 800, reason: '10 % de 8 000');
      expect(ticket.prix, 7200);
    });

    test('LE PLAFOND de la compagnie est appliqué hors ligne', () async {
      /*
        Le plafond était embarqué dans l'instantané depuis le début, et personne ne le lisait — un
        commentaire affirmait que l'écran de vente s'en chargeait, ce qui était faux. En ligne, sans
        conséquence : le serveur refuse avant qu'un billet n'existe. Hors ligne, la vente était
        encaissée, imprimée, puis REFUSÉE à la synchronisation.
      */
      await expectLater(
        vendre(type: 'POURCENTAGE', valeur: 50),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('plafond'))),
      );

      expect(await file.enAttente(7), isEmpty, reason: 'rien n\'est encaissé ni mis en file');
    });

    test('une remise exactement au plafond passe', () async {
      // Sans la tolérance du serveur, un arrondi ferait refuser une remise pourtant conforme.
      final ticket = await vendre(type: 'POURCENTAGE', valeur: 20);

      expect(ticket.remise, 1600);
    });

    test('une remise supérieure au prix est refusée, pas bornée en silence', () async {
      // Le téléphone la ramenait au tarif : le client payait 0 et le serveur refusait la vente.
      await expectLater(
        vendre(type: 'MONTANT', valeur: 20000),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('dépasser'))),
      );
    });

    test('un type de remise inconnu est refusé', () async {
      await expectLater(
        vendre(type: 'CADEAU', valeur: 500),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('invalide'))),
      );
    });
  });

  group('occupation d\'un siège', () {
    Future<List<Siege>> plan() =>
        VenteLocalDataSource(file).sieges(voyageId: 7, monteeId: 3, descenteId: 4);

    test('la règle de la priorité amont est celle du serveur', () async {
      final sieges = await plan();

      // 21 : Bouaké → Korhogo, occupé à Bouaké. 22 : Adjamé → Bouaké, descendu AVANT, donc libre.
      expect(sieges.firstWhere((s) => s.id == 21).statut, 'OCCUPE');
      expect(sieges.firstWhere((s) => s.id == 22).statut, 'LIBRE');
    });

    test('un siège vendu par une gare AVAL est libre, mais SIGNALÉ', () async {
      /*
        Le pendant de la priorité amont : rien n'empêche de vendre ce siège, et c'est voulu. Mais le
        passager de Ferké ne montera pas — alors qu'un siège voisin était libre. Le dire au moment
        du CHOIX est le seul moment utile : à la synchronisation, l'éviction a déjà eu lieu.
      */
      final siege = (await plan()).firstWhere((s) => s.id == 25);

      expect(siege.statut, 'LIBRE', reason: 'la priorité amont ne bouge pas');
      expect(siege.alerteAval, isTrue);
      expect(siege.avalMontee, 'Ferké');
      expect(siege.avalDescente, 'Korhogo');
      expect(siege.avalNombre, 1);
      expect(siege.resumeAval, 'Ferké → Korhogo, Awa Koffi');
    });

    test('un passager qui DESCEND à ma gare ne déclenche aucune alerte', () async {
      /*
        LE FAUX POSITIF LIVRÉ CÔTÉ SERVEUR, et le plus visible de tous : un Yamoussoukro → Bouaké
        faisait signaler le siège au vendeur qui monte à Bouaké — alors que son occupant vient
        précisément d'en descendre. Il n'y a personne à évincer, le siège est simplement libre.

        La cause : on échappe au test d'occupation de DEUX façons — monter plus tard (le vrai cas
        aval) ou être monté plus tôt et avoir DÉJÀ DESCENDU. Sans la borne `debut > ordreMontee`, la
        seconde passait pour la première. Un repère qui se déclenche sur la revente la plus banale
        du réseau ne serait plus regardé, donc ne préviendrait plus des vraies évictions.
      */
      final siege = (await plan()).firstWhere((s) => s.id == 22);

      expect(siege.statut, 'LIBRE');
      expect(siege.alerteAval, isFalse);
      expect(siege.avalMontee, isNull);
    });

    test('un billet DÉJÀ évincé ne redéclenche aucune alerte', () async {
      // Son sort ne dépend pas de cette vente, et `conflit` le signale ailleurs. Crier deux fois au
      // loup pour la même place ferait douter des alertes qui, elles, sont évitables.
      expect((await plan()).firstWhere((s) => s.id == 26).alerteAval, isFalse);
    });

    test('un siège OCCUPÉ ne porte aucune alerte : elle serait sans objet', () async {
      // Même arbitrage que `PlanCar` côté web : la vente y est de toute façon impossible.
      expect((await plan()).firstWhere((s) => s.id == 21).alerteAval, isFalse);
    });

    test('ma propre vente en file suit la règle de tronçon, comme celles du serveur', () async {
      /*
        Elles étaient bloquées EN BLOC, descente ignorée. Un siège que le vendeur a lui-même vendu
        Bouaké → Ferké restait donc occupé pour toujours à ses yeux, alors que son passager descend
        à Ferké et que le serveur l'y rend libre.

        Aucune mauvaise vente n'en découlait — le défaut faisait seulement perdre au car une place
        revendable, hors réseau, c'est-à-dire là où l'on ne peut appeler personne pour comprendre
        pourquoi le plan refuse.
      */
      await repository.vendreTicket(
        voyageId: 7,
        siegeId: 23,
        monteeGareId: 3, // Bouaké
        descenteGareId: 5, // Ferké : le passager descend avant Korhogo
      );

      // Vu depuis Bouaké, le siège est bien pris : le passager y monte.
      expect((await plan()).firstWhere((s) => s.id == 23).statut, 'OCCUPE');

      // Vu depuis Ferké, il s'est libéré — et se revend.
      final depuisFerke = await VenteLocalDataSource(file)
          .sieges(voyageId: 7, monteeId: 5, descenteId: 4);
      expect(depuisFerke.firstWhere((s) => s.id == 23).statut, 'LIBRE');
    });

    test('des bornes illisibles BLOQUENT le siège, elles ne le libèrent pas', () async {
      /*
        Posture du serveur, mot pour mot : « sécurité : ticket hors ligne → on bloque ». Le téléphone
        ignorait le billet, donc affichait libre un siège que le serveur tient pour occupé — et
        l'erreur ne se serait découverte qu'après l'encaissement.
      */
      final sieges = await plan();

      expect(sieges.firstWhere((s) => s.id == 24).statut, 'OCCUPE');
    });
  });

  group('ma performance', () {
    Future<Map<String, dynamic>> voyageEnCache() async =>
        (await file.voyages()).firstWhere((v) => v['id'] == 7);

    test('une vente hors ligne fait bouger la recette et les compteurs', () async {
      /*
        « Ma performance » vient du serveur, et le serveur ignore encore cette vente. Sans correction
        locale, le vendeur encaisse trois billets et voit sa recette immobile — un compteur qui ment
        sur son propre travail, et le seul retour chiffré qu'il ait de sa journée.
      */
      await vendre();

      final voyage = await voyageEnCache();
      expect(voyage['maRecette'], 18000, reason: '10 000 + 8 000 encaissés');
      expect(voyage['mesTickets'], 3);
      expect(voyage['placesoccupees'], 5, reason: 'une place de moins à vendre');
    });

    test('la recette suit le NET encaissé, pas le tarif plein', () async {
      await vendre(type: 'POURCENTAGE', valeur: 10);

      expect((await voyageEnCache())['maRecette'], 17200, reason: '10 000 + 7 200');
    });

    test('un bagage hors ligne compte aussi', () async {
      await repository.ajouterBagage(
        voyageId: 7,
        codeticket: 'LI-V1-TCK-2026-B1',
        nature: 'Valise',
        type: 'LOURD',
        poids: 18,
        montant: 2500,
      );

      final voyage = await voyageEnCache();
      expect(voyage['maRecette'], 12500);
      expect(voyage['mesBagages'], 2);
      expect(voyage['mesTickets'], 2, reason: 'un bagage n\'est pas un billet');
    });

    test('une vente REFUSÉE ne touche à rien', () async {
      // Le refus tombe avant l'encaissement : ni file, ni compteur, ni recette.
      await expectLater(vendre(type: 'POURCENTAGE', valeur: 50), throwsA(isA<ApiException>()));

      final voyage = await voyageEnCache();
      expect(voyage['maRecette'], 10000);
      expect(voyage['mesTickets'], 2);
    });
  });

  test('le plafond absent de l\'instantané ne bloque rien', () async {
    // Pas de plafond configuré côté compagnie : on ne doit pas en inventer un.
    await file.enregistrerInstantane(8, {
      ..._instantane,
      'voyage': {'id': 8, 'codevoyage': 'LI-V2'},
      'plafondRemisePourcentage': null,
    });

    final ticket = await repository.vendreTicket(
      voyageId: 8,
      siegeId: 23,
      monteeGareId: 3,
      descenteGareId: 4,
      remiseType: 'POURCENTAGE',
      remiseValeur: 90,
    );

    expect(ticket.remise, 7200);
  });
}

class _RemoteHorsLigne extends VenteRemoteDataSource {
  _RemoteHorsLigne() : super(Dio());

  static const _coupure = ApiException(
    'Impossible de joindre le serveur. Vérifiez votre connexion.',
    estHorsLigne: true,
  );

  @override
  Future<TicketVendu> vendreTicket({
    required int voyageId,
    required int siegeId,
    required int monteeGareId,
    required int descenteGareId,
    String? nom,
    String? contact,
    String? remiseType,
    int? remiseValeur,
  }) async =>
      throw _coupure;
}

/// Le vendeur est à Bouaké (ordre 2) et vend jusqu'à Korhogo (ordre 4), tarif 8 000, plafond de
/// remise 20 %. Ferké s'intercale entre les deux : sans arrêt INTERMÉDIAIRE au tronçon vendu, le cas
/// « vendu en aval » ne peut tout simplement pas se produire, et le repère resterait non testé.
const _instantane = <String, dynamic>{
  'voyage': {'id': 7, 'codevoyage': 'LI-V1'},
  'arrets': [
    {'gareId': 2, 'libelle': 'Yamoussoukro', 'ordre': 1},
    {'gareId': 3, 'libelle': 'Bouaké', 'ordre': 2},
    {'gareId': 5, 'libelle': 'Ferké', 'ordre': 3},
    {'gareId': 4, 'libelle': 'Korhogo', 'ordre': 4},
  ],
  'sieges': [
    {'id': 21, 'numero': 1, 'rangee': 1, 'colonne': 1, 'cote': 'GAUCHE'},
    {'id': 22, 'numero': 2, 'rangee': 1, 'colonne': 1, 'cote': 'DROITE'},
    {'id': 23, 'numero': 3, 'rangee': 2, 'colonne': 1, 'cote': 'GAUCHE'},
    {'id': 24, 'numero': 4, 'rangee': 2, 'colonne': 1, 'cote': 'DROITE'},
    {'id': 25, 'numero': 5, 'rangee': 3, 'colonne': 1, 'cote': 'GAUCHE'},
    {'id': 26, 'numero': 6, 'rangee': 3, 'colonne': 1, 'cote': 'DROITE'},
  ],
  'billets': [
    // Occupe le siège 21 au point de montée.
    {'siegeId': 21, 'monteeId': 3, 'descenteId': 4, 'aBord': false, 'aMoi': false, 'evince': false},
    // Descend à Bouaké : le siège 22 se libère pour qui monte à Bouaké.
    {'siegeId': 22, 'monteeId': 2, 'descenteId': 3, 'aBord': false, 'aMoi': false, 'evince': false},
    // Gare de descente ABSENTE des arrêts embarqués : bornes illisibles.
    {'siegeId': 24, 'monteeId': 3, 'descenteId': 999, 'aBord': false, 'aMoi': false, 'evince': false},
    // Ferké → Korhogo : monte APRÈS le vendeur, DANS son tronçon. Le siège 25 est libre pour lui,
    // mais le prendre évincerait ce passager.
    {
      'siegeId': 25,
      'monteeId': 5,
      'descenteId': 4,
      'descenteAfficheeId': 4,
      'nomclient': 'Awa Koffi',
      'aBord': false,
      'aMoi': false,
      'evince': false,
    },
    // Ferké → Korhogo, mais DÉJÀ évincé : son sort ne dépend pas de cette vente.
    {
      'siegeId': 26,
      'monteeId': 5,
      'descenteId': 4,
      'nomclient': 'Déjà évincé',
      'aBord': false,
      'aMoi': false,
      'evince': true,
    },
  ],
  'tarifs': [
    {'departId': 3, 'arriveeId': 4, 'montant': 8000},
    {'departId': 3, 'arriveeId': 5, 'montant': 5000},
  ],
  'tarifsBagage': <dynamic>[],
  'plafondRemisePourcentage': 20,
  'entreprise': {'libelle': 'IRA Transport', 'sigle': 'IRA'},
};
