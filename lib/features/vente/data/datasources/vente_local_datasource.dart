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
///  * l'ALERTE « VENDU EN AVAL » suit la même logique : un billet qui monte APRÈS le vendeur mais
///    AVANT sa descente serait évincé si ce siège lui était pris. Rejouée ici parce qu'elle décide
///    de ce que le vendeur voit au moment de CHOISIR — l'apprendre à la synchronisation ne servirait
///    plus à rien, le passager évincé le serait déjà.
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
    final libelles = _libelleParGare(instantane);
    final ordreMontee = ordres[monteeId];
    final ordreDescente = ordres[descenteId];
    if (ordreMontee == null) return const [];

    // Les sièges rendus indisponibles par un billet déjà émis, au point de montée du client.
    final occupes = <int>{};
    // Les sièges LIBRES ici mais déjà vendus par une gare en aval, et par qui.
    final avals = <int, _Aval>{};
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
        continue;
      }

      /*
        VENDU EN AVAL — les DEUX bornes comptent, et la première a coûté un faux positif côté
        serveur avant d'être posée ici :

          * `debut > ordreMontee` — le billet monte APRÈS le vendeur. On n'arrive pas ici
            uniquement parce que le billet est en aval : on y arrive AUSSI quand son passager est
            monté avant et a DÉJÀ DESCENDU (`fin <= ordreMontee`). Ce siège-là est libre, et
            personne n'y sera évincé ;
          * `debut < ordreDescente` — sa montée tombe avant la descente vendue. Au-delà, il monte
            là où le client descend : c'est une REVENTE, le bon cas, pas une alerte.

        Un billet DÉJÀ évincé est ignoré : son sort ne dépend pas de cette vente, et `conflit` le
        signale ailleurs. `evince` vient du serveur — un téléphone ne peut pas le recalculer, il
        faudrait toute la capacité du car et l'ordre de montée de tous les billets.
      */
      if (ordreDescente != null &&
          debut > ordreMontee &&
          debut < ordreDescente &&
          b['evince'] != true) {
        final courant = avals[siegeId];
        avals[siegeId] = _Aval(
          ordre: courant == null ? debut : (debut < courant.ordre ? debut : courant.ordre),
          nom: courant == null || debut < courant.ordre ? b['nomclient'] as String? : courant.nom,
          montee: courant == null || debut < courant.ordre
              ? libelles[b['monteeId']]
              : courant.montee,
          descente: courant == null || debut < courant.ordre
              ? libelles[b['descenteAfficheeId'] ?? b['descenteId']]
              : courant.descente,
          nombre: (courant?.nombre ?? 0) + 1,
        );
      }
    }

    /*
      Les ventes DE CE TÉLÉPHONE, pas encore remontées : elles n'existent pas dans l'instantané,
      mais le siège est bel et bien pris — le passager est assis dedans.

      Elles passent par la MÊME règle de tronçon que les billets du serveur. Elles étaient
      auparavant bloquées en bloc, descente ignorée : un siège vendu Bouaké → Ferké restait donc
      occupé pour toujours aux yeux du vendeur, alors que son passager descend à Ferké et que le
      serveur, lui, l'y rend libre. Le défaut ne produisait aucune mauvaise vente — il faisait
      seulement perdre au car une place revendable, hors réseau, c'est-à-dire là où l'on ne peut
      appeler personne pour comprendre pourquoi le plan refuse.

      Bornes illisibles : on bloque, comme ailleurs. Et rien à chercher du côté « vendu en aval » —
      le commercial vend depuis la position du car, ses propres ventes ne peuvent pas monter à une
      gare qu'il n'a pas encore atteinte.
    */
    for (final operation in await _file.toutes(voyageId)) {
      if (operation.type != TypeOperation.VENTE) continue;

      final siegeId = operation.payload['siege'];
      if (siegeId is! int) continue;

      final debut = ordres[operation.payload['gare']];
      final fin = ordres[operation.payload['garedescente']];
      if (debut == null || fin == null || (debut <= ordreMontee && fin > ordreMontee)) {
        occupes.add(siegeId);
      }
    }

    // La DISPOSITION est reprise telle quelle : sans 'rangee' / 'colonne' / 'cote', le plan se
    // dessinerait sur une seule ligne au lieu d'un car, et le vendeur ne retrouverait pas ses sièges.
    return [
      for (final siege in (instantane['sieges'] as List<dynamic>? ?? const []))
        () {
          final aval = avals[(siege as Map<String, dynamic>)['id']];

          return Siege(
            id: siege['id'] as int,
            numero: siege['numero'] as int? ?? 0,
            rangee: siege['rangee'] as int? ?? 0,
            colonne: siege['colonne'] as int? ?? 0,
            cote: siege['cote'] as String? ?? 'GAUCHE',
            statut: occupes.contains(siege['id']) ? 'OCCUPE' : 'LIBRE',
            // Posé même sur un siège occupé, comme le fait le serveur : c'est l'affichage qui
            // décide de le taire (`Siege.alerteAval`), pas la source. Les deux chemins — JSON du
            // serveur et calcul local — rendent ainsi exactement le même objet.
            venduAval: aval != null,
            avalNom: aval?.nom,
            avalMontee: aval?.montee,
            avalDescente: aval?.descente,
            avalNombre: aval?.nombre ?? 0,
          );
        }(),
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

  static Map<int, String> _libelleParGare(Map<String, dynamic> instantane) {
    final libelles = <int, String>{};
    for (final arret in (instantane['arrets'] as List<dynamic>? ?? const [])) {
      final a = arret as Map<String, dynamic>;
      final gareId = a['gareId'];
      final libelle = a['libelle'];
      if (gareId is int && libelle is String) libelles[gareId] = libelle;
    }

    return libelles;
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

/// Le billet aval le plus AMONT retenu pour un siège, et le nombre total de billets aval sur ce
/// siège. On nomme celui qui monterait le PREMIER — c'est lui qui se présentera le plus tôt à un
/// car dont la place a été reprise — et on compte les autres plutôt que de les taire.
class _Aval {
  const _Aval({
    required this.ordre,
    required this.nom,
    required this.montee,
    required this.descente,
    required this.nombre,
  });

  final int ordre;
  final String? nom;
  final String? montee;
  final String? descente;
  final int nombre;
}
