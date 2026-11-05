import '../../data/models/voyage_commercial.dart';
import '../../data/models/voyage_historique.dart';

/// Contrat de l'espace commercial (voyages + progression).
abstract interface class VoyageRepository {
  Future<List<VoyageCommercial>> mesVoyages();

  /// Une page de l'historique. SANS REPLI HORS LIGNE : on consulte le passé,
  /// on n'agit pas dessus — et une page tirée d'un cache partiel laisserait
  /// croire à un trou dans l'historique là où il n'y a qu'un trou de réseau.
  Future<PageVoyages> historique({int page, int parPage});

  Future<void> avancer({required int voyageId, required int gareId});

  Future<void> repartir(int voyageId);
}
