import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/offline/offline_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/entreprise_remote_datasource.dart';
import '../../data/models/entreprise.dart';

final _entrepriseRemoteProvider = Provider<EntrepriseRemoteDataSource>(
  (ref) => EntrepriseRemoteDataSource(ref.watch(dioProvider)),
);

/// L'entreprise du commercial connecté, pour l'en-tête du reçu. Chargée une
/// fois puis mise en cache par Riverpod (le nom/sigle/téléphones ne changent
/// pas en cours de session).
///
/// HORS LIGNE, l'en-tête vient de l'instantané embarqué. Sans ce repli, un billet vendu sans réseau
/// s'imprimait sous « BILLET / Compagnie de transport » : un reçu anonyme, que le client ne peut
/// rattacher à personne et qui ne vaut rien en cas de litige. L'instantané porte l'en-tête
/// précisément pour ça.
final monEntrepriseProvider = FutureProvider<Entreprise>((ref) async {
  try {
    return await ref.watch(_entrepriseRemoteProvider).moi();
  } on ApiException catch (e) {
    final file = ref.watch(fileOperationsProvider);
    if (!e.estHorsLigne || file == null) rethrow;

    final embarquee = await file.entrepriseEmbarquee();
    if (embarquee == null) rethrow;

    return Entreprise.fromJson(embarquee);
  }
});
