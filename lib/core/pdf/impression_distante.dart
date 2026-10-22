import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../network/api_exception.dart';

/// LES DOCUMENTS IMPRIMÉS VIENNENT DU SERVEUR (20/10/2026).
///
/// Le billet et le reçu de bagage étaient composés ici, en Dart, pendant que le front web les
/// composait en Twig et les deux apps de réservation chacune à leur façon : quatre maquettes du
/// même papier, dans trois langages. La souche détachable a dû y être écrite deux fois le même
/// jour. Les maquettes vivent désormais auprès de leurs données, et l'API les rend pour tous les
/// canaux (`GET /api/tickets/{id}/print`, `GET /api/bagages/{id}/print`).
///
/// !! CE QUI RESTE LOCAL, ET POURQUOI. Le commercial vend et imprime SANS RÉSEAU, à bord du car :
///    c'est la limite irréductible de la règle « une seule source ». `recu_pdf.dart` et
///    `bagage_recu_pdf.dart` demeurent donc, non plus comme une seconde maquette mais comme le
///    REPLI hors-ligne, et c'est ainsi qu'il faut les lire.
///
/// Deux situations amènent à ce repli, et il importe de ne pas les confondre :
///
///   · LE DOCUMENT N'A PAS D'IDENTIFIANT SERVEUR. Une vente hors ligne n'a encore qu'un code,
///     définitif, mais aucun `id` : il n'y a rien à demander au serveur, même avec du réseau.
///   · L'APPEL ÉCHOUE FAUTE DE RÉSEAU. On le décide sur l'ÉCHEC RÉEL (`ApiException.estHorsLigne`)
///     et jamais sur l'état déclaré du réseau : un téléphone accroché à une antenne sans débit se
///     dit connecté. C'est la règle déjà suivie par la vente à bord et par le contrôle.
///
/// Toute autre erreur — un 403, un 409, un serveur en vrac — n'est PAS un cas de repli : elle
/// remonte. Composer un papier local en réponse à un refus du serveur reviendrait à imprimer ce
/// qu'il vient d'interdire.
class ImpressionDistante {
  const ImpressionDistante(this._dio);

  final Dio _dio;

  /// Le billet rendu par le serveur, ou `null` s'il n'y a pas de réseau.
  ///
  /// `format: 'large'` compose pour un terminal à rouleau large ; sans lui, c'est le thermique de
  /// 80 mm. La souche part sur sa propre page des deux côtés — c'est le mode normal, et le seul
  /// moyen d'obtenir un billet qui se détache sans se déchirer.
  Future<Uint8List?> billet(int id, {bool large = false}) =>
      _telecharger('/api/tickets/$id/print', large: large);

  /// Le reçu de bagage rendu par le serveur, ou `null` s'il n'y a pas de réseau.
  ///
  /// Il suit le MÊME support que le billet depuis le 21/10/2026 : l'agent réglé sur un terminal
  /// large récupérait sinon un billet lisible accompagné d'un reçu minuscule.
  Future<Uint8List?> bagage(int id, {bool large = false}) =>
      _telecharger('/api/bagages/$id/print', large: large);

  Future<Uint8List?> _telecharger(String chemin, {bool large = false}) async {
    try {
      final res = await _dio.get<List<int>>(
        chemin,
        queryParameters: large ? const {'format': 'large'} : null,
        options: Options(responseType: ResponseType.bytes),
      );

      final octets = res.data;
      if (octets == null || octets.isEmpty) {
        return null;
      }

      /*
        Un PDF commence par « %PDF ». Sans ce contrôle, une page d'erreur HTML ou une réponse
        tronquée partirait à l'imprimante comme un document : le vendeur verrait sortir du
        charabia au lieu d'un billet, sans savoir d'où il vient.
      */
      final octetsPdf = Uint8List.fromList(octets);
      if (octetsPdf.length < 4 ||
          octetsPdf[0] != 0x25 || // %
          octetsPdf[1] != 0x50 || // P
          octetsPdf[2] != 0x44 || // D
          octetsPdf[3] != 0x46) { // F
        return null;
      }

      return octetsPdf;
    } on DioException catch (e) {
      if (ApiException.fromDio(e).estHorsLigne) {
        return null;
      }

      rethrow;
    }
  }
}
