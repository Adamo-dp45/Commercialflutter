import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/controle_remote_datasource.dart';

/// Le contrôle d'embarquement n'a qu'une dépendance : l'appel HTTP. Tout le jugement est au
/// serveur, il n'y a donc ni dépôt, ni source locale, ni état à conserver entre deux scans.
final controleDataSourceProvider = Provider<ControleRemoteDataSource>(
  (ref) => ControleRemoteDataSource(ref.watch(dioProvider)),
);
