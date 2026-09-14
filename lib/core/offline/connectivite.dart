import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// État du réseau, observable.
///
/// Attention à ce que cette classe dit et ne dit pas : elle rapporte l'existence d'une INTERFACE
/// réseau, pas la joignabilité du serveur. Un téléphone accroché à une antenne sans débit se déclare
/// « connecté ». C'est pourquoi la décision de basculer en file d'attente ne se prend pas ici mais à
/// l'échec réel d'un appel — [ApiException.estHorsLigne] fait foi. Cette classe sert à l'inverse :
/// savoir QUAND retenter une vidange, plutôt que de sonder en boucle.
class Connectivite {
  Connectivite({Connectivity? connectivity}) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<bool> get flux => _connectivity.onConnectivityChanged.map(_estConnecte);

  Future<bool> maintenant() async => _estConnecte(await _connectivity.checkConnectivity());

  static bool _estConnecte(List<ConnectivityResult> resultats) =>
      resultats.any((r) => r != ConnectivityResult.none);
}
