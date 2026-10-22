import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:commercialflutter/features/auth/presentation/providers/auth_providers.dart';
import 'package:commercialflutter/core/pdf/format_impression.dart';
import 'package:commercialflutter/core/pdf/impression_distante.dart';
import 'package:commercialflutter/core/pdf/impression_providers.dart';
import 'package:commercialflutter/core/pdf/bagage_recu_pdf.dart';
import 'package:commercialflutter/core/pdf/recu_pdf.dart';

/// LE DOCUMENT VIENT DU SERVEUR, LE RENDU LOCAL EST UN REPLI (20/10/2026).
///
/// Le billet et le reçu de bagage étaient composés ici, dans le front web et dans les deux apps
/// de réservation : quatre maquettes du même papier. Elles ont rejoint leurs données, et l'app
/// n'en garde qu'une — pour le cas où il n'y a pas de réseau, qui est le quotidien d'un commercial
/// à bord d'un car.
///
/// !! C'EST LA DÉCISION DE BASCULE QUE CES SENTINELLES TIENNENT, et elle ne se voit nulle part à
///    l'écran : un billet rendu par le serveur et un billet composé ici se ressemblent. Si la
///    bascule se faisait à l'envers — repli systématique, ou appel réseau sur une vente hors
///    ligne — on ne s'en apercevrait qu'au comptoir, des semaines plus tard, devant deux papiers
///    qui ne se ressemblent plus.
///
/// Quatre cas, et le quatrième est le moins évident : une erreur qui N'EST PAS un défaut de
/// réseau ne doit pas faire imprimer le document local. Composer un papier en réponse à un refus
/// du serveur reviendrait à imprimer ce qu'il vient d'interdire.
void main() {
  // Les generateurs locaux composent leurs dates en 'fr_FR' ; sans ce chargement, 'DateFormat'
  // leve des la premiere date. 'main.dart' le fait au demarrage de l'application.
  setUpAll(() => initializeDateFormatting('fr_FR'));

  final pdfDuServeur = Uint8List.fromList('%PDF-1.7 du serveur'.codeUnits);

  RecuData billetDeSecours() => const RecuData(
        codeticket: 'TCK-HORS-LIGNE-1',
        sigle: 'IRA',
        compagnie: 'IRA Transport',
      );

  group('ImpressionDistante', () {
    test('rend les octets du serveur quand il répond un PDF', () async {
      final service = ImpressionDistante(_dio(_Reponse.pdf(pdfDuServeur)));

      expect(await service.billet(42), pdfDuServeur);
    });

    test('rend null hors ligne, pour que l\'appelant compose lui-même', () async {
      final service = ImpressionDistante(_dio(_Reponse.horsLigne()));

      expect(await service.billet(42), isNull);
    });

    test('rend null si la réponse n\'est pas un PDF', () async {
      // Une page d'erreur HTML ou une réponse tronquée partirait sinon à l'imprimante comme un
      // document : le vendeur verrait sortir du charabia sans savoir d'où il vient.
      final service = ImpressionDistante(_dio(_Reponse.pdf(Uint8List.fromList('<html>'.codeUnits))));

      expect(await service.billet(42), isNull);
    });

    test('laisse remonter une erreur qui n\'est PAS un défaut de réseau', () async {
      final service = ImpressionDistante(_dio(_Reponse.refus(403)));

      expect(() => service.billet(42), throwsA(isA<DioException>()));
    });

    test('demande le format large quand on le lui dit', () async {
      final espion = _Reponse.pdf(pdfDuServeur);
      final service = ImpressionDistante(_dio(espion));

      await service.billet(42, large: true);
      expect(espion.derniersParametres, {'format': 'large'});

      await service.billet(42);
      expect(espion.derniersParametres, isNull, reason: 'le thermique est le défaut, sans paramètre');
    });
  });

  group('RecuImprimable', () {
    test('sans identifiant serveur, le billet est composé ici sans appeler le réseau', () async {
      /*
        Le cas d'une vente HORS LIGNE : le billet n'a qu'un code, définitif, et attend dans la
        file de synchronisation. Il n'y a rien à demander au serveur, même avec du réseau — et
        l'appeler quand même ferait attendre le vendeur pour un 404.
      */
      final espion = _Reponse.pdf(pdfDuServeur);
      final imprimable = RecuImprimable(ImpressionDistante(_dio(espion)));

      final octets = await imprimable.billet(id: null, repli: billetDeSecours());

      expect(espion.appels, 0, reason: 'aucun appel ne doit partir sans identifiant');
      expect(String.fromCharCodes(octets.sublist(0, 4)), '%PDF');
      expect(octets, isNot(pdfDuServeur), reason: 'le document doit être celui composé ici');
    });

    test('avec identifiant et réseau, le billet est celui du serveur', () async {
      final imprimable = RecuImprimable(ImpressionDistante(_dio(_Reponse.pdf(pdfDuServeur))));

      expect(await imprimable.billet(id: 42, repli: billetDeSecours()), pdfDuServeur);
    });

    test('avec identifiant mais sans réseau, on retombe sur le rendu local', () async {
      final imprimable = RecuImprimable(ImpressionDistante(_dio(_Reponse.horsLigne())));

      final octets = await imprimable.billet(id: 42, repli: billetDeSecours());

      expect(String.fromCharCodes(octets.sublist(0, 4)), '%PDF');
      expect(octets, isNot(pdfDuServeur));
    });

    test('le reçu de bagage suit la même règle', () async {
      const repli = BagageRecuData(codebagage: 'BAG-1', sigle: 'IRA', compagnie: 'IRA Transport');
      final espion = _Reponse.pdf(pdfDuServeur);
      final imprimable = RecuImprimable(ImpressionDistante(_dio(espion)));

      expect(await imprimable.bagage(id: 7, repli: repli), pdfDuServeur);

      final sansId = await imprimable.bagage(id: null, repli: repli);
      expect(sansId, isNot(pdfDuServeur));
      expect(espion.appels, 1, reason: 'le second appel ne doit pas partir');
    });
  });

  group("Format réglé sur l'appareil", () {
    /*
      LE FORMAT VIENT DU RÉGLAGE DE L'APPAREIL (21/10/2026), parce que le serveur ne peut pas le
      deviner : il dépend de la machine posée devant l'agent, pas de l'entreprise ni de la gare.
      Un billet composé pour 80 mm paraît minuscule sur un terminal large — le défaut constaté le
      20/10/2026 — et un billet large sur une thermique de 80 mm ne tiendrait pas dans la laize.

      !! CE QUE CES SENTINELLES TIENNENT NE SE VOIT PAS À L'ÉCRAN. Les deux papiers portent les
         mêmes mentions ; seule leur taille diffère. Un réglage qui n'arrive pas jusqu'à la requête
         ne se remarquerait qu'au comptoir, en comparant deux billets.
    */
    test('une clé inconnue retombe sur le thermique, jamais sur rien', () {
      expect(FormatImpression.depuisCle(null), FormatImpression.thermique80);
      expect(FormatImpression.depuisCle('format_dune_version_future'), FormatImpression.thermique80);
      expect(FormatImpression.depuisCle('large'), FormatImpression.large);
      expect(FormatImpression.depuisCle('thermique80'), FormatImpression.thermique80);
    });

    test('réglé en large, le billet est demandé en large', () async {
      final espion = _Reponse.pdf(pdfDuServeur);
      final imprimable = RecuImprimable(
        ImpressionDistante(_dio(espion)),
        format: () async => FormatImpression.large,
      );

      await imprimable.billet(id: 42, repli: billetDeSecours());

      expect(espion.derniersParametres, {'format': 'large'});
    });

    test('réglé en thermique, aucun format ne part', () async {
      final espion = _Reponse.pdf(pdfDuServeur);
      final imprimable = RecuImprimable(
        ImpressionDistante(_dio(espion)),
        format: () async => FormatImpression.thermique80,
      );

      await imprimable.billet(id: 42, repli: billetDeSecours());

      expect(espion.derniersParametres, isNull);
    });

    test('le reçu de bagage part dans le même format que le billet', () async {
      // Un billet lisible accompagné d'un reçu minuscule serait lu comme un défaut : les deux
      // papiers sortent de la même machine, donc du même réglage.
      final espion = _Reponse.pdf(pdfDuServeur);
      final imprimable = RecuImprimable(
        ImpressionDistante(_dio(espion)),
        format: () async => FormatImpression.large,
      );

      await imprimable.bagage(
        id: 7,
        repli: const BagageRecuData(codebagage: 'BAG-1', sigle: 'IRA', compagnie: 'IRA Transport'),
      );

      expect(espion.derniersParametres, {'format': 'large'});
    });

    test('le réglage est branché sur le provider, et pas seulement sur la classe', () async {
      /*
        La sentinelle du câblage : `RecuImprimable` sait lire un format, mais si
        `recuImprimableProvider` oubliait de le lui donner, les trois écrans imprimeraient en
        thermique quoi qu'on règle — et les deux tests ci-dessus resteraient verts.
      */
      final espion = _Reponse.pdf(pdfDuServeur);
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(_dio(espion)),
          lectureFormatProvider.overrideWithValue(() async => FormatImpression.large),
        ],
      );
      addTearDown(container.dispose);

      await container.read(recuImprimableProvider).billet(id: 42, repli: billetDeSecours());

      expect(espion.derniersParametres, {'format': 'large'});
    });
  });
}

Dio _dio(_Reponse reponse) {
  final dio = Dio(BaseOptions(baseUrl: 'https://exemple.test'));
  dio.httpClientAdapter = reponse;

  return dio;
}

/// Un adaptateur HTTP de test : il rend ce qu'on lui a dit, et retient ce qu'on lui a demandé.
///
/// Écrit à la main plutôt qu'avec une bibliothèque de doublures : le projet n'en embarque aucune,
/// et ce dont on a besoin ici tient en vingt lignes.
class _Reponse implements HttpClientAdapter {
  _Reponse._({this.octets, this.statut = 200, this.coupure = false});

  factory _Reponse.pdf(Uint8List octets) => _Reponse._(octets: octets);

  factory _Reponse.horsLigne() => _Reponse._(coupure: true);

  factory _Reponse.refus(int statut) => _Reponse._(statut: statut, octets: Uint8List(0));

  final Uint8List? octets;
  final int statut;
  final bool coupure;

  int appels = 0;
  Map<String, dynamic>? derniersParametres;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    appels++;
    derniersParametres = options.queryParameters.isEmpty ? null : options.queryParameters;

    if (coupure) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'pas de reseau',
      );
    }

    if (statut >= 400) {
      throw DioException.badResponse(
        statusCode: statut,
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: statut),
      );
    }

    return ResponseBody.fromBytes(octets ?? Uint8List(0), statut);
  }

  @override
  void close({bool force = false}) {}
}
