/// Empêche qu'une même lecture parte dix fois.
///
/// POURQUOI CETTE CLASSE EXISTE À PART. Une caméra relit le même QR plusieurs fois par seconde
/// tant que le billet reste devant l'objectif. Sans garde, le premier envoi marque l'embarquement
/// et les suivants reviennent « déjà scanné » — sous les yeux de l'agent, qui croit à un duplicata
/// et arrête un passager parfaitement en règle.
///
/// Elle est hors du widget parce que c'est la seule logique de cet écran qui mérite un test : le
/// reste n'est que de l'affichage et un appel HTTP.
///
/// !! LE VERROU PORTE SUR UN CODE DONNÉ, pas sur le scanner. Deux billets différents présentés
/// coup sur coup doivent passer tous les deux — c'est le cas courant d'une famille qui embarque.
class VerrouScan {
  VerrouScan({this.delai = const Duration(seconds: 3)});

  /// Assez long pour que le passager avance, assez court pour qu'un voyageur présentant un second
  /// billet identique… ne puisse de toute façon pas exister : deux billets ont deux codes.
  final Duration delai;

  String? _dernierCode;
  DateTime? _dernierInstant;

  /// Faut-il envoyer cette lecture au serveur ?
  bool accepte(String code, {DateTime? maintenant}) {
    final instant = maintenant ?? DateTime.now();

    if (code == _dernierCode &&
        _dernierInstant != null &&
        instant.difference(_dernierInstant!) < delai) {
      return false;
    }

    _dernierCode = code;
    _dernierInstant = instant;

    return true;
  }
}
