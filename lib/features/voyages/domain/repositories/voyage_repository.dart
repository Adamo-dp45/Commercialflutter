import '../../data/models/voyage_commercial.dart';

/// Contrat de l'espace commercial (voyages + progression).
abstract interface class VoyageRepository {
  Future<List<VoyageCommercial>> mesVoyages();

  Future<void> avancer({required int voyageId, required int gareId});

  Future<void> repartir(int voyageId);
}
