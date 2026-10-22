import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:commercialflutter/core/pdf/bagage_recu_pdf.dart';
import 'package:commercialflutter/core/pdf/format_impression.dart';
import 'package:commercialflutter/core/pdf/recu_pdf.dart';

/// LA SOUCHE PART SUR SA PROPRE PAGE (20/10/2026).
///
/// Une imprimante thermique n'a pas de peigne de perforation, seulement une lame, et cette lame
/// ne tombe qu'en FIN DE PAGE. Mettre la souche sur une page à elle est donc le seul moyen
/// d'obtenir le billet « presque coupé » que le commercial détache sans le déchirer — vérifié sur
/// une EPSON TM-T20III, poste réglé en rouleau continu avec « Paper Cut » sur `Page[Alim., Coup.]`.
///
/// Ce découpage ne se voit nulle part à l'écran : un billet à une page et un billet à deux pages
/// se ressemblent dans l'aperçu, et c'est seulement au guichet, le rouleau à la main, qu'on
/// découvre que la coupe ne tombe pas au bon endroit. D'où ces sentinelles.
void main() {
  // 'Formatters' compose les dates en 'fr_FR' ; sans ce chargement, 'DateFormat' lève une
  // LocaleDataException dès la première date du billet. 'main.dart' le fait au démarrage.
  setUpAll(() => initializeDateFormatting('fr_FR'));

  RecuData recu({String statut = 'VALIDE'}) => RecuData(
        codeticket: 'LI-ABI-KOR-0001-V35-TCK-2026-5',
        prixNet: 12000,
        monteeLibelle: "Gare d'Adjame",
        descenteLibelle: 'Gare de Bouake',
        codevoyage: 'LI-ABI-KOR-0001-V35',
        numerodepart: 4,
        dateDepart: DateTime(2026, 10, 21, 7),
        dateEmission: DateTime(2026, 10, 20, 10, 13),
        siege: '23',
        nomclient: 'Konan Aya Mariam',
        statut: statut,
        sigle: 'IRA',
        compagnie: 'IRA Transport',
      );

  BagageRecuData recuBagage() => const BagageRecuData(
        codebagage: 'LI-ABI-KOR-0001-V35-BAG-2026-7',
        nature: 'Valise',
        type: 'LOURD',
        poids: 23,
        montant: 2500,
        statut: 'DEPOSE',
        nomclient: 'Konan Aya Mariam',
        contactclient: '+225 07 00 00 00 07',
        codeticket: 'LI-ABI-KOR-0001-V35-TCK-2026-5',
        codevoyage: 'LI-ABI-KOR-0001-V35',
        monteeLibelle: "Gare d'Adjame",
        descenteLibelle: 'Gare de Bouake',
        sigle: 'IRA',
        compagnie: 'IRA Transport',
      );

  test('par defaut, le billet et sa souche sont sur DEUX pages', () async {
    expect(nombreDePages(await buildRecuPdf(recu())), 2);
  });

  test('un billet annule garde ses deux pages : le bandeau ne doit pas en ajouter une',
      () async {
    // Le bandeau « BILLET ANNULE » allonge le billet ; sur un format rouleau la page s'étire,
    // elle ne déborde pas. Si une troisième page apparaissait, la lame couperait en plein milieu.
    expect(nombreDePages(await buildRecuPdf(recu(statut: 'ANNULE'))), 2);
  });

  test('soucheDetachable: false ramene tout sur une seule page', () async {
    // Le recours pour un terminal dont le pilote coupe par DOCUMENT et non par page : la seconde
    // page ne ferait alors qu'avancer le papier sans être coupée.
    expect(nombreDePages(await buildRecuPdf(recu(), soucheDetachable: false)), 1);
  });

  test('le repere de detachement est imprime dans les deux modes', () async {
    // Sans coupe à chaque page, ce repère est le seul guide pour détacher droit.
    for (final detachable in [true, false]) {
      final texte = contenuLisible(
        await buildRecuPdf(recu(), soucheDetachable: detachable),
      );
      expect(
        texte.contains('DETACHER ICI'),
        isTrue,
        reason: 'repere absent avec soucheDetachable: $detachable',
      );
    }
  });
  group('Le papier réglé sur l\'appareil (21/10/2026)', () {
    /*
      LE REPLI SORTAIT TOUJOURS EN 80 MM. Le billet et le reçu du serveur suivent le réglage
      « Mon imprimante » depuis le 20/10/2026 ; composés ici, ils l'ignoraient. Le vendeur réglé
      sur un terminal large retrouvait donc l'écriture minuscule dès qu'il perdait le réseau —
      c'est-à-dire en route, là où il vend le plus.

      !! ON MESURE LE PDF, PAS LE CODE. Deux choses doivent bouger ensemble et rien ne le dit à
         l'écran : la LARGEUR DE PAGE (une page large avec une écriture de 80 mm laisse le billet
         dans un coin) et la TAILLE DES CARACTÈRES (une écriture agrandie sur une page de 80 mm
         déborde de la laize). D'où deux mesures, et non une.

      !! CE QUI N'EST PAS MESURABLE ICI : la MARGE. Le paquet `pdf` pose ses rectangles et ses
         textes en coordonnées RELATIVES à une matrice de transformation — toutes à zéro dans le
         flux —, il faudrait suivre les `cm` pour en déduire une position absolue. La marge est
         donc gardée ailleurs, et par une comparaison plutôt que par une mesure :
         `Backend-Transport/tests/Domain/ContratImpressionTest.php` lit ce que
         `format_impression.dart` DÉCLARE et le confronte aux constantes de `PdfService`, qui est
         l'autorité — c'est lui qui rend le même billet pour le guichet et le web.
    */
    test('le billet large élargit la page ET agrandit l\'écriture', () async {
      final etroit = await buildRecuPdf(recu());
      final large = await buildRecuPdf(recu(), format: FormatImpression.large);

      expect(largeurDePage(etroit), closeTo(226.8, 1), reason: '80 mm');
      expect(largeurDePage(large), closeTo(419.5, 1), reason: '148 mm');
      expect(
        plusGrandeEcriture(large),
        greaterThan(plusGrandeEcriture(etroit) * 1.5),
        reason: 'la page a changé de laize sans que le texte suive',
      );
      expect(nombreDePages(large), 2, reason: 'la souche reste sur sa propre page');
    });

    test('le reçu de bagage suit le même papier', () async {
      // Un billet lisible accompagné d'un reçu minuscule serait lu comme un défaut, pas comme
      // une subtilité : les deux papiers sortent de la même machine.
      final etroit = await buildBagageRecuPdf(recuBagage());
      final large = await buildBagageRecuPdf(recuBagage(), format: FormatImpression.large);

      expect(largeurDePage(etroit), closeTo(226.8, 1));
      expect(largeurDePage(large), closeTo(419.5, 1));
      expect(
        plusGrandeEcriture(large),
        greaterThan(plusGrandeEcriture(etroit) * 1.5),
      );
    });
  });
}

/// Le nombre de pages, lu dans les octets : le paquet `pdf` ne l'expose pas après coup.
int nombreDePages(Uint8List octets) {
  final brut = String.fromCharCodes(octets);

  return RegExp(r'/Type\s*/Page[^s]').allMatches(brut).length;
}

/// Le texte réellement posé sur la page, mot à mot.
///
/// Deux pièges, tous deux rencontrés en écrivant ces sentinelles :
///
///   1. LES FLUX DE CONTENU SONT COMPRESSÉS. Chercher la chaîne dans les octets bruts ne trouve
///      rien, et la sentinelle échoue pour une raison qui n'a rien à voir avec le billet.
///   2. LE TEXTE EST DÉCOUPÉ MOT PAR MOT. Le paquet `pdf` pose chaque mot à sa propre abscisse :
///      « DETACHER ICI » s'écrit `[(DETACHER)]TJ … [(ICI)]TJ`, et la chaîne entière est introuvable.
///
/// On décompresse donc, puis on recolle les littéraux avec un espace.
String contenuLisible(Uint8List octets) {
  final mots = RegExp(r'\[\(([^)]*)\)\]\s*TJ')
      .allMatches(fluxDecompresses(octets))
      .map((m) => m.group(1) ?? '');

  return mots.join(' ');
}

/// Les flux de contenu du PDF, décompressés et mis bout à bout.
String fluxDecompresses(Uint8List octets) {
  final brut = String.fromCharCodes(octets);
  final morceaux = StringBuffer();

  for (final debut in RegExp('stream').allMatches(brut)) {
    final fin = brut.indexOf('endstream', debut.end);
    if (fin < 0) {
      continue;
    }

    // Le mot-clé « stream » est suivi d'un saut de ligne qui ne fait PAS partie du flux ;
    // le laisser dedans fait échouer zlib, et le repli sur les octets bruts masque l'échec.
    var ouvre = debut.end;
    while (ouvre < fin && (octets[ouvre] == 13 || octets[ouvre] == 10)) {
      ouvre++;
    }

    final flux = octets.sublist(ouvre, fin);
    try {
      morceaux.write(String.fromCharCodes(zlib.decode(flux)));
    } catch (_) {
      morceaux.write(String.fromCharCodes(flux));
    }
  }

  return morceaux.toString();
}

/// La largeur de page, lue dans le `/MediaBox` : il n'est pas compressé, lui.
double largeurDePage(Uint8List octets) {
  final boite = RegExp(r'/MediaBox\s*\[\s*[\d.]+\s+[\d.]+\s+([\d.]+)')
      .firstMatch(String.fromCharCodes(octets));

  return double.parse(boite!.group(1)!);
}

/// La plus grande écriture posée sur la page.
///
/// L'opérateur `Tf` des flux de contenu porte la taille réellement utilisée — c'est la seule
/// façon de distinguer un billet agrandi d'un billet qu'on a seulement posé sur un papier plus
/// large. Les flux étant compressés, on réutilise le décodeur ci-dessus.
double plusGrandeEcriture(Uint8List octets) => RegExp(r'/F\d+\s+([\d.]+)\s+Tf')
    .allMatches(fluxDecompresses(octets))
    .map((m) => double.parse(m.group(1)!))
    .reduce((a, b) => a > b ? a : b);
