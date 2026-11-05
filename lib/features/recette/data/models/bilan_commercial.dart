import 'package:freezed_annotation/freezed_annotation.dart';

part 'bilan_commercial.freezed.dart';
part 'bilan_commercial.g.dart';

/// Les chiffres d'un bilan — ceux d'une période ou ceux de tout l'historique :
/// même forme, servie deux fois par `GET /api/commercial/me`.
///
/// `nbVoyages` n'est renseigné que sur le TOTAL (le serveur ne le sert pas pour
/// une période) : compter les départs d'un intervalle demanderait de les
/// compter sur leur date de départ alors que la recette se compte sur la date
/// de vente — deux bornes différentes sous un même titre.
@freezed
abstract class BilanChiffres with _$BilanChiffres {
  const BilanChiffres._();

  const factory BilanChiffres({
    @Default(0) int recette,
    @Default(0) int recetteBillets,
    @Default(0) int recetteBagages,
    @Default(0) int nbBillets,
    @Default(0) int nbBagages,

    /// Recette (bagages compris) rapportée au nombre de BILLETS. Calculé par le
    /// serveur : un bagage est un supplément à une vente, pas une vente de plus,
    /// et cette définition ne doit s'écrire qu'à un seul endroit.
    @Default(0) int panierMoyen,
    @Default(0) int nbVoyages,
  }) = _BilanChiffres;

  factory BilanChiffres.fromJson(Map<String, dynamic> json) =>
      _$BilanChiffresFromJson(json);

  bool get estVide => recette == 0 && nbBillets == 0 && nbBagages == 0;
}

/// L'intervalle réellement retenu par le serveur, tel qu'il le renvoie.
///
/// On l'affiche plutôt que les dates saisies : le serveur ramène le début au
/// premier instant du jour et la fin au dernier, et sans paramètre il prend le
/// MOIS COURANT ENTIER. Montrer la demande plutôt que la réponse laisserait
/// croire à une borne qui n'est pas celle du calcul.
@freezed
abstract class BilanPeriode with _$BilanPeriode {
  const factory BilanPeriode({String? debut, String? fin}) = _BilanPeriode;

  factory BilanPeriode.fromJson(Map<String, dynamic> json) =>
      _$BilanPeriodeFromJson(json);
}

/// MON bilan de vendeur à bord : `GET /api/commercial/me`.
///
/// Les deux chiffres arrivent ENSEMBLE et se lisent ensemble : la période dit ce
/// que j'ai fait entre deux dates, le total dit où j'en suis depuis toujours.
/// C'est le total qui remplace l'ancien cumul « mes voyages actifs », lequel
/// faisait disparaître une journée dès que le car arrivait.
@freezed
abstract class BilanCommercial with _$BilanCommercial {
  const factory BilanCommercial({
    BilanPeriode? periode,
    @Default(BilanChiffres()) BilanChiffres surPeriode,
    @Default(BilanChiffres()) BilanChiffres total,
  }) = _BilanCommercial;

  factory BilanCommercial.fromJson(Map<String, dynamic> json) =>
      _$BilanCommercialFromJson(json);
}
