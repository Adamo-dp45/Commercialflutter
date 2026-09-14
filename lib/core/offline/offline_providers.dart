import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/providers/auth_providers.dart';
import 'base_locale.dart';
import 'connectivite.dart';
import 'file_operations.dart';
import 'synchronisateur.dart';

/// Câblage de la vente hors ligne.
///
/// La base est ouverte une seule fois pour la durée de l'application : c'est un fichier, pas une
/// connexion réseau, et la rouvrir à chaque écran multiplierait les verrous SQLite.
final baseLocaleProvider = FutureProvider<BaseLocale>((ref) async {
  final base = await BaseLocale.ouvrir();
  ref.onDispose(base.fermer);

  return base;
});

/// La file d'opérations. `null` tant que la base n'est pas ouverte — quelques millisecondes au
/// démarrage, pendant lesquelles la vente hors ligne n'est simplement pas encore armée.
final fileOperationsProvider = Provider<FileOperations?>((ref) {
  final base = ref.watch(baseLocaleProvider).asData?.value;
  if (base == null) return null;

  final file = FileOperations(base);
  ref.onDispose(file.fermer);

  return file;
});

/// Émet à chaque écriture dans la file — mise en file d'une vente, sort rendu par le serveur.
///
/// Les compteurs de l'interface s'y accrochent. Sans lui, ils gardaient la valeur lue à leur première
/// construction : le vendeur encaissait hors ligne et le bandeau continuait d'afficher « rien en
/// attente », le journal restait vide. Une file invisible vaut une file perdue.
final revisionFileProvider = StreamProvider<int>((ref) async* {
  final file = ref.watch(fileOperationsProvider);
  if (file == null) {
    yield 0;

    return;
  }

  var revision = 0;
  yield revision;
  await for (final _ in file.changements) {
    yield ++revision;
  }
});

final synchronisateurProvider = Provider<Synchronisateur?>((ref) {
  final file = ref.watch(fileOperationsProvider);

  return file == null ? null : Synchronisateur(ref.watch(dioProvider), file);
});

final connectiviteProvider = Provider<Connectivite>((ref) => Connectivite());

/// Le réseau est-il là ? Sert à déclencher une vidange au retour de la couverture, pas à décider
/// qu'une vente part en file — cette décision se prend à l'échec réel de l'appel.
final reseauDisponibleProvider = StreamProvider<bool>(
  (ref) => ref.watch(connectiviteProvider).flux,
);

/// Nombre d'opérations encore en attente, tous voyages confondus — la matière du bandeau d'état.
final operationsEnAttenteProvider = FutureProvider<int>((ref) async {
  final file = ref.watch(fileOperationsProvider);
  if (file == null) return 0;

  // Se recalcule à chaque écriture dans la file : une vente qui entre, un sort qui se décide.
  ref.watch(revisionFileProvider);

  return file.nombreEnAttente();
});
