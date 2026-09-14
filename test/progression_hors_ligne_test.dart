import 'package:commercialflutter/core/network/api_exception.dart';
import 'package:commercialflutter/core/offline/base_locale.dart';
import 'package:commercialflutter/core/offline/file_operations.dart';
import 'package:commercialflutter/core/offline/operation_hors_ligne.dart';
import 'package:commercialflutter/core/offline/synchronisateur.dart';
import 'package:commercialflutter/features/voyages/data/datasources/voyage_remote_datasource.dart';
import 'package:commercialflutter/features/voyages/data/models/voyage_commercial.dart';
import 'package:commercialflutter/features/voyages/data/repositories/voyage_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

/// La progression du car déclarée SANS réseau.
///
/// Deux propriétés sont protégées ici, et la seconde est la moins évidente :
///
///  1. le geste part en file — sinon il est simplement perdu ;
///  2. **le voyage en cache est corrigé dans la foulée**, en appliquant les mêmes règles que le
///     serveur. Sans cela le vendeur déclare une arrivée et l'application le croit encore à la gare
///     d'avant ; et si la correction est trop généreuse, elle lui offre un geste que la
///     synchronisation refusera à coup sûr — après lui avoir affiché « Départ enregistré ».
void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late BaseLocale base;
  late FileOperations file;
  late VoyageRepositoryImpl repository;

  setUp(() async {
    base = await BaseLocale.ouvrir(chemin: inMemoryDatabasePath);
    file = FileOperations(base);
    repository = VoyageRepositoryImpl(
      _RemoteHorsLigne(),
      file: file,
      synchronisateur: Synchronisateur(Dio(), file),
    );

    await file.enregistrerVoyages([
      {
        'id': 7,
        'codevoyage': 'LI-V1',
        'demarre': true,
        'garecouranteId': 2,
        'garecouranteLibelle': 'Yamoussoukro',
        'peutRepartir': false,
        'arrets': [
          {'id': 1, 'libelle': 'Adjamé', 'ordre': 0},
          {'id': 2, 'libelle': 'Yamoussoukro', 'ordre': 1},
          {'id': 3, 'libelle': 'Bouaké', 'ordre': 2},
          {'id': 4, 'libelle': 'Korhogo', 'ordre': 3},
        ],
      },
    ]);
  });

  tearDown(() async => base.fermer());

  Future<VoyageCommercial> voyageEnCache() async =>
      VoyageCommercial.fromJson((await file.voyages()).single);

  test('une arrivée sans réseau part en file et déplace le car localement', () async {
    await repository.avancer(voyageId: 7, gareId: 3);

    final enFile = await file.enAttente(7);
    expect(enFile, hasLength(1));
    expect(enFile.single.type, TypeOperation.POSITION);
    expect(enFile.single.payload['gare'], 3);

    final voyage = await voyageEnCache();
    expect(voyage.garecouranteId, 3);
    expect(voyage.garecouranteLibelle, 'Bouaké');
    expect(
      voyage.descentesPossibles.map((a) => a.libelle),
      ['Korhogo'],
      reason: 'les trajets vendables suivent la position : c\'est tout l\'objet de la correction',
    );
  });

  test('à une gare intermédiaire, le départ devient proposable', () async {
    await repository.avancer(voyageId: 7, gareId: 3);

    expect((await voyageEnCache()).peutRepartir, isTrue);
  });

  test('AU TERMINUS, le départ n\'est pas proposé', () async {
    /*
      Le car ne repart pas d'un terminus : c'est la fin de la course. Le serveur le refuse
      ('DepartGareService'), et ne propose donc jamais le geste ('CommercialEspaceController'). La
      correction locale doit appliquer la même règle — sinon le vendeur voit « Départ enregistré »,
      puis découvre un refus au journal des opérations.
    */
    await repository.avancer(voyageId: 7, gareId: 4);

    final voyage = await voyageEnCache();
    expect(voyage.garecouranteId, 4);
    expect(voyage.peutRepartir, isFalse);
    expect(voyage.prochainArret, isNull, reason: 'et plus aucune arrivée à déclarer non plus');
  });

  test('un départ déclaré sans réseau part en file et retire le bouton', () async {
    await repository.avancer(voyageId: 7, gareId: 3);
    await repository.repartir(7);

    final enFile = await file.enAttente(7);
    expect(enFile.map((o) => o.type), [TypeOperation.POSITION, TypeOperation.DEPART]);
    expect(
      enFile.last.payload,
      isEmpty,
      reason: 'la gare n\'est pas transmise : le serveur repart de la position que le lot vient '
          'de poser',
    );

    expect((await voyageEnCache()).peutRepartir, isFalse);
  });

  test('les gestes portent l\'horodatage du téléphone', () async {
    final avant = DateTime.now().subtract(const Duration(seconds: 1));
    await repository.avancer(voyageId: 7, gareId: 3);

    // Il fait foi côté serveur : l'heure de la synchronisation donnerait un temps d'arrêt en gare
    // fantaisiste, et c'est précisément ce que ces gestes servent à mesurer.
    expect((await file.enAttente(7)).single.instant.isAfter(avant), isTrue);
  });
}

/// Un serveur injoignable : toutes les écritures échouent comme une coupure réseau.
class _RemoteHorsLigne extends VoyageRemoteDataSource {
  _RemoteHorsLigne() : super(Dio());

  static const _coupure = ApiException(
    'Impossible de joindre le serveur. Vérifiez votre connexion',
    estHorsLigne: true,
  );

  @override
  Future<List<VoyageCommercial>> mesVoyages() async => throw _coupure;

  @override
  Future<void> avancer({required int voyageId, required int gareId}) async => throw _coupure;

  @override
  Future<void> repartir(int voyageId) async => throw _coupure;
}
