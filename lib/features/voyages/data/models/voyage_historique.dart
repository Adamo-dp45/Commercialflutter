import 'package:freezed_annotation/freezed_annotation.dart';

part 'voyage_historique.freezed.dart';
part 'voyage_historique.g.dart';

/// Une ligne de MON historique : `GET /api/commercial/me/voyages`.
///
/// Volontairement PLUS PAUVRE que `VoyageCommercial` : ni arrêts, ni position,
/// ni plan de sièges. L'historique se consulte, il ne sert aucun geste — et une
/// page de vingt départs qui traînerait tout cela coûterait à chaque chargement
/// ce qu'elle n'affiche pas.
///
/// !! LA LISTE CONTIENT AUSSI LES VOYAGES EN COURS, signalés par `cloture`. Ce
/// n'est pas un oubli de filtre : la somme des recettes de cette liste doit
/// retomber sur le total du bilan, qui, lui, ne connaît pas la clôture.
@freezed
abstract class VoyageHistorique with _$VoyageHistorique {
  const VoyageHistorique._();

  const factory VoyageHistorique({
    required int id,
    String? codevoyage,
    int? numerodepart,
    String? provenance,
    String? destination,
    DateTime? datedepartprevue,
    DateTime? datearriveereelle,
    @Default(false) bool demarre,
    @Default(false) bool cloture,
    String? carMatricule,
    @Default(0) int maRecette,
    @Default(0) int mesTickets,
    @Default(0) int mesBagages,
  }) = _VoyageHistorique;

  factory VoyageHistorique.fromJson(Map<String, dynamic> json) =>
      _$VoyageHistoriqueFromJson(json);

  String get trajet => '${provenance ?? '?'} → ${destination ?? '?'}';

  /// « Départ 2 · LI-ABI-KOR-0001-V3 » — le numéro d'abord, c'est le repère que
  /// le vendeur a annoncé au quai ce jour-là.
  String get libelleDepart {
    final code = codevoyage ?? 'Voyage #$id';
    return numerodepart == null ? code : 'Départ $numerodepart · $code';
  }
}

/// Une PAGE d'historique, avec de quoi savoir s'il en reste une.
///
/// `pages` vient du serveur et n'est pas recalculé ici : deux façons de compter
/// le nombre de pages finiraient par ne plus s'accorder sur la dernière.
@freezed
abstract class PageVoyages with _$PageVoyages {
  const PageVoyages._();

  const factory PageVoyages({
    @Default(<VoyageHistorique>[]) List<VoyageHistorique> voyages,
    @Default(1) int page,
    @Default(20) int parPage,
    @Default(0) int total,
    @Default(0) int pages,
  }) = _PageVoyages;

  factory PageVoyages.fromJson(Map<String, dynamic> json) =>
      _$PageVoyagesFromJson(json);

  bool get aUneSuite => page < pages;
}
