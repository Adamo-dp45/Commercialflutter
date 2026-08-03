import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/entreprise_remote_datasource.dart';
import '../../data/models/entreprise.dart';

final _entrepriseRemoteProvider = Provider<EntrepriseRemoteDataSource>(
  (ref) => EntrepriseRemoteDataSource(ref.watch(dioProvider)),
);

/// L'entreprise du commercial connecté, pour l'en-tête du reçu. Chargée une
/// fois puis mise en cache par Riverpod (le nom/sigle/téléphones ne changent
/// pas en cours de session).
final monEntrepriseProvider = FutureProvider<Entreprise>(
  (ref) => ref.watch(_entrepriseRemoteProvider).moi(),
);
