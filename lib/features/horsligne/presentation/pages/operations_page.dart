import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/offline/base_locale.dart';
import '../../../../core/offline/offline_providers.dart';
import '../../../../core/offline/operation_hors_ligne.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../providers/operations_providers.dart';

/// Ce que le téléphone a encaissé sans réseau, et ce que le serveur en a fait.
///
/// C'est la contrepartie du choix OPTIMISTE fait côté serveur : une vente hors ligne est acceptée
/// même si le siège a été vendu ailleurs entre-temps, et c'est l'éviction qui tranche ensuite. Le
/// vendeur a pris de l'argent et remis un reçu imprimé — il doit pouvoir montrer, à sa gare, ce qui
/// est passé et ce qui a été refusé. Sans cet écran, un refus disparaîtrait en silence.
///
/// Rien ne s'efface ici, et c'est délibéré : une opération refusée reste visible avec son motif.
class OperationsPage extends ConsumerWidget {
  const OperationsPage({super.key, required this.voyageId});

  final int voyageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final operations = ref.watch(operationsDuVoyageProvider(voyageId));
    final numeros = ref.watch(numeroParSiegeProvider(voyageId)).asData?.value ?? const <int, int>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opérations hors ligne'),
        actions: [
          IconButton(
            tooltip: 'Relancer la synchronisation',
            icon: const Icon(Icons.cloud_sync_outlined),
            onPressed: () => _synchroniser(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _synchroniser(context, ref),
        child: AsyncValueWidget(
          value: operations,
          onRetry: () => ref.invalidate(operationsDuVoyageProvider(voyageId)),
          data: (liste) {
            if (liste.isEmpty) {
              return ListView(children: const [
                SizedBox(height: 120),
                AppEmptyView(
                  icon: Icons.cloud_done_outlined,
                  message: 'Aucune opération hors ligne sur ce voyage.',
                ),
              ]);
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: liste.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) => i == 0
                  ? _Resume(operations: liste)
                  : _OperationTile(operation: liste[i - 1], numeros: numeros),
            );
          },
        ),
      ),
    );
  }

  /// Relance la vidange, puis relit la file — les sorts ont pu changer.
  ///
  /// Le bilan est affiché même quand il est vide : « rien à envoyer » est une réponse, et le vendeur
  /// qui appuie sur le bouton attend un retour, pas un écran immobile.
  Future<void> _synchroniser(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final bilan = await ref.read(synchronisateurProvider)?.vider(voyageId);

    ref.invalidate(operationsDuVoyageProvider(voyageId));
    ref.invalidate(operationsEnAttenteProvider);

    if (!context.mounted || bilan == null) return;

    final texte = switch (bilan) {
      _ when bilan.erreur != null => 'Synchronisation impossible : ${bilan.erreur}',
      _ when !bilan.aEnvoye => 'Rien à envoyer : tout est déjà remonté.',
      _ => '${bilan.acceptes} enregistrée(s), ${bilan.dejaSynchronises} déjà remontée(s), '
          '${bilan.refuses} refusée(s).',
    };

    messenger.showSnackBar(SnackBar(content: Text(texte)));
  }
}

/// Le compte par sort, en tête de liste : ce que le vendeur regarde en premier.
class _Resume extends StatelessWidget {
  const _Resume({required this.operations});

  final List<OperationHorsLigne> operations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final attente = operations.where((o) => o.statut == BaseLocale.enAttente).length;
    final refusees = operations.where((o) => o.statut == BaseLocale.refusee).length;
    final passees = operations.length - attente - refusees;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Compteur(valeur: passees, libelle: 'remontées', couleur: theme.colorScheme.primary),
            _Compteur(valeur: attente, libelle: 'en attente', couleur: theme.colorScheme.outline),
            _Compteur(valeur: refusees, libelle: 'refusées', couleur: theme.colorScheme.error),
          ],
        ),
      ),
    );
  }
}

class _Compteur extends StatelessWidget {
  const _Compteur({required this.valeur, required this.libelle, required this.couleur});

  final int valeur;
  final String libelle;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$valeur',
          style: theme.textTheme.titleLarge?.copyWith(
            color: couleur,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(libelle, style: theme.textTheme.labelSmall?.copyWith(color: couleur)),
      ],
    );
  }
}

class _OperationTile extends StatelessWidget {
  const _OperationTile({required this.operation, required this.numeros});

  final OperationHorsLigne operation;

  /// Identifiant de siège → numéro peint dans le car.
  final Map<int, int> numeros;

  static final _heure = DateFormat('dd/MM HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icone, couleur, sort) = switch (operation.statut) {
      BaseLocale.synchronisee => (Icons.check_circle_outline, theme.colorScheme.primary, 'Remontée'),
      BaseLocale.refusee => (Icons.error_outline, theme.colorScheme.error, 'Refusée'),
      _ => (Icons.schedule_outlined, theme.colorScheme.outline, 'En attente'),
    };

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, color: couleur),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titre(operation),
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text(
                        _heure.format(operation.instant),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(_detail(operation, numeros), style: theme.textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    sort,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: couleur, fontWeight: FontWeight.w700),
                  ),
                  // Le MOTIF est la raison d'être de cet écran : il dit au vendeur quoi expliquer à
                  // sa gare, et c'est la seule trace qui en existe.
                  if (operation.motif != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      operation.motif!,
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _titre(OperationHorsLigne o) => switch (o.type) {
        TypeOperation.VENTE => 'Billet ${o.payload['codeticket'] ?? ''}',
        TypeOperation.BAGAGE => 'Bagage ${o.payload['codebagage'] ?? ''}',
        TypeOperation.POSITION => 'Arrivée du car',
        TypeOperation.DEPART => 'Départ du car',
      };

  /// Les morceaux vides sont écartés AVANT la jointure : une vente anonyme ne doit pas laisser un
  /// séparateur orphelin en fin de ligne.
  static String _detail(OperationHorsLigne o, Map<int, int> numeros) => switch (o.type) {
        TypeOperation.VENTE => _joindre([
            if (numeros[o.payload['siege']] != null) 'Siège ${numeros[o.payload['siege']]}',
            if (o.payload['montantEncaisse'] != null) '${o.payload['montantEncaisse']} FCFA',
            o.payload['nomclient']?.toString(),
          ]),
        TypeOperation.BAGAGE => _joindre([
            '${o.payload['nature'] ?? 'Bagage'} ${o.payload['poids'] ?? '?'} kg',
            if (o.payload['montantEncaisse'] != null) '${o.payload['montantEncaisse']} FCFA',
            'billet ${o.payload['codeticket'] ?? '?'}',
          ]),
        TypeOperation.POSITION => 'Arrivée à la gare, déclarée à bord',
        TypeOperation.DEPART => 'Départ de la gare, déclaré à bord',
      };

  static String _joindre(List<String?> morceaux) => morceaux
      .map((m) => m?.trim())
      .where((m) => m != null && m.isNotEmpty)
      .join(' · ');
}
