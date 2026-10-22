import 'package:dio/dio.dart';

import '../../../../core/network/api_exception.dart';
import '../models/verdict_pointage.dart';

/// Le contrôle d'embarquement : on envoie ce que la caméra a lu, le serveur juge.
///
/// L'APPLICATION NE DÉCIDE RIEN. Signature du QR, départ, statut du billet, double passage : tout
/// est tranché par `POST /api/tickets/pointer`. Rejouer une seule de ces règles ici donnerait un
/// écran qui dit « valide » là où le serveur refuse — devant le passager, c'est la pire situation.
///
/// !! PAS DE CONTRÔLE HORS LIGNE, et c'est un choix (19/10/2026). Le téléphone ne détient ni le
/// secret qui signe les QR, ni l'état d'embarquement des autres contrôles : il ne peut donc ni
/// reconnaître un faux, ni voir qu'un billet est déjà monté. Promettre un verdict sans réseau
/// reviendrait à promettre ce qu'on ne peut pas tenir. On le DIT (`EtatPointage.indisponible`), et
/// le chauffeur pointe au stylo sur son bordereau — ce qu'il faisait de toute façon hier.
///
/// La bascule se décide sur l'ÉCHEC RÉEL de l'appel (`ApiException.estHorsLigne`), jamais sur
/// l'état déclaré du réseau : un téléphone accroché à une antenne sans débit se dit connecté.
/// C'est la règle déjà suivie par la vente à bord.
class ControleRemoteDataSource {
  const ControleRemoteDataSource(this._dio);

  final Dio _dio;

  Future<VerdictPointage> pointer({
    required String code,
    required int voyageId,
  }) async {
    try {
      final res = await _dio.post<dynamic>('/api/tickets/pointer', data: {
        'code': code,
        'voyage': '/api/voyages/$voyageId',
      });

      final data = res.data;
      if (data is! Map) {
        return VerdictPointage.indisponible('Réponse inattendue du serveur.');
      }

      return VerdictPointage.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      final erreur = ApiException.fromDio(e);

      if (erreur.estHorsLigne) {
        return VerdictPointage.indisponible(
          'Pas de réseau : le contrôle ne peut pas être fait ici. Pointez sur le bordereau.',
        );
      }

      // Une erreur serveur n'est pas un refus non plus : le billet n'a pas été jugé.
      return VerdictPointage.indisponible('Contrôle impossible : ${erreur.message}');
    }
  }
}
