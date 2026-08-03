import '../../voyages/data/models/voyage_commercial.dart';

/// Synthèse de MA recette, cumulée sur mes voyages ACTIFS (non clôturés).
///
/// Entièrement dérivée de `GET /api/voyages/me/commercial` : pas d'appel réseau
/// dédié. Conséquence assumée du périmètre « voyages en cours » : un voyage
/// clôturé sort du cumul (à signaler dans l'UI pour ne pas laisser croire à un
/// bilan journalier définitif).
class RecetteSynthese {
  const RecetteSynthese({
    required this.recetteTotale,
    required this.nbBillets,
    required this.nbBagages,
    required this.nbVoyages,
  });

  /// Recette propre, billets + bagages confondus (le backend additionne déjà les
  /// deux dans `maRecette`).
  final int recetteTotale;
  final int nbBillets;
  final int nbBagages;

  /// Nombre de voyages actifs qui alimentent ce cumul.
  final int nbVoyages;

  /// Recette moyenne par billet vendu (0 s'il n'y a aucune vente).
  int get panierMoyen =>
      nbBillets > 0 ? (recetteTotale / nbBillets).round() : 0;

  bool get estVide => nbVoyages == 0;

  factory RecetteSynthese.fromVoyages(List<VoyageCommercial> voyages) {
    var recette = 0;
    var billets = 0;
    var bagages = 0;
    for (final v in voyages) {
      recette += v.maRecette;
      billets += v.mesTickets;
      bagages += v.mesBagages;
    }
    return RecetteSynthese(
      recetteTotale: recette,
      nbBillets: billets,
      nbBagages: bagages,
      nbVoyages: voyages.length,
    );
  }
}
