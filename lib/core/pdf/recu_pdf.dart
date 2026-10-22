import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../formatting/formatters.dart';
import 'format_impression.dart';

/// Données d'un reçu/billet, en primitives — indépendantes de toute feature
/// (le reçu est produit aussi bien à la vente qu'à la réimpression). Le PDF
/// reproduit le ticket thermique du front web (`mails/ticket/thermalpdf.html.twig`).
class RecuData {
  const RecuData({
    required this.codeticket,
    this.prixNet,
    this.remise = 0,
    this.monteeLibelle,
    this.descenteLibelle,
    this.codevoyage,
    this.numerodepart,
    this.vehicule,
    this.dateDepart,
    this.dateEmission,
    this.siege,
    this.nomclient,
    this.statut,
    this.sigle = 'BILLET',
    this.compagnie = 'Compagnie de transport',
    this.telephones = '',
  });

  final String codeticket;
  final int? prixNet; // net payé (tarif - remise)
  final int remise;
  final String? monteeLibelle;
  final String? descenteLibelle;
  final String? codevoyage;
  /// Numéro de départ DU JOUR : la case que le passager lit face à son siège.
  final int? numerodepart;
  final String? vehicule; // matricule du car
  final DateTime? dateDepart;
  final DateTime? dateEmission;
  final String? siege;
  final String? nomclient;
  final String? statut; // VALIDE | REPORTE | ANNULE

  final String sigle;
  final String compagnie;
  final String telephones;

  /// TARIF affiché sur le billet = prix net + remise (le brut, comme le FT).
  int get tarifBrut => (prixNet ?? 0) + remise;

  bool get estAnnuleOuReporte => statut == 'ANNULE' || statut == 'REPORTE';
}

/// Construit le reçu au format ticket 80 mm, fidèle au thermique du front web :
/// en-tête sigle/gare, trajet, grille voyage/siège, tarif, véhicule, QR, souche
/// détachable. N'utilise que les polices standard (Latin-1) : on évite les
/// glyphes hors Latin-1 (« → », « – ») au profit d'équivalents ASCII.
///
/// LA SOUCHE PART SUR SA PROPRE PAGE (20/10/2026), comme sur le web. Une imprimante
/// thermique n'a pas de peigne de perforation, seulement une lame, et cette lame ne
/// tombe qu'en FIN DE PAGE : deux pages est le seul moyen d'obtenir le billet « presque
/// coupé » qui se détache sans se déchirer. Vérifié sur une EPSON TM-T20III, poste réglé
/// en rouleau continu avec « Paper Cut » sur `Page[Alim., Coup.]`.
///
/// Contrairement au PDF du web, ici les deux pages ont chacune LEUR hauteur : le format
/// rouleau du paquet `pdf` n'impose pas de hauteur, la page s'arrête au contenu.
///
/// `soucheDetachable: false` ramène tout sur une page — le recours pour un terminal dont
/// le pilote coupe par document, où la seconde page ne ferait qu'avancer le papier.
Future<Uint8List> buildRecuPdf(
  RecuData d, {
  bool soucheDetachable = true,
  FormatImpression format = FormatImpression.thermique80,
}) async {
  final doc = pw.Document(title: 'Billet ${d.codeticket}', author: 'iTransport');

  /*
    LE REPLI SUIT LE RÉGLAGE DE PAPIER (21/10/2026). Il sortait toujours en 80 mm : sur un
    terminal large, le vendeur retrouvait le billet minuscule du 20/10/2026 dès qu'il perdait le
    réseau — c'est-à-dire en route, là où il vend le plus.

    'k()' met une dimension à l'échelle du format. TOUT y passe — polices, interlettres,
    épaisseurs de trait, marges intérieures, QR — sauf les marges de PAGE, qui décrivent la zone
    que la tête sait écrire et non la taille du texte (cf. 'FormatImpression').
  */
  double k(double v) => v * format.echelle;

  final montee = d.monteeLibelle ?? '-';
  final descente = d.descenteLibelle ?? '-';
  final depart =
      d.dateDepart != null ? Formatters.dateTime(d.dateDepart) : '-';
  final emisle =
      d.dateEmission != null ? Formatters.dateTime(d.dateEmission) : '';
  final tarif = '${Formatters.number(d.tarifBrut)} FCFA';

  pw.Widget centre(String t, {double size = 8.5, bool bold = false,
          double spacing = 0, PdfColor? color, double top = 0}) =>
      pw.Padding(
        padding: pw.EdgeInsets.only(top: k(top)),
        child: pw.Center(
          child: pw.Text(t,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: k(size),
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                letterSpacing: k(spacing),
                color: color,
              )),
        ),
      );

  pw.Widget sep() => pw.Padding(
        padding: pw.EdgeInsets.symmetric(vertical: k(4)),
        child: pw.Divider(
            height: k(1), thickness: k(0.5), borderStyle: pw.BorderStyle.dashed),
      );

  // En-tête : sigle (gauche) / émission + gare émettrice (droite).
  pw.Widget entete(String sigleTexte, double sigleSize) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(sigleTexte,
                style: pw.TextStyle(
                    fontSize: k(sigleSize),
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: k(1))),
            pw.Container(
                width: k(sigleSize * 3.5),
                margin: pw.EdgeInsets.only(top: k(2)),
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(width: k(1.5), style: pw.BorderStyle.dotted)))),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            if (emisle.isNotEmpty)
              pw.Text(emisle, style: pw.TextStyle(fontSize: k(7.5))),
            pw.Text(montee,
                style: pw.TextStyle(fontSize: k(8), fontWeight: pw.FontWeight.bold)),
          ]),
        ],
      );

  // Grille à deux cases (DEPART numéro | SIÈGE numéro), comme le thermique du web.
  pw.Widget grille({required double keySize, required double valSize}) {
    pw.Widget box(String cle, String v) => pw.Expanded(
          child: pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: k(4), horizontal: k(2)),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: k(0.7))),
            child: pw.Column(children: [
              pw.Text(cle,
                  style: pw.TextStyle(fontSize: k(keySize), letterSpacing: k(1))),
              pw.Text(v,
                  style: pw.TextStyle(
                      fontSize: k(valSize), fontWeight: pw.FontWeight.bold)),
            ]),
          ),
        );
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: k(5)),
      child: pw.Row(children: [
        box('DEPART', d.numerodepart?.toString() ?? '-'),
        pw.SizedBox(width: k(14)),
        box('SIEGE', d.siege ?? '-'),
      ]),
    );
  }

  final billet = <pw.Widget>[
    entete(d.sigle, 18),
    if (d.estAnnuleOuReporte)
      pw.Container(
        margin: pw.EdgeInsets.symmetric(vertical: k(5)),
        padding: pw.EdgeInsets.symmetric(vertical: k(3)),
        color: PdfColors.black,
        child: pw.Center(
          child: pw.Text(
              d.statut == 'ANNULE' ? 'BILLET ANNULE' : 'BILLET REPORTE',
              style: pw.TextStyle(
                  fontSize: k(11),
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: k(2))),
        ),
      ),
    centre('Ticket no : ${d.codeticket}', size: 9, top: 5),
    centre('Depart : $depart', size: 10, bold: true, top: 2),
    centre('VOYAGE', size: 8, spacing: 2, top: 5),
    centre('$montee\n$descente', size: 13, bold: true, top: 2),
    grille(keySize: 7.5, valSize: 16),
    centre('TARIF : $tarif', size: 12, bold: true, top: 3),
    // Le VÉHICULE a cédé sa ligne au CODE VOYAGE, que la case du haut a laissé partir pour
    // afficher le numéro de départ (même échange que 'mails/ticket/thermalpdf.html.twig'
    // côté web, recalé sur le ticket de référence). Conservé en commentaire : un format
    // d'impression se règle sur du papier, pas sur un écran.
    // centre('Vehicule : ${d.vehicule ?? '-'}', size: 9, top: 2),
    centre('Voyage : ${d.codevoyage ?? '-'}', size: 9, top: 2),
    sep(),
    centre('NB : Le ticket n\'est pas remboursable', size: 8),
    pw.SizedBox(height: k(6)),
    pw.Center(
      child: pw.BarcodeWidget(
        barcode: pw.Barcode.qrCode(),
        data: d.codeticket,
        width: k(72),
        height: k(72),
        drawText: false,
      ),
    ),
    centre('Presentez ce billet a l\'embarquement', size: 7.5, top: 3),
    sep(),
    centre('${d.compagnie} vous souhaite un agreable voyage', size: 8.5),
    if (d.telephones.isNotEmpty)
      centre(d.telephones, size: 8.5, bold: true, top: 1),
    centre('Edite par iTransport', size: 6.5, color: PdfColors.grey600, top: 3),
    // Le repère reste imprimé même quand la coupe tombe ici : sur un terminal dont le
    // pilote ne coupe pas à chaque page, il est le seul guide pour détacher droit.
    centre('DETACHER ICI', size: 6.5, spacing: 2, top: 7),
    if (!soucheDetachable)
      pw.Padding(
        padding: pw.EdgeInsets.only(top: k(1), bottom: k(8)),
        child: pw.Divider(
            height: k(1), thickness: k(0.7), borderStyle: pw.BorderStyle.dashed),
      ),
  ];

  final souche = <pw.Widget>[
    entete(d.sigle, 12),
    centre('Ticket no : ${d.codeticket}', size: 8, top: 3),
    centre('Depart : $depart', size: 8),
    centre('$montee - $descente', size: 9, bold: true, top: 2),
    grille(keySize: 7, valSize: 11),
    centre('Tarif : $tarif', size: 8),
    // Idem sur la souche (cf. le billet ci-dessus).
    // centre('Vehicule : ${d.vehicule ?? '-'}', size: 8),
    centre('Voyage : ${d.codevoyage ?? '-'}', size: 8),
  ];

  pw.Page feuille(List<pw.Widget> contenu) => pw.Page(
        pageFormat: format.papier,
        margin: pw.EdgeInsets.symmetric(
          horizontal: format.margeHorizontalePt,
          vertical: format.margeVerticalePt,
        ),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: contenu,
        ),
      );

  if (soucheDetachable) {
    doc.addPage(feuille(billet));
    doc.addPage(feuille(souche));
  } else {
    doc.addPage(feuille([...billet, ...souche]));
  }

  return doc.save();
}
