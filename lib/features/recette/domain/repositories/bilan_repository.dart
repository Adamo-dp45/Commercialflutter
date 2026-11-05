import '../../data/models/bilan_commercial.dart';

/// Contrat du bilan du vendeur.
///
/// AUCUN REPLI HORS LIGNE, et c'est délibéré : un bilan est de la CONSULTATION,
/// pas un geste. Servir un chiffre d'hier sans pouvoir dire de quand il date
/// ferait croire à un écart de recette là où il n'y a qu'un écart de fraîcheur
/// — sur de l'argent, c'est le genre de doute qu'on ne lève plus. L'écran dit
/// que le réseau manque ; le vendeur réessaie.
abstract interface class BilanRepository {
  Future<BilanCommercial> bilan({String? debut, String? fin});
}
