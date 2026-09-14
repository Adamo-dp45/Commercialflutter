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
      codes: CodesHorsLigne(base),
    );
    await file.enregistrerInstantane(7, _instantane);
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

/// Bouaké (ordre 2) → Korhogo (ordre 3), tarif 8 000, plafond de remise 20 %.
const _instantane = <String, dynamic>{
  'voyage': {'id': 7, 'codevoyage': 'LI-V1'},
  'arrets': [
    {'gareId': 2, 'libelle': 'Yamoussoukro', 'ordre': 1},
    {'gareId': 3, 'libelle': 'Bouaké', 'ordre': 2},
    {'gareId': 4, 'libelle': 'Korhogo', 'ordre': 3},
  ],
  'sieges': [
    {'id': 21, 'numero': 1, 'rangee': 1, 'colonne': 1, 'cote': 'GAUCHE'},
    {'id': 22, 'numero': 2, 'rangee': 1, 'colonne': 1, 'cote': 'DROITE'},
    {'id': 23, 'numero': 3, 'rangee': 2, 'colonne': 1, 'cote': 'GAUCHE'},
    {'id': 24, 'numero': 4, 'rangee': 2, 'colonne': 1, 'cote': 'DROITE'},
  ],
  'billets': [
    // Occupe le siège 21 au point de montée.
    {'siegeId': 21, 'monteeId': 3, 'descenteId': 4, 'aBord': false, 'aMoi': false, 'evince': false},
    // Descend à Bouaké : le siège 22 se libère pour qui monte à Bouaké.
    {'siegeId': 22, 'monteeId': 2, 'descenteId': 3, 'aBord': false, 'aMoi': false, 'evince': false},
    // Gare de descente ABSENTE des arrêts embarqués : bornes illisibles.
    {'siegeId': 24, 'monteeId': 3, 'descenteId': 999, 'aBord': false, 'aMoi': false, 'evince': false},
  ],
  'tarifs': [
    {'departId': 3, 'arriveeId': 4, 'montant': 8000},
  ],
  'tarifsBagage': <dynamic>[],
  'plafondRemisePourcentage': 20,
  'entreprise': {'libelle': 'IRA Transport', 'sigle': 'IRA'},
};
