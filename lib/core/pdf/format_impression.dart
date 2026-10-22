import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pdf/pdf.dart';

/// LE FORMAT DU PAPIER EST UN RÉGLAGE DE L'APPAREIL (21/10/2026).
///
/// Le billet sort sur deux matériels : la thermique de 80 mm du guichet et du car, et les
/// terminaux à rouleau large (du genre A5) employés dans certaines gares. Sur ces derniers, un
/// billet composé pour 80 mm paraît minuscule au milieu de la page — c'est le défaut constaté le
/// 20/10/2026. L'API sait rendre les deux (`?format=large`) ; restait à dire LEQUEL.
///
/// !! LE SERVEUR NE PEUT PAS LE DEVINER. Le format ne dépend ni de l'entreprise, ni de la gare, ni
///    du voyage : il dépend de la MACHINE posée devant l'agent. Deux vendeurs de la même gare
///    peuvent avoir deux imprimantes. C'est donc un réglage local, attaché au téléphone, et non une
///    colonne en base.
///
/// !! POURQUOI UN RÉGLAGE ET NON LE DIALOGUE SYSTÈME D'IMPRESSION. `Printing.layoutPdf` donnerait
///    le format réellement choisi par l'utilisateur, donc un papier toujours juste — mais il
///    remplacerait le geste « Partager » (par lequel le vendeur envoie aussi le billet en
///    WhatsApp), ajouterait un écran à chaque vente, et exigerait l'appel réseau PENDANT le
///    dialogue, là où le repli hors ligne doit pouvoir répondre tout de suite. Le matériel d'un
///    vendeur ne change pas en cours de journée : un réglage réglé une fois coûte moins cher.
enum FormatImpression {
  thermique80(
    'thermique80',
    'Rouleau thermique 80 mm',
    'Le format habituel : imprimante de guichet ou de bord.',
  ),
  large(
    'large',
    'Terminal à rouleau large',
    'Pour les TPE du genre A5 : mêmes mentions, écriture plus grande.',
  );

  const FormatImpression(this.cle, this.libelle, this.detail);

  /// Ce qui est écrit dans le stockage. Une valeur STABLE, distincte du nom Dart : renommer
  /// l'énumération ne doit pas remettre tous les appareils déjà réglés sur le format par défaut.
  final String cle;

  final String libelle;
  final String detail;

  bool get estLarge => this == FormatImpression.large;

  /*
    ── CE QUE LE FORMAT VAUT POUR LE REPLI COMPOSÉ ICI ─────────────────────────────────────────

    Le billet et le reçu de bagage du SERVEUR suivent déjà ce réglage. Le repli hors ligne, lui,
    sortait toujours en 80 mm : sur un terminal large, le vendeur retrouvait donc le défaut du
    20/10/2026 dès qu'il perdait le réseau — c'est-à-dire en route, là où il vend le plus.

    !! LES TROIS VALEURS CI-DESSOUS SONT LA MÊME TABLE QUE CELLE DU SERVEUR, et c'est voulu : base
       18 contre 10, laize de 148 mm contre 80, marges de 6/4 mm contre celles du thermique. Les
       deux papiers doivent se ressembler, qu'ils viennent de l'API ou du téléphone.
  */

  /// L'échelle des textes et des traits, alignée sur la base du serveur (18 contre 10).
  double get echelle => estLarge ? 1.8 : 1.0;

  /// Le papier : la laize du rouleau, hauteur libre — c'est le contenu qui l'arrête.
  PdfPageFormat get papier => estLarge ? _rouleauLarge : PdfPageFormat.roll80;

  /// La marge HORIZONTALE : elle décrit la zone que la tête sait écrire, pas la taille du texte —
  /// elle ne suit donc pas l'échelle.
  ///
  /// !! ELLE FAIT CONTRAT AVEC LE SERVEUR (`PdfService::TICKET_MARGES` et `LARGE_MARGES`), qui
  /// est l'autorité : c'est lui qui rend le même billet pour le guichet, le web et cette
  /// application. Relevé sur l'EPSON TM-T20III, la tête n'écrit QU'ENTRE 3,753 mm et 75,949 mm
  /// d'un papier de 80 : une marge plus petite fait rogner la colonne de gauche par le pilote,
  /// sans le moindre avertissement.
  ///
  /// !! VALAIT 12 pt (4,233 mm) jusqu'au 21/10/2026, contre 4,5 mm côté serveur. Les deux
  /// tenaient dans la zone imprimable, mais de justesse pour celle-ci — 0,18 mm de garde à droite
  /// contre 0,45 — et surtout les deux papiers ne se ressemblaient pas tout à fait, ce que le
  /// README promettait pourtant. Alignée sur la valeur du serveur, qui est celle qui a été mesurée.
  double get margeHorizontalePt =>
      (estLarge ? 6 : 4.5) * PdfPageFormat.mm;

  /// La marge VERTICALE, qui NE FAIT PAS contrat — et c'est une différence à comprendre.
  ///
  /// Côté serveur, le billet est rendu dans une page de HAUTEUR FIXE (520 pt), que le pilote coupe
  /// à chaque page : la marge verticale y borne un contenu dans une page qui ne bouge pas. Ici la
  /// hauteur est LIBRE, c'est le contenu qui l'arrête. La même valeur ne produirait donc pas le
  /// même papier, et l'aligner serait une fausse rigueur.
  double get margeVerticalePt => estLarge ? 4 * PdfPageFormat.mm : 14;

  /// Le thermique est le défaut, et le défaut s'applique aussi à une clé inconnue : une version
  /// plus ancienne de l'application, ou un stockage abîmé, doit sortir le format le plus courant
  /// plutôt que rien.
  static FormatImpression depuisCle(String? cle) => FormatImpression.values.firstWhere(
        (format) => format.cle == cle,
        orElse: () => FormatImpression.thermique80,
      );
}

/// Le peu qu'il faut d'un magasin clé/valeur pour tenir ce réglage.
///
/// Une interface, et non le coffre lui-même : en test, `FlutterSecureStorage` lève faute de canal
/// de plate-forme, et la feuille de réglage ne pourrait pas être ouverte par une sentinelle. Un
/// écran qu'aucun test ne peut pomper est un écran que personne ne vérifie avant l'appareil.
abstract interface class MagasinReglage {
  Future<String?> lire(String cle);

  Future<void> ecrire(String cle, String valeur);
}

/// Le coffre du téléphone — `flutter_secure_storage`, le seul magasin clé/valeur déjà embarqué.
///
/// Le chiffrement n'a ici aucun intérêt, mais ajouter `shared_preferences` pour un unique réglage,
/// ou faire migrer le schéma SQLite de la file de ventes, coûterait plus que cela ne rapporte.
class CoffreSecurise implements MagasinReglage {
  const CoffreSecurise([
    this._coffre = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  ]);

  final FlutterSecureStorage _coffre;

  @override
  Future<String?> lire(String cle) => _coffre.read(key: cle);

  @override
  Future<void> ecrire(String cle, String valeur) => _coffre.write(key: cle, value: valeur);
}

/// Le format retenu sur CET appareil.
///
/// !! IL SURVIT À LA DÉCONNEXION, et c'est voulu : `TokenStore.clear()` ne purge que les clés de
///    la session. Le format décrit l'imprimante du téléphone, pas la personne qui s'en sert — un
///    vendeur qui se reconnecte le lendemain ne doit pas avoir à le régler à nouveau.
class ReglageFormatImpression {
  const ReglageFormatImpression([this._magasin = const CoffreSecurise()]);

  final MagasinReglage _magasin;

  static const _cle = 'format_impression';

  /// Le format réglé, ou le thermique si rien n'a été choisi.
  ///
  /// !! NE LÈVE JAMAIS. Un magasin illisible empêcherait sinon d'imprimer, alors qu'on sait très
  ///    bien quoi faire dans ce cas : sortir le format le plus courant.
  Future<FormatImpression> lire() async {
    try {
      return FormatImpression.depuisCle(await _magasin.lire(_cle));
    } catch (_) {
      return FormatImpression.thermique80;
    }
  }

  Future<void> definir(FormatImpression format) => _magasin.ecrire(_cle, format.cle);
}

/// Le rouleau large des terminaux : 148 mm de laize, comme `PdfService::LARGE_LARGEUR_PT`.
///
/// !! AUCUNE MARGE ICI, et ce n'est pas un oubli : `pw.Page` reçoit son propre `margin`, qui
/// REMPLACE celui du format. Le `marginAll: 5 mm` qui figurait là n'a jamais été appliqué — une
/// valeur morte qui laissait croire à une marge de 5 mm alors que le papier en portait 6.
const _rouleauLarge = PdfPageFormat(
  148 * PdfPageFormat.mm,
  double.infinity,
);
