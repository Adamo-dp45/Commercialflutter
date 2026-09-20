import 'package:dio/dio.dart';

import '../network/api_exception.dart';
import 'base_locale.dart';
import 'file_operations.dart';
import 'operation_hors_ligne.dart';

/// Résultat d'une vidange de file.
class BilanSynchronisation {
  const BilanSynchronisation({
    this.acceptes = 0,
    this.dejaSynchronises = 0,
    this.refuses = 0,
    this.erreur,
  });

  final int acceptes;
  final int dejaSynchronises;
  final int refuses;

  /// Renseignée quand le lot n'a pas pu partir du tout (réseau, serveur). Rien n'a été marqué : la
  /// file est intacte et la prochaine tentative reprendra tout.
  final String? erreur;

  bool get aEnvoye => acceptes + dejaSynchronises + refuses > 0;
  int get total => acceptes + dejaSynchronises + refuses;
}

/// Vidange la file des ventes hors ligne vers le serveur.
///
/// Le mécanisme tient en une phrase : **on envoie tout, dans l'ordre, et on réessaie sans crainte.**
/// C'est la référence d'idempotence portée par chaque opération qui rend ce « sans crainte » vrai —
/// le serveur reconnaît ce qu'il a déjà enregistré et le signale au lieu de le dupliquer.
///
/// Un échec d'envoi (réseau coupé en plein vol) ne marque RIEN : la file reste telle quelle et la
/// tentative suivante repart du début. Un refus métier, lui, est consigné avec son motif — le vendeur
/// a encaissé de l'argent, il doit pouvoir montrer ce qui s'est passé.
class Synchronisateur {
  Synchronisateur(this._dio, this._file);

  final Dio _dio;
  final FileOperations _file;

  Future<BilanSynchronisation> vider(int voyageId) async {
    final operations = await _file.enAttente(voyageId);
    if (operations.isEmpty) {
      return const BilanSynchronisation();
    }

    final Response<Map<String, dynamic>> reponse;
    try {
      reponse = await _dio.post<Map<String, dynamic>>(
        '/api/voyages/$voyageId/me/sync',
        data: {'operations': operations.map((o) => o.versApi()).toList()},
      );
    } on DioException catch (e) {
      /*
        Rien n'est marqué : soit le serveur n'a pas reçu le lot, soit il l'a reçu et sa réponse s'est
        perdue. Dans les deux cas la file repart entière au prochain essai — et si le lot était bien
        passé, le serveur répondra « déjà synchronisé ». C'est exactement ce pour quoi la référence
        d'idempotence existe.
      */
      return BilanSynchronisation(erreur: ApiException.fromDio(e).message);
    }

    final resultats = (reponse.data?['resultats'] as List<dynamic>? ?? const <dynamic>[])
        .cast<Map<String, dynamic>>();

    var acceptes = 0;
    var deja = 0;
    var refuses = 0;

    for (final resultat in resultats) {
      final reference = resultat['reference'] as String?;
      if (reference == null) continue;

      switch (resultat['statut'] as String?) {
        case 'ACCEPTE':
          acceptes++;
          await _file.marquer(reference, statut: BaseLocale.synchronisee);
        case 'DEJA_SYNCHRONISE':
          deja++;
          await _file.marquer(reference, statut: BaseLocale.synchronisee);
        case 'REFUSE':
          refuses++;
          await _file.marquer(
            reference,
            statut: BaseLocale.refusee,
            motif: resultat['motif'] as String? ?? 'Refusé par le serveur',
          );
      }
    }

    return BilanSynchronisation(acceptes: acceptes, dejaSynchronises: deja, refuses: refuses);
  }

  /// Vide la file de TOUS les voyages qui attendent.
  ///
  /// C'est ce que réclame le retour du réseau : à cet instant, on ne sait pas où le vendeur se
  /// trouve dans l'application, ni quels départs ont des opérations en souffrance. On les traite
  /// tous, dans l'ordre des voyages.
  ///
  /// Rend le nombre d'opérations effectivement remontées — zéro si le serveur est toujours
  /// injoignable, ce qui arrive : une interface réseau qui réapparaît ne garantit pas un serveur
  /// joignable. L'échec est sans conséquence, la file reste intacte.
  Future<int> viderTout() async {
    var remontees = 0;

    for (final voyageId in await _file.voyagesEnAttente()) {
      final bilan = await vider(voyageId);
      remontees += bilan.total;
    }

    return remontees;
  }

  /// Met une opération en file et tente de la faire partir tout de suite.
  ///
  /// L'ordre est volontaire : on écrit D'ABORD, on envoie ensuite. Une vente encaissée doit survivre
  /// à ce qui peut arriver entre les deux — plus de réseau, batterie vide, application tuée.
  Future<OperationHorsLigne> deposer(OperationHorsLigne operation) async {
    final enregistree = await _file.mettreEnFile(operation);
    await vider(operation.voyageId);

    return enregistree;
  }
}
