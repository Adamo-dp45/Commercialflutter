import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../formatting/formatters.dart';

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
Future<Uint8List> buildRecuPdf(RecuData d) async {
  final doc = pw.Document(title: 'Billet ${d.codeticket}', author: 'iTransport');

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
        padding: pw.EdgeInsets.only(top: top),
        child: pw.Center(
          child: pw.Text(t,
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: size,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
                letterSpacing: spacing,
                color: color,
              )),
        ),
      );

  pw.Widget sep() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Divider(
            height: 1, thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
      );

  // En-tête : sigle (gauche) / émission + gare émettrice (droite).
  pw.Widget entete(String sigleTexte, double sigleSize) => pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text(sigleTexte,
                style: pw.TextStyle(
                    fontSize: sigleSize,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1)),
            pw.Container(
                width: sigleSize * 3.5,
                margin: const pw.EdgeInsets.only(top: 2),
                decoration: const pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(width: 1.5, style: pw.BorderStyle.dotted)))),
          ]),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
            if (emisle.isNotEmpty)
              pw.Text(emisle, style: const pw.TextStyle(fontSize: 7.5)),
            pw.Text(montee,
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          ]),
        ],
      );

  // Grille à deux cases (DEPART numéro | SIÈGE numéro), comme le thermique du web.
  pw.Widget grille({required double keySize, required double valSize}) {
    pw.Widget box(String k, String v) => pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.7)),
            child: pw.Column(children: [
              pw.Text(k,
                  style: pw.TextStyle(fontSize: keySize, letterSpacing: 1)),
              pw.Text(v,
                  style: pw.TextStyle(
                      fontSize: valSize, fontWeight: pw.FontWeight.bold)),
            ]),
          ),
        );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(children: [
        box('DEPART', d.numerodepart?.toString() ?? '-'),
        pw.SizedBox(width: 14),
        box('SIEGE', d.siege ?? '-'),
      ]),
    );
  }

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // ══ BILLET ══
          entete(d.sigle, 18),
          if (d.estAnnuleOuReporte)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 5),
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              color: PdfColors.black,
              child: pw.Center(
                child: pw.Text(
                    d.statut == 'ANNULE' ? 'BILLET ANNULE' : 'BILLET REPORTE',
                    style: pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2)),
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
          pw.SizedBox(height: 6),
          pw.Center(
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: d.codeticket,
              width: 72,
              height: 72,
              drawText: false,
            ),
          ),
          centre('Presentez ce billet a l\'embarquement', size: 7.5, top: 3),
          sep(),
          centre('${d.compagnie} vous souhaite un agreable voyage', size: 8.5),
          if (d.telephones.isNotEmpty)
            centre(d.telephones, size: 8.5, bold: true, top: 1),
          centre('Edite par iTransport', size: 6.5, color: PdfColors.grey600, top: 3),

          // ══ SOUCHE (talon détachable) ══
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 8),
            child: pw.Divider(
                height: 1, thickness: 0.7, borderStyle: pw.BorderStyle.dashed),
          ),
          entete(d.sigle, 12),
          centre('Ticket no : ${d.codeticket}', size: 8, top: 3),
          centre('Depart : $depart', size: 8),
          centre('$montee - $descente', size: 9, bold: true, top: 2),
          grille(keySize: 7, valSize: 11),
          centre('Tarif : $tarif', size: 8),
          // Idem sur la souche (cf. le billet ci-dessus).
          // centre('Vehicule : ${d.vehicule ?? '-'}', size: 8),
          centre('Voyage : ${d.codevoyage ?? '-'}', size: 8),
        ],
      ),
    ),
  );

  return doc.save();
}
