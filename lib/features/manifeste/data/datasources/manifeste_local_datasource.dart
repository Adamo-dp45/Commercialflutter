import '../../../../core/offline/file_operations.dart';
import '../../../../core/offline/operation_hors_ligne.dart';
import '../models/passager_manifeste.dart';

/// Sert le manifeste depuis l'INSTANTANÉ, quand le réseau n'est plus là.
///
/// C'est le document que le commercial ouvre pour contrôler qui est à bord — précisément au moment
/// où il est le plus loin d'une antenne. Un manifeste qui ne s'affiche pas en route ne sert à rien.
///
/// Deux sources se combinent :
///
///  * les billets de l'instantané, tous canaux confondus, tels qu'ils étaient à l'armement ;
///  * les ventes DE CE TÉLÉPHONE encore en file, qui n'existent nulle part ailleurs — le passager
///    est pourtant assis dans le car, et c'est bien lui qu'il faut contrôler.
///
/// Les billets ÉVINCÉS sont écartés, comme le fait le serveur : ces passagers ne monteront pas, les
/// annoncer décrirait un car que personne n'occupe. L'éviction est calculée côté serveur au moment
/// de l'instantané — un téléphone ne peut pas la refaire, elle se déduit de la capacité du car et de
/// la priorité amont sur l'ensemble des billets.
class ManifesteLocalDataSource {
  const ManifesteLocalDataSource(this._file);

  final FileOperations _file;

  Future<List<PassagerManifeste>> manifeste(int voyageId) async {
    final instantane = await _file.instantane(voyageId);
    if (instantane == null) return const [];

    final libelles = _libelleParGare(instantane);
    final numeroParSiege = {
      for (final siege in (instantane['sieges'] as List<dynamic>? ?? const []))
        (siege as Map<String, dynamic>)['id'] as int: siege['numero'] as int? ?? 0,
    };

    final passagers = <PassagerManifeste>[];

    for (final billet in (instantane['billets'] as List<dynamic>? ?? const [])) {
      final b = billet as Map<String, dynamic>;
      if (b['evince'] == true) continue;

      passagers.add(PassagerManifeste(
        ticketId: b['ticketId'] as int?,
        codeticket: b['codeticket'] as String?,
        siegeNumero: b['siegeNumero'] as int?,
        nomclient: b['nomclient'] as String?,
        contactclient: b['contactclient'] as String?,
        monteeLibelle: libelles[b['monteeId']],
        descenteLibelle: libelles[b['descenteAfficheeId'] ?? b['descenteId']],
        aBord: b['aBord'] == true,
      ));
    }

    for (final operation in await _file.toutes(voyageId)) {
      if (operation.type != TypeOperation.VENTE) continue;

      final p = operation.payload;
      passagers.add(PassagerManifeste(
        // Pas de ticketId : il n'existera qu'à la synchronisation. Le code, lui, est définitif.
        codeticket: p['codeticket'] as String?,
        siegeNumero: numeroParSiege[p['siege']],
        nomclient: p['nomclient'] as String?,
        contactclient: p['contactclient'] as String?,
        monteeLibelle: libelles[p['gare']],
        descenteLibelle: libelles[p['garedescente']],
        aBord: true,
      ));
    }

    passagers.sort((a, b) => (a.siegeNumero ?? 0).compareTo(b.siegeNumero ?? 0));

    return passagers;
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
}
