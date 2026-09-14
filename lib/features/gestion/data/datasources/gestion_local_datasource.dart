import '../../../../core/offline/file_operations.dart';
import '../../../../core/offline/operation_hors_ligne.dart';
import '../models/bagage_detail.dart';
import '../models/mes_ventes.dart';
import '../models/ticket_detail.dart';

/// Sert « Mes ventes » depuis l'INSTANTANÉ, quand le réseau n'est plus là.
///
/// Ce qui justifie cet écran hors ligne, c'est un geste précis : **réimprimer**. Un passager perd son
/// reçu en route — exactement là où le commercial n'a pas de couverture. Le billet est sur le
/// téléphone, l'impression est locale ; refuser la liste reviendrait à refuser le seul service que
/// le vendeur puisse encore rendre.
///
/// Deux sources se combinent, comme pour le manifeste :
///
///  * l'instantané, filtré sur les ventes DE CE COMMERCIAL (`aBord`) — le même périmètre que
///    l'endpoint en ligne, qui ne montre jamais les ventes du guichet ;
///  * la file, pour ce qui a été encaissé depuis l'armement et n'a pas encore remonté.
///
/// Ce que cette source ne permet PAS : corriger. Modifier un client, descendre un passager, annuler
/// un bagage — ces gestes restent en ligne, et la page les désactive. Ils touchent des données que le
/// serveur arbitre, et une correction faite à l'aveugle sur une copie vieillissante ferait plus de
/// dégâts qu'un bouton grisé.
class GestionLocalDataSource {
  const GestionLocalDataSource(this._file);

  final FileOperations _file;

  Future<MesVentes> ventesDuVoyage(int voyageId) async {
    final instantane = await _file.instantane(voyageId);
    if (instantane == null) return const MesVentes(tickets: [], bagages: [], horsLigne: true);

    final libelles = _libelleParGare(instantane);
    final numeroParSiege = {
      for (final siege in (instantane['sieges'] as List<dynamic>? ?? const []))
        (siege as Map<String, dynamic>)['id'] as int: siege['numero'] as int? ?? 0,
    };

    final tickets = <TicketDetail>[];
    for (final billet in (instantane['billets'] as List<dynamic>? ?? const [])) {
      final b = billet as Map<String, dynamic>;
      // Le périmètre de la page : MES ventes. Le serveur le dit explicitement ('aMoi') plutôt que de
      // le laisser déduire de 'aBord', qui ne désigne que le canal — les deux coïncident tant qu'un
      // voyage n'a qu'un commercial, et un périmètre ne doit pas reposer sur une coïncidence.
      if (b['aMoi'] != true) continue;

      tickets.add(TicketDetail(
        id: b['ticketId'] as int? ?? 0,
        codeticket: b['codeticket'] as String?,
        prix: (b['prix'] as num?)?.toInt() ?? 0,
        remise: (b['remise'] as num?)?.toInt() ?? 0,
        nomclient: b['nomclient'] as String?,
        contactclient: b['contactclient'] as String?,
        statut: b['statut'] as String? ?? 'VALIDE',
        siegeNumero: b['siegeNumero'] as int?,
        monteeGareId: b['monteeId'] as int?,
        monteeLibelle: libelles[b['monteeId']],
        descenteGareId: b['descenteAfficheeId'] as int? ?? b['descenteId'] as int?,
        descenteLibelle: libelles[b['descenteAfficheeId'] ?? b['descenteId']],
        dateEmission: _date(b['dateEmission']),
      ));
    }

    final bagages = <BagageDetail>[];
    for (final bagage in (instantane['bagages'] as List<dynamic>? ?? const [])) {
      final b = bagage as Map<String, dynamic>;
      bagages.add(BagageDetail(
        id: b['id'] as int? ?? 0,
        codebagage: b['codebagage'] as String?,
        nature: b['nature'] as String?,
        type: b['type'] as String?,
        poids: (b['poids'] as num?)?.toInt() ?? 0,
        montant: (b['montant'] as num?)?.toInt() ?? 0,
        montantForce: b['montantforce'] == true,
        statut: b['statut'] as String? ?? 'ENREGISTRE',
        ticketId: b['ticketId'] as int?,
        codeticket: b['codeticket'] as String?,
        nomclient: b['nomclient'] as String?,
        contactclient: b['contactclient'] as String?,
        monteeLibelle: libelles[b['monteeId']],
        descenteLibelle: libelles[b['descenteId']],
      ));
    }

    // Ce que ce téléphone a encaissé depuis l'armement : ces ventes n'existent nulle part ailleurs,
    // et ce sont justement celles dont le reçu vient d'être imprimé.
    for (final operation in await _file.toutes(voyageId)) {
      final p = operation.payload;

      switch (operation.type) {
        case TypeOperation.VENTE:
          tickets.add(TicketDetail(
            // Pas d'identifiant serveur avant la synchronisation : il vaut 0, et la page s'en sert
            // pour savoir qu'aucune correction n'est possible sur ce billet-là.
            id: 0,
            codeticket: p['codeticket'] as String?,
            prix: (p['montantEncaisse'] as num?)?.toInt() ?? 0,
            nomclient: p['nomclient'] as String?,
            contactclient: p['contactclient'] as String?,
            siegeNumero: numeroParSiege[p['siege']],
            monteeGareId: p['gare'] as int?,
            monteeLibelle: libelles[p['gare']],
            descenteGareId: p['garedescente'] as int?,
            descenteLibelle: libelles[p['garedescente']],
            dateEmission: operation.instant,
          ));
        case TypeOperation.BAGAGE:
          bagages.add(BagageDetail(
            id: 0,
            codebagage: p['codebagage'] as String?,
            nature: p['nature'] as String?,
            type: p['type'] as String?,
            poids: (p['poids'] as num?)?.toInt() ?? 0,
            montant: (p['montantEncaisse'] as num?)?.toInt() ?? 0,
            montantForce: p['montant'] != null,
            codeticket: p['codeticket'] as String?,
          ));
        case TypeOperation.POSITION:
        case TypeOperation.DEPART:
          break;
      }
    }

    return MesVentes(tickets: tickets, bagages: bagages, horsLigne: true);
  }

  static DateTime? _date(dynamic valeur) =>
      valeur is String ? DateTime.tryParse(valeur) : null;

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
}
