import '../../../../core/models/bagage_cree.dart';
import '../../data/models/mes_ventes.dart';

/// Contrat de gestion des ventes du commercial (relire / corriger).
abstract interface class GestionRepository {
  Future<MesVentes> ventesDuVoyage(int voyageId);

  Future<void> modifierClientTicket({
    required int ticketId,
    String? nom,
    String? contact,
  });

  Future<void> descendreTicket({required int ticketId, required int gareId});

  Future<BagageCree> ajouterBagage({
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  });

  Future<void> modifierBagage({
    required int bagageId,
    required int ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  });

  Future<void> annulerBagage(int bagageId);
}
