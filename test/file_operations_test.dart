import 'package:commercialflutter/core/offline/base_locale.dart';
import 'package:commercialflutter/core/offline/codes_hors_ligne.dart';
import 'package:commercialflutter/core/offline/file_operations.dart';
import 'package:commercialflutter/core/offline/operation_hors_ligne.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_common_ffi.dart';

/// La file des ventes hors ligne.
///
/// Ce que ces tests protègent : **une vente encaissée ne se perd pas et ne se duplique pas.** Le
/// vendeur a pris de l'argent et remis un reçu imprimé ; tout ce qui suit doit préserver ces deux
/// faits, y compris après une coupure, un redémarrage ou un rejeu.
void main() {
  setUpAll(() {
    // sqflite vise Android/iOS ; en test, l'implémentation FFI fournit le même SQLite sur le poste.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late BaseLocale base;
  late FileOperations file;

  setUp(() async {
    base = await BaseLocale.ouvrir(chemin: inMemoryDatabasePath);
    file = FileOperations(base);
  });

  tearDown(() async => base.fermer());

  OperationHorsLigne vente(String reference, {int voyageId = 7, int siege = 1}) =>
      OperationHorsLigne(
        reference: reference,
        voyageId: voyageId,
        type: TypeOperation.VENTE,
        instant: DateTime(2026, 9, 12, 8, 30),
        payload: {'siege': siege, 'codeticket': 'LI-V1-TCK-2026-B1'},
        statut: BaseLocale.enAttente,
        creeLe: DateTime(2026, 9, 12, 8, 30),
      );

  OperationHorsLigne bagage(String reference, {int voyageId = 7}) => OperationHorsLigne(
        reference: reference,
        voyageId: voyageId,
        type: TypeOperation.BAGAGE,
        instant: DateTime(2026, 9, 12, 8, 35),
        payload: {
          'codebagage': 'LI-V1-BAG-2026-B1',
          'codeticket': 'LI-V1-TCK-2026-B1',
          'nature': 'valise',
          'type': 'LOURD',
          'poids': 25,
          'montantEncaisse': 2000,
        },
        statut: BaseLocale.enAttente,
        creeLe: DateTime(2026, 9, 12, 8, 35),
      );

  test('une opération mise en file est relue à l\'identique', () async {
    await file.mettreEnFile(vente('ref-1'));

    final attente = await file.enAttente(7);
    expect(attente, hasLength(1));
    expect(attente.first.reference, 'ref-1');
    expect(attente.first.payload['siege'], 1);
    expect(
      attente.first.instant,
      DateTime(2026, 9, 12, 8, 30),
      reason: 'l\'horodatage du téléphone survit au stockage : c\'est lui qui fait foi côté serveur',
    );
  });

  test('l\'ordre d\'émission est conservé', () async {
    // Il compte : une vente faite depuis une gare doit remonter avant l'arrivée à la suivante.
    for (final r in ['a', 'b', 'c']) {
      await file.mettreEnFile(vente(r));
    }

    expect(
      (await file.enAttente(7)).map((o) => o.reference),
      ['a', 'b', 'c'],
    );
  });

  test('une référence ne peut pas entrer deux fois en file', () async {
    await file.mettreEnFile(vente('ref-1'));

    // La contrainte d'unicité est la même que celle du serveur : c'est elle qui rend un rejeu sûr.
    expect(() => file.mettreEnFile(vente('ref-1')), throwsA(isA<Exception>()));
  });

  test('une opération synchronisée sort de la file, une refusée garde son motif', () async {
    await file.mettreEnFile(vente('ref-ok'));
    await file.mettreEnFile(vente('ref-ko', siege: 2));

    await file.marquer('ref-ok', statut: BaseLocale.synchronisee);
    await file.marquer('ref-ko', statut: BaseLocale.refusee, motif: 'Siège inconnu');

    expect(await file.enAttente(7), isEmpty, reason: 'plus rien à envoyer');
    expect(await file.nombreEnAttente(), 0);

    final refusee = (await file.toutes(7)).firstWhere((o) => o.reference == 'ref-ko');
    expect(
      refusee.motif,
      'Siège inconnu',
      reason: 'le vendeur a encaissé : il doit pouvoir montrer ce qui s\'est passé, pas un trou',
    );
  });

  test('la file d\'un voyage ignore celle d\'un autre', () async {
    await file.mettreEnFile(vente('ref-1'));
    await file.mettreEnFile(vente('ref-2', voyageId: 8));

    expect(await file.enAttente(7), hasLength(1));
    expect(await file.nombreEnAttente(), 2, reason: 'le bandeau compte tout, lui');
  });

  test('l\'instantané se remplace, il ne s\'empile pas', () async {
    await file.enregistrerInstantane(7, {'voyage': {'codevoyage': 'LI-V1'}});
    await file.enregistrerInstantane(7, {'voyage': {'codevoyage': 'LI-V2'}});

    final instantane = await file.instantane(7);
    expect((instantane?['voyage'] as Map)['codevoyage'], 'LI-V2');
  });

  test('le code de billet suit une série propre au bord, sans repartir à zéro', () async {
    final codes = CodesHorsLigne(base);

    expect(await codes.billet(voyageId: 7, codevoyage: 'LI-V1'), endsWith('-B1'));

    await file.mettreEnFile(vente('ref-1'));
    expect(
      await codes.billet(voyageId: 7, codevoyage: 'LI-V1'),
      endsWith('-B2'),
      reason: 'le compteur se déduit de la file : il ne peut pas s\'en désynchroniser',
    );

    // Un autre voyage a sa propre série : un commercial par voyage, donc aucune collision possible.
    expect(await codes.billet(voyageId: 8, codevoyage: 'LI-V2'), endsWith('-B1'));
  });

  test('billets et bagages comptent chacun leur propre série', () async {
    final codes = CodesHorsLigne(base);

    await file.mettreEnFile(vente('ref-1'));
    await file.mettreEnFile(bagage('ref-2'));
    await file.mettreEnFile(vente('ref-3', siege: 2));

    // Deux ventes en file → le prochain billet est le 3e ; le bagage intercalé n'a rien décalé.
    expect(await codes.billet(voyageId: 7, codevoyage: 'LI-V1'), endsWith('-TCK-2026-B3'));
    expect(await codes.bagage(voyageId: 7, codevoyage: 'LI-V1'), endsWith('-BAG-2026-B2'));
  });

  test('la file signale ses écritures', () async {
    /*
      Sans ce signal, les compteurs de l'interface restaient figés sur ce qu'ils avaient lu à leur
      première construction : le vendeur encaissait trois billets hors ligne et le bandeau continuait
      d'annoncer « rien en attente », le journal des opérations restait vide. Une file invisible vaut
      une file perdue.
    */
    final signaux = <void>[];
    final abonnement = file.changements.listen(signaux.add);

    await file.mettreEnFile(vente('ref-1'));
    await file.marquer('ref-1', statut: BaseLocale.synchronisee);
    await Future<void>.delayed(Duration.zero);

    expect(signaux, hasLength(2), reason: 'une mise en file, puis un sort rendu');

    await abonnement.cancel();
  });

  test('le voyage en cache se corrige localement quand le car avance', () async {
    /*
      Mettre l'avance en file ne suffit pas : tout ce que le vendeur peut faire ensuite — les
      destinations proposées, le droit de vendre, le prochain arrêt — se déduit de 'garecouranteId'.
      Sans cette correction, il déclarerait l'arrivée à Korhogo et l'application le croirait encore
      à Bouaké, lui refusant les trajets qu'il doit justement vendre à partir de là.
    */
    await file.enregistrerVoyages([
      {
        'id': 7,
        'garecouranteId': 3,
        'garecouranteLibelle': 'Bouaké',
        'arrets': [
          {'id': 3, 'libelle': 'Bouaké', 'ordre': 2},
          {'id': 4, 'libelle': 'Korhogo', 'ordre': 3},
        ],
      },
      {'id': 8, 'garecouranteId': 1, 'garecouranteLibelle': 'Adjamé', 'arrets': <dynamic>[]},
    ]);

    await file.modifierVoyageEnCache(7, (voyage) => {...voyage, 'garecouranteId': 4});

    final cache = await file.voyages();
    expect(cache.firstWhere((v) => v['id'] == 7)['garecouranteId'], 4);
    expect(
      cache.firstWhere((v) => v['id'] == 8)['garecouranteId'],
      1,
      reason: 'les autres voyages ne bougent pas',
    );
  });

  test('le bagage désigne son billet par son CODE, pas par un identifiant', () async {
    // C'est tout l'enjeu : hors ligne le billet attend dans la même file et n'a aucun identifiant
    // serveur. Le code, lui, est imprimé sur le reçu du client dès la vente.
    await file.mettreEnFile(bagage('ref-b'));

    final remonte = (await file.enAttente(7)).first;
    expect(remonte.type, TypeOperation.BAGAGE);
    expect(remonte.payload['codeticket'], 'LI-V1-TCK-2026-B1');
    expect(remonte.payload.containsKey('id'), isFalse);
  });
}
