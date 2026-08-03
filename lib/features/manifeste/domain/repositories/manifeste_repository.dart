import '../../data/models/passager_manifeste.dart';

/// Contrat du manifeste nominatif d'un voyage.
abstract interface class ManifesteRepository {
  Future<List<PassagerManifeste>> manifeste(int voyageId);
}
