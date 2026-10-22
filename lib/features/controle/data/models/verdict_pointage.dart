/// Le verdict d'un contrôle d'embarquement, tel que l'écran doit le montrer.
///
/// QUATRE ÉTATS, et le quatrième n'existe que sur le téléphone : le serveur en rend trois
/// (`VALIDE`, `DEJA_SCANNE`, `INVALIDE`), et l'application ajoute `indisponible` pour le cas où
/// l'appel n'a pas abouti.
///
/// !! CETTE DISTINCTION EST CE QUI PROTÈGE LE PASSAGER. Afficher « invalide » parce que le réseau
/// est coupé ferait refuser quelqu'un qui a payé, pour une panne dont il n'est pas responsable.
/// Un contrôle qui n'a pas eu lieu n'est pas un contrôle négatif.
enum EtatPointage {
  valide,
  dejaScanne,
  invalide,

  /// L'appel n'a pas abouti : pas de réseau, serveur injoignable, session expirée.
  indisponible;

  static EtatPointage depuis(String? brut) => switch (brut) {
        'VALIDE' => EtatPointage.valide,
        'DEJA_SCANNE' => EtatPointage.dejaScanne,
        'INVALIDE' => EtatPointage.invalide,
        _ => EtatPointage.indisponible,
      };
}

class VerdictPointage {
  const VerdictPointage({
    required this.etat,
    this.motif,
    this.codeticket,
    this.nomclient,
    this.siege,
    this.trajet,
    this.embarqueLe,
    this.embarqueGare,
    this.signe = true,
  });

  final EtatPointage etat;
  final String? motif;
  final String? codeticket;
  final String? nomclient;
  final int? siege;
  final String? trajet;

  /// Heure du PREMIER passage, quand le billet était déjà monté.
  final String? embarqueLe;
  final String? embarqueGare;

  /// Le QR portait-il une signature ? Les billets imprimés avant la signature passent encore,
  /// mais ils ne prouvent que leur existence en base, jamais leur origine.
  final bool signe;

  factory VerdictPointage.fromJson(Map<String, dynamic> json) => VerdictPointage(
        etat: EtatPointage.depuis(json['etat'] as String?),
        motif: json['motif'] as String?,
        codeticket: json['codeticket'] as String?,
        nomclient: json['nomclient'] as String?,
        siege: (json['siege'] as num?)?.toInt(),
        trajet: json['trajet'] as String?,
        embarqueLe: json['embarqueLe'] as String?,
        embarqueGare: json['embarqueGare'] as String?,
        signe: json['signe'] as bool? ?? true,
      );

  /// Le contrôle n'a pas eu lieu — et ce n'est pas un refus.
  factory VerdictPointage.indisponible(String motif) => VerdictPointage(
        etat: EtatPointage.indisponible,
        motif: motif,
      );
}
