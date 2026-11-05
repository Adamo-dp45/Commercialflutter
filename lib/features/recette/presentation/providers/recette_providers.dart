import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/bilan_remote_datasource.dart';
import '../../data/models/bilan_commercial.dart';
import '../../data/repositories/bilan_repository_impl.dart';
import '../../domain/repositories/bilan_repository.dart';

// -- Injection de dépendances (Dio partagé porté par la feature auth) -- //

final _bilanRemoteProvider = Provider<BilanRemoteDataSource>(
  (ref) => BilanRemoteDataSource(ref.watch(dioProvider)),
);

final bilanRepositoryProvider = Provider<BilanRepository>(
  (ref) => BilanRepositoryImpl(ref.watch(_bilanRemoteProvider)),
);

/// Les deux bornes choisies par le vendeur, à la journée près.
typedef Periode = ({DateTime debut, DateTime fin});

/// La période de consultation du bilan.
///
/// PAR DÉFAUT : du premier du mois à AUJOURD'HUI, et non le mois entier comme le
/// ferait le serveur sans paramètre. Les deux bornes sont affichées et
/// modifiables à l'écran : il n'y a donc aucune ambiguïté à lever, et un
/// intervalle qui s'avancerait dans le futur n'ajouterait que des jours vides.
class PeriodeController extends Notifier<Periode> {
  @override
  Periode build() {
    final aujourdhui = DateTime.now();

    return (debut: DateTime(aujourdhui.year, aujourdhui.month), fin: aujourdhui);
  }

  void changer({required DateTime debut, required DateTime fin}) {
    state = (debut: debut, fin: fin);
  }
}

final periodeBilanProvider =
    NotifierProvider<PeriodeController, Periode>(PeriodeController.new);

/// MON bilan sur la période courante, plus le total de tout mon historique.
///
/// REMPLACE le cumul qui se dérivait de `mesVoyagesProvider` : celui-ci ne
/// portait que sur les voyages ACTIFS, si bien que la journée d'un vendeur
/// disparaissait de son écran au moment précis où son car arrivait. Le serveur
/// sait additionner les départs clôturés, l'application n'a plus à s'en priver.
///
/// `autoDispose` : la période est un choix de consultation, pas un état de
/// l'application — en revenant sur l'écran, on repart du bilan du jour.
final bilanProvider = FutureProvider.autoDispose<BilanCommercial>((ref) {
  final periode = ref.watch(periodeBilanProvider);

  return ref.watch(bilanRepositoryProvider).bilan(
        debut: Formatters.dateApi(periode.debut),
        fin: Formatters.dateApi(periode.fin),
      );
});
