import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../formatting/formatters.dart';

/// Données d'un reçu bagage, en primitives. Le PDF reproduit le reçu thermique
/// du front web (`mails/bagage/ticket.html.twig`).
class BagageRecuData {
  const BagageRecuData({
    required this.codebagage,
    this.nature,
    this.type,
    this.poids = 0,
    this.montant = 0,
    this.montantForce = false,
    this.statut,
    this.nomclient,
    this.contactclient,
    this.codeticket,
    this.codevoyage,
    this.monteeLibelle,
    this.descenteLibelle,
    this.dateEmission,
    this.sigle = 'BILLET',
    this.compagnie = 'Compagnie de transport',
    this.telephones = '',
  });

  final String codebagage;
  final String? nature;
  final String? type;
  final int poids;
  final int montant;
  final bool montantForce;
  final String? statut; // ENREGISTRE | EMBARQUE | LIVRE | PERDU | ANNULE
  final String? nomclient;
  final String? contactclient;
  final String? codeticket;
  final String? codevoyage;
  final String? monteeLibelle;
  final String? descenteLibelle;
  final DateTime? dateEmission;

  final String sigle;
  final String compagnie;
  final String telephones;

  bool get estPerduOuAnnule => statut == 'PERDU' || statut == 'ANNULE';

  static const _typeLabels = {
    'LEGER': 'Leger',
    'LOURD': 'Lourd',
    'VOLUMINEUX': 'Volumineux',
    'FRAGILE': 'Fragile',
  };

  String get typeLabel =>
      type == null ? '' : (_typeLabels[type] ?? type!);
}

/// Construit le reçu bagage au format ticket 80 mm, fidèle au thermique du web.
/// N'utilise que les polices standard (Latin-1).
Future<Uint8List> buildBagageRecuPdf(BagageRecuData d) async {
  final doc =
      pw.Document(title: 'Recu bagage ${d.codebagage}', author: 'iTransport');

  final date = d.dateEmission != null
      ? Formatters.dateLong(d.dateEmission)
      : Formatters.dateLong(DateTime.now());

  pw.Widget ligne(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(k,
                  style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 0.5)),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Text(v,
                  textAlign: pw.TextAlign.right,
                  style:
                      pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
      );

  pw.Widget sep() => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Divider(height: 1, thickness: 0.6),
      );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // En-tête : sigle + départ (gauche) / téléphones + date (droite).
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(d.sigle.toUpperCase(),
                        style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 1)),
                    if (d.monteeLibelle != null)
                      pw.Text(d.monteeLibelle!.toUpperCase(),
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  ]),
              pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    if (d.telephones.isNotEmpty)
                      pw.Text(d.telephones,
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text(date,
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                  ]),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text('RECU BAGAGE',
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 2)),
          ),
          if (d.estPerduOuAnnule)
            pw.Container(
              margin: const pw.EdgeInsets.symmetric(vertical: 5),
              padding: const pw.EdgeInsets.symmetric(vertical: 3),
              color: PdfColors.black,
              child: pw.Center(
                child: pw.Text(
                    d.statut == 'PERDU' ? 'BAGAGE PERDU' : 'BAGAGE ANNULE',
                    style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 2)),
              ),
            ),
          pw.SizedBox(height: 6),
          // Code bagage encadré.
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 2),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
            child: pw.Center(
              child: pw.Text(d.codebagage,
                  style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2)),
            ),
          ),
          pw.SizedBox(height: 6),
          ligne('CLIENT', (d.nomclient ?? '-').toUpperCase()),
          ligne('CONTACT', d.contactclient ?? '-'),
          if (d.codeticket != null) ligne('BILLET', d.codeticket!),
          sep(),
          ligne('VOYAGE', d.codevoyage ?? '-'),
          if (d.monteeLibelle != null)
            ligne('DEPART', d.monteeLibelle!.toUpperCase()),
          if (d.descenteLibelle != null)
            ligne('DESCENTE', d.descenteLibelle!.toUpperCase()),
          sep(),
          ligne('NATURE', (d.nature ?? '-').toUpperCase()),
          if (d.type != null) ligne('TYPE', d.typeLabel.toUpperCase()),
          ligne('POIDS', '${d.poids} KG'),
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Column(children: [
              pw.Text('MONTANT PAYE',
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1)),
              pw.Text('${Formatters.number(d.montant)} FCFA',
                  style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1)),
              if (d.montantForce)
                pw.Text('(MONTANT AJUSTE)',
                    style: pw.TextStyle(
                        fontSize: 8, fontWeight: pw.FontWeight.bold)),
            ]),
          ),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
                'NB : CONSERVEZ CE RECU JUSQU\'A LA REMISE DU BAGAGE',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8)),
          ),
          pw.Center(
            child: pw.Text('${d.compagnie} - Emis par iTransport',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                    fontSize: 7, color: PdfColors.grey600)),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}
