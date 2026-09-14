import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import '../network/api_exception.dart';
import 'file_operations.dart';
import 'offline_providers.dart';

/// Télécharge l'INSTANTANÉ d'un voyage : c'est le geste qui arme la vente hors ligne.
///
/// À faire pendant qu'il y a encore du réseau — typiquement à l'ouverture du voyage, avant le départ.
/// Sans lui, le téléphone ne sait ni calculer un prix, ni dessiner un plan de sièges, ni composer un
/// code de billet : il ne doit alors PAS vendre, et le repository le refuse explicitement plutôt que
/// d'improviser.
///
/// L'instantané se rafraîchit à chaque ouverture réussie du voyage : plus il est frais, moins il y a
/// de sièges affichés libres qu'une gare vient de vendre.
class Armement {
  const Armement(this._dio, this._file);

  final Dio _dio;
  final FileOperations _file;

  /// Rend `true` si le voyage est désormais armé (instantané frais), `false` si le réseau a manqué.
  ///
  /// Un échec n'est PAS une erreur bloquante : si un instantané plus ancien est déjà là, le vendeur
  /// travaille avec. Mieux vaut une carte d'hier que pas de carte du tout.
  Future<bool> armer(int voyageId) async {
    try {
      final reponse = await _dio.get<Map<String, dynamic>>('/api/voyages/$voyageId/me/instantane');
      final payload = reponse.data;
      if (payload == null) return false;

      await _file.enregistrerInstantane(voyageId, payload);

      return true;
    } on DioException catch (e) {
      final erreur = ApiException.fromDio(e);
      if (erreur.estHorsLigne) return false;

      // Un refus du serveur (403, 409 : voyage clôturé, plus commercial de ce départ) désarme :
      // conserver un instantané périmé laisserait vendre sur un voyage qu'on ne tient plus.
      await _file.oublierInstantane(voyageId);

      return false;
    }
  }

  Future<bool> estArme(int voyageId) async => (await _file.instantane(voyageId)) != null;
}

final armementProvider = Provider<Armement?>((ref) {
  final file = ref.watch(fileOperationsProvider);

  return file == null ? null : Armement(ref.watch(dioProvider), file);
});

/// Arme le voyage et vide ce qui attend — l'enchaînement naturel à l'ouverture d'un départ.
final voyageArmeProvider = FutureProvider.autoDispose.family<bool, int>((ref, voyageId) async {
  final armement = ref.watch(armementProvider);
  if (armement == null) return false;

  // On vide AVANT de rafraîchir : l'instantané intègre alors les ventes qu'on vient de remonter,
  // et le plan de sièges cesse d'afficher libres des places déjà vendues par ce téléphone.
  await ref.watch(synchronisateurProvider)?.vider(voyageId);

  final arme = await armement.armer(voyageId);

  return arme || await armement.estArme(voyageId);
});
