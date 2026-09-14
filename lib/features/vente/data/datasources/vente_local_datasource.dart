import '../../../../core/offline/file_operations.dart';
import '../../../../core/offline/operation_hors_ligne.dart';
import '../models/siege.dart';

/// Sert le plan de sièges et le tarif depuis l'INSTANTANÉ, quand le réseau n'est plus là.
///
/// Ces deux calculs ont été choisis parce qu'ils sont les seuls que le serveur fasse et qu'un
/// téléphone puisse refaire à l'identique :
///
///  * le PRIX vient d'une grille plate `(gare de départ, gare d'arrivée) → montant`, indépendante de
///    la ligne, de la date et du remplissage. Rien à deviner.
///  * l'OCCUPATION D'UN SIÈGE se juge au seul point de montée, par la règle
///    `montée_existante <= ma_montée < descente_existante`. C'est mot pour mot celle de
///    `SiegeStateProvider` côté serveur, reproduite ici pour que le vendeur voie la même chose.
///
/// Ce que cette source ne prétend PAS faire : être à jour. L'instantané vieillit dès qu'il est pris,
/// d'autres gares vendent pendant ce temps. Un siège affiché libre peut avoir été vendu ailleurs —
/// c'est assumé, et c'est la doctrine d'éviction qui tranchera à la synchronisation.
class VenteLocalDataSource {
  const VenteLocalDataSource(this._file);

  final FileOperations _file;

  /// Le plan de sièges du tronçon, tel que l'instantané permet de le reconstituer.
  Future<List<Siege>> sieges({
    required int voyageId,
    required int monteeId,
    required int descenteId,
  }) async {
    final instantane = await _file.instantane(voyageId);
    if (instantane == null) return const [];

    final ordres = _ordreParGare(instantane);
    final ordreMontee = ordres[monteeId];
    if (ordreMontee == null) return const [];

    // Les sièges rendus indisponibles par un billet déjà émis, au point de montée du client.
    final occupes = <int>{};
    for (final billet in (instantane['billets'] as List<dynamic>? ?? const [])) {
      final b = billet as Map<String, dynamic>;
      final debut = ordres[b['monteeId']];
      final fin = ordres[b['descenteId']];
      final siegeId = b['siegeId'];

      if (siegeId is! int) continue;

      /*
        Bornes illisibles — gare hors de cette ligne, instantané partiel : on BLOQUE le siège, on ne
        le libère pas. C'est la posture du serveur, mot pour mot (« sécurité : ticket hors ligne → on
        bloque »). Ignorer le billet afficherait libre un siège que le serveur tient pour occupé, et
        l'erreur ne se découvrirait qu'après l'encaissement.
      */
      if (debut == null || fin == null) {
        occupes.add(siegeId);
        continue;
      }

      if (debut <= ordreMontee && fin > ordreMontee) {
        occupes.add(siegeId);
      }
    }

    // Les ventes DE CE TÉLÉPHONE, pas encore remontées : elles n'existent pas dans l'instantané,
    // mais le siège est bel et bien pris — le passager est assis dedans.
    for (final operation in await _file.toutes(voyageId)) {
      if (operation.type != TypeOperation.VENTE) continue;

      final siegeId = operation.payload['siege'];
      if (siegeId is int) occupes.add(siegeId);
    }

    // La DISPOSITION est reprise telle quelle : sans 'rangee' / 'colonne' / 'cote', le plan se
    // dessinerait sur une seule ligne au lieu d'un car, et le vendeur ne retrouverait pas ses sièges.
    return [
      for (final siege in (instantane['sieges'] as List<dynamic>? ?? const []))
        Siege(
          id: (siege as Map<String, dynamic>)['id'] as int,
          numero: siege['numero'] as int? ?? 0,
          rangee: siege['rangee'] as int? ?? 0,
          colonne: siege['colonne'] as int? ?? 0,
          cote: siege['cote'] as String? ?? 'GAUCHE',
          statut: occupes.contains(siege['id']) ? 'OCCUPE' : 'LIBRE',
        ),
    ];
  }

  /// Le prix du couple dans la grille embarquée. `null` si le trajet n'y figure pas — la vente est
  /// alors refusée en amont, exactement comme le ferait le serveur.
  Future<int?> tarif({required int monteeId, required int descenteId, int? voyageId}) async {
    final instantane = voyageId == null ? null : await _file.instantane(voyageId);
    if (instantane == null) return null;

    for (final tarif in (instantane['tarifs'] as List<dynamic>? ?? const [])) {
      final t = tarif as Map<String, dynamic>;
      if (t['departId'] == monteeId && t['arriveeId'] == descenteId) {
        final montant = t['montant'];

        return montant is num ? montant.toInt() : null;
      }
    }

    return null;
  }

  /// Le montant d'un bagage de ce poids dans la grille embarquée. `null` si aucune tranche ne le
  /// couvre — l'agent doit alors saisir un montant, exactement comme au guichet.
  ///
  /// Reproduit `TarifbagageRepository::findTarifForPoids` : tranches parcourues par `poidsmin`
  /// croissant (l'instantané les livre déjà dans cet ordre), première qui couvre le poids gagne, et
  /// `poidsmax` nul = dernière tranche illimitée.
  Future<int?> tarifBagage({required int voyageId, required int poids}) async {
    final instantane = await _file.instantane(voyageId);
    if (instantane == null) return null;

    for (final tranche in (instantane['tarifsBagage'] as List<dynamic>? ?? const [])) {
      final t = tranche as Map<String, dynamic>;
      final min = (t['poidsmin'] as num?)?.toInt();
      final max = (t['poidsmax'] as num?)?.toInt();

      if (min == null || poids < min) continue;
      if (max != null && poids > max) continue;

      return (t['montant'] as num?)?.toInt();
    }

    return null;
  }

  /// Le plafond de remise de la compagnie, en pourcentage. `null` = aucun plafond.
  ///
  /// Il est dans l'instantané depuis le début ; ce qui manquait, c'était quelqu'un pour le lire.
  Future<int?> plafondRemisePourcentage(int voyageId) async {
    final instantane = await _file.instantane(voyageId);

    return (instantane?['plafondRemisePourcentage'] as num?)?.toInt();
  }

  /// Le code du voyage, nécessaire pour composer un code de billet ou d'étiquette hors ligne.
  Future<String?> codevoyage(int voyageId) async {
    final instantane = await _file.instantane(voyageId);

    return (instantane?['voyage'] as Map<String, dynamic>?)?['codevoyage'] as String?;
  }

  static Map<int, int> _ordreParGare(Map<String, dynamic> instantane) {
    final ordres = <int, int>{};
    for (final arret in (instantane['arrets'] as List<dynamic>? ?? const [])) {
      final a = arret as Map<String, dynamic>;
      final gareId = a['gareId'];
      final ordre = a['ordre'];
      if (gareId is int && ordre is int) ordres[gareId] = ordre;
    }

    return ordres;
  }
}
