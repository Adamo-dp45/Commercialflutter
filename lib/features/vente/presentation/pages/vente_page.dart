import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/pdf/bagage_recu_pdf.dart';
import '../../../../core/pdf/recu_pdf.dart';
import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../entreprise/data/models/entreprise.dart';
import '../../../entreprise/presentation/providers/entreprise_providers.dart';
import '../../../voyages/data/models/arret.dart';
import '../../../voyages/presentation/providers/voyage_providers.dart';
import '../providers/vente_controller.dart';
import '../widgets/seat_grid.dart';

/// Tunnel de vente à bord : destination → siège → client → confirmation → reçu.
class VentePage extends ConsumerStatefulWidget {
  const VentePage({super.key, required this.voyageId});

  final int voyageId;

  @override
  ConsumerState<VentePage> createState() => _VentePageState();
}

class _VentePageState extends ConsumerState<VentePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voyage = ref.read(voyageByIdProvider(widget.voyageId));
      if (voyage != null) {
        ref.read(venteControllerProvider.notifier).start(voyage);
      }
    });
  }

  void _leave() {
    ref.read(venteControllerProvider.notifier).reset();
    if (context.canPop()) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(venteControllerProvider);
    final controller = ref.read(venteControllerProvider.notifier);

    final canGoBackStep =
        state.step == VenteStep.siege || state.step == VenteStep.client ||
            state.step == VenteStep.confirmation;

    if (state.voyage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !canGoBackStep,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && canGoBackStep) controller.back();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: canGoBackStep
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: controller.back,
                )
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _leave,
                ),
          title: Text(_titreEtape(state.step)),
        ),
        body: switch (state.step) {
          VenteStep.descente => _DescenteStep(),
          VenteStep.siege => _SiegeStep(),
          VenteStep.client => _ClientStep(),
          VenteStep.confirmation => _ConfirmationStep(),
          VenteStep.done => _RecuStep(onLeave: _leave),
        },
      ),
    );
  }

  String _titreEtape(VenteStep step) => switch (step) {
        VenteStep.descente => 'Destination',
        VenteStep.siege => 'Choix du siège',
        VenteStep.client => 'Client',
        VenteStep.confirmation => 'Confirmation',
        VenteStep.done => 'Billet émis',
      };
}

// ─────────────────────────── Étape 1 : destination ───────────────────────────

class _DescenteStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(venteControllerProvider);
    final controller = ref.read(venteControllerProvider.notifier);
    final descentes = state.voyage?.descentesPossibles ?? const <Arret>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MonteeBanner(libelle: state.montee?.libelle),
        const SizedBox(height: 16),
        Text('Où descend le client ?',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final a in descentes)
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(a.libelle),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => controller.selectDescente(a),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────── Étape 2 : siège ───────────────────────────

class _SiegeStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(venteControllerProvider);
    final controller = ref.read(venteControllerProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TrajetTarifBanner(
          montee: state.montee?.libelle,
          descente: state.descente?.libelle,
          tarif: state.tarif,
        ),
        const SizedBox(height: 16),
        if (state.loadingSieges)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state.error != null)
          _ErrorBox(
            message: state.error!,
            onRetry: controller.reloadSieges,
          )
        else
          SeatGrid(
            sieges: state.sieges,
            selectedId: state.siege?.id,
            onTap: (siege) {
              /*
                AVERTISSEMENT, jamais un refus : la priorité amont est la règle et elle ne se
                discute pas ici. Mais le vendeur passe à l'étape suivante dès qu'il touche un
                siège — sans ce rappel, il ne saurait qu'à la synchronisation qu'il a privé un
                passager de sa place, c'est-à-dire trop tard pour en choisir un autre.
              */
              if (siege.alerteAval) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    duration: const Duration(seconds: 6),
                    content: Text(
                      'Siège ${siege.numero} déjà vendu (${siege.resumeAval}). '
                      'Vous restez prioritaire, mais ce passager ne montera pas : '
                      'prenez un autre siège s\'il en reste.',
                    ),
                  ));
              }
              controller.selectSiege(siege);
            },
          ),
      ],
    );
  }
}

// ─────────────────────────── Étape 3 : client ───────────────────────────

class _ClientStep extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ClientStep> createState() => _ClientStepState();
}

class _ClientStepState extends ConsumerState<_ClientStep> {
  late final TextEditingController _nom;
  late final TextEditingController _contact;

  @override
  void initState() {
    super.initState();
    final state = ref.read(venteControllerProvider);
    _nom = TextEditingController(text: state.nom);
    _contact = TextEditingController(text: state.contact);
  }

  @override
  void dispose() {
    _nom.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _continue() {
    final controller = ref.read(venteControllerProvider.notifier);
    controller.setClient(nom: _nom.text, contact: _contact.text);
    controller.goTo(VenteStep.confirmation);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Identité du client (facultatif)',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Utile pour le reçu et le suivi. Vous pouvez laisser vide pour '
                'une vente anonyme.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nom,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom du client',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _contact,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _continue,
            child: const Text('Continuer'),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────── Étape 4 : confirmation ───────────────────────────

class _ConfirmationStep extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(venteControllerProvider);
    final controller = ref.read(venteControllerProvider.notifier);
    // Sans tarif défini pour ce tronçon, le serveur refuse la vente : on bloque
    // en amont avec un message clair plutôt qu'une erreur à la confirmation.
    final sansTarif = state.tarif == null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (sansTarif) ...[
                _ErrorBox(
                  message:
                      'Aucun tarif défini pour ce trajet (${state.montee?.libelle ?? '?'} → '
                      '${state.descente?.libelle ?? '?'}). Vente impossible : '
                      'la grille tarifaire doit être complétée.',
                ),
                const SizedBox(height: 12),
              ],
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _RecapLine('Trajet',
                          '${state.montee?.libelle ?? '?'} → ${state.descente?.libelle ?? '?'}'),
                      _RecapLine('Siège', '${state.siege?.numero ?? '—'}'),
                      _RecapLine(
                          'Client',
                          state.nom.trim().isEmpty
                              ? 'Anonyme'
                              : state.nom.trim()),
                      if (state.contact.trim().isNotEmpty)
                        _RecapLine('Téléphone', state.contact.trim()),
                    ],
                  ),
                ),
              ),
              if (!sansTarif) ...[
                const SizedBox(height: 12),
                const _RemiseCard(),
              ],
              if (state.error != null) ...[
                const SizedBox(height: 12),
                _ErrorBox(message: state.error!),
              ],
            ],
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed:
                (state.submitting || sansTarif) ? null : controller.confirmer,
            icon: state.submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.check_circle_outline),
            label: const Text('Confirmer la vente'),
          ),
        ),
      ],
    );
  }
}

/// Saisie d'une remise (comme sur le web) : type + valeur, avec aperçu du net.
/// Le serveur reste maître du montant final (plafond de la compagnie).
class _RemiseCard extends ConsumerStatefulWidget {
  const _RemiseCard();

  @override
  ConsumerState<_RemiseCard> createState() => _RemiseCardState();
}

class _RemiseCardState extends ConsumerState<_RemiseCard> {
  late final TextEditingController _valeur;

  @override
  void initState() {
    super.initState();
    final s = ref.read(venteControllerProvider);
    _valeur =
        TextEditingController(text: s.remiseValeur > 0 ? '${s.remiseValeur}' : '');
  }

  @override
  void dispose() {
    _valeur.dispose();
    super.dispose();
  }

  void _setType(String type) {
    if (type == 'AUCUNE') _valeur.clear();
    ref.read(venteControllerProvider.notifier).setRemise(
          type: type,
          valeur: int.tryParse(_valeur.text.trim()) ?? 0,
        );
  }

  void _setValeur(String v) {
    ref.read(venteControllerProvider.notifier).setRemise(
          type: ref.read(venteControllerProvider).remiseType,
          valeur: int.tryParse(v.trim()) ?? 0,
        );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(venteControllerProvider);
    final theme = Theme.of(context);
    final type = state.remiseType;
    final aRemise = type != 'AUCUNE';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remise (facultatif)',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Aucune'),
                  selected: type == 'AUCUNE',
                  onSelected: (_) => _setType('AUCUNE'),
                ),
                ChoiceChip(
                  label: const Text('Pourcentage'),
                  selected: type == 'POURCENTAGE',
                  onSelected: (_) => _setType('POURCENTAGE'),
                ),
                ChoiceChip(
                  label: const Text('Montant'),
                  selected: type == 'MONTANT',
                  onSelected: (_) => _setType('MONTANT'),
                ),
              ],
            ),
            if (aRemise) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _valeur,
                keyboardType: TextInputType.number,
                onChanged: _setValeur,
                decoration: InputDecoration(
                  labelText: type == 'POURCENTAGE'
                      ? 'Pourcentage (%)'
                      : 'Montant (FCFA)',
                  prefixIcon: const Icon(Icons.local_offer_outlined),
                ),
              ),
            ],
            const Divider(height: 24),
            _RecapLine('Tarif', Formatters.money(state.tarif)),
            if (state.remiseEstimee > 0)
              _RecapLine('Remise', '- ${Formatters.money(state.remiseEstimee)}'),
            _RecapLine('Net estimé', Formatters.money(state.netEstime),
                strong: true),
            if (aRemise) ...[
              const SizedBox(height: 6),
              Text(
                'Le montant final est calculé au serveur (plafond de la '
                'compagnie appliqué).',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Étape 5 : reçu ───────────────────────────

/// Construit le reçu du billet fraîchement émis à partir du contexte de vente
/// (déjà connu) et de l'en-tête entreprise.
RecuData recuFromVente(VenteState state, Entreprise? ent) => RecuData(
      codeticket: state.ticket?.codeticket ?? '-',
      prixNet: state.ticket?.prix,
      remise: state.ticket?.remise ?? 0,
      monteeLibelle: state.montee?.libelle,
      descenteLibelle: state.descente?.libelle,
      codevoyage: state.voyage?.codevoyage,
      vehicule: state.voyage?.carMatricule,
      dateDepart: state.voyage?.datedepartprevue,
      dateEmission: DateTime.now(),
      siege: state.siege?.numero.toString(),
      nomclient: state.nom.trim().isEmpty ? null : state.nom.trim(),
      statut: 'VALIDE',
      sigle: ent?.sigleAffiche ?? 'BILLET',
      compagnie: ent?.nom ?? 'Compagnie de transport',
      telephones: ent?.telephones ?? '',
    );

class _RecuStep extends ConsumerWidget {
  const _RecuStep({required this.onLeave});

  final VoidCallback onLeave;

  Future<void> _partager(
      BuildContext context, WidgetRef ref, VenteState state) async {
    // L'entreprise alimente l'en-tête du reçu ; on tolère son absence (repli).
    Entreprise? ent;
    try {
      ent = await ref.read(monEntrepriseProvider.future);
    } catch (_) {
      ent = null;
    }
    final bytes = await buildRecuPdf(recuFromVente(state, ent));
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'billet-${state.ticket?.codeticket ?? 'recu'}.pdf',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(venteControllerProvider);
    final controller = ref.read(venteControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final peutBagage =
        ref.watch(authControllerProvider).user?.can('Bagage', 'CREER') ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        Icon(Icons.check_circle, size: 64, color: scheme.primary),
        const SizedBox(height: 12),
        Center(
          child: Text('Billet émis',
              style: Theme.of(context).textTheme.headlineSmall),
        ),
        Center(
          child: Text(state.ticket?.codeticket ?? '',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: scheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RecapLine('Trajet',
                    '${state.montee?.libelle ?? '?'} → ${state.descente?.libelle ?? '?'}'),
                _RecapLine('Siège', '${state.siege?.numero ?? '—'}'),
                _RecapLine(
                    'Client',
                    state.nom.trim().isEmpty ? 'Anonyme' : state.nom.trim()),
                const Divider(height: 20),
                _RecapLine('Prix payé', Formatters.money(state.ticket?.prix),
                    strong: true),
              ],
            ),
          ),
        ),
        // Vendu sans réseau : le billet n'a pas encore d'identifiant serveur. Le code, lui, est
        // définitif et le reçu est valable — mais le vendeur doit savoir que la remontée reste à
        // faire, et où en suivre le sort.
        if (state.ticket?.id == null) ...[
          const SizedBox(height: 12),
          const _EnAttenteDeRemontee(),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _partager(context, ref, state),
          icon: const Icon(Icons.ios_share),
          label: const Text('Partager le reçu (PDF)'),
        ),
        if (peutBagage) ...[
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => _BagageSheet.show(context, ref),
            icon: const Icon(Icons.luggage_outlined),
            label: const Text('Ajouter un bagage'),
          ),
        ],
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => controller.start(state.voyage!),
          icon: const Icon(Icons.add),
          label: const Text('Nouvelle vente'),
        ),
        const SizedBox(height: 10),
        TextButton(onPressed: onLeave, child: const Text('Terminer')),
      ],
    );
  }
}

/// Dit que la vente est encaissée mais pas encore remontée, et où en suivre le sort.
///
/// Sans cette mention, le vendeur ne distingue pas une vente hors ligne d'une vente ordinaire : le
/// reçu s'imprime pareil, le code est le même. Or l'une des deux reste à remonter — et peut être
/// refusée.
class _EnAttenteDeRemontee extends ConsumerWidget {
  const _EnAttenteDeRemontee();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final voyageId = ref.watch(venteControllerProvider).voyage?.id;

    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Vendu hors ligne. Le reçu est valable, la vente remontera au retour du réseau.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSecondaryContainer),
              ),
            ),
            if (voyageId != null)
              TextButton(
                onPressed: () => context.push(AppRoutes.operations(voyageId)),
                child: const Text('Suivre'),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Bagage (bottom sheet) ───────────────────────────

class _BagageSheet extends ConsumerStatefulWidget {
  const _BagageSheet();

  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _BagageSheet(),
    );
  }

  @override
  ConsumerState<_BagageSheet> createState() => _BagageSheetState();
}

class _BagageSheetState extends ConsumerState<_BagageSheet> {
  final _nature = TextEditingController();
  final _poids = TextEditingController();
  final _montant = TextEditingController();
  String _type = 'LEGER';
  bool _submitting = false;

  static const _types = {
    'LEGER': 'Léger',
    'LOURD': 'Lourd',
    'VOLUMINEUX': 'Volumineux',
    'FRAGILE': 'Fragile',
  };

  @override
  void dispose() {
    _nature.dispose();
    _poids.dispose();
    _montant.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final poids = int.tryParse(_poids.text.trim());
    if (_nature.text.trim().length < 2 || poids == null || poids <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nature et poids (kg) sont requis.')),
      );
      return;
    }
    // Montant vide → calcul serveur (grille de poids) ; renseigné → forcé.
    final montant = int.tryParse(_montant.text.trim());
    final nature = _nature.text.trim();
    final type = _type;
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final cree = await ref.read(venteControllerProvider.notifier).ajouterBagage(
            nature: nature,
            type: type,
            poids: poids,
            montant: montant,
          );
      Entreprise? ent;
      try {
        ent = await ref.read(monEntrepriseProvider.future);
      } catch (_) {
        ent = null;
      }
      final state = ref.read(venteControllerProvider);
      final recu = BagageRecuData(
        codebagage: cree.codebagage,
        nature: nature,
        type: type,
        poids: poids,
        montant: cree.montant,
        montantForce: cree.montantForce,
        nomclient: state.nom,
        contactclient: state.contact,
        codeticket: state.ticket?.codeticket,
        codevoyage: state.voyage?.codevoyage,
        monteeLibelle: state.montee?.libelle,
        descenteLibelle: state.descente?.libelle,
        sigle: ent?.sigleAffiche ?? 'BILLET',
        compagnie: ent?.nom ?? 'Compagnie de transport',
        telephones: ent?.telephones ?? '',
      );
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text('Bagage enregistré (${cree.codebagage}).'),
        action: SnackBarAction(
          label: 'Reçu',
          onPressed: () async {
            final bytes = await buildBagageRecuPdf(recu);
            await Printing.sharePdf(
                bytes: bytes, filename: 'bagage-${cree.codebagage}.pdf');
          },
        ),
        duration: const Duration(seconds: 6),
      ));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Nouveau bagage',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nature,
            decoration: const InputDecoration(
              labelText: 'Nature / désignation',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _type,
            decoration: const InputDecoration(
              labelText: 'Type',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              for (final e in _types.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => _type = v ?? 'LEGER'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _poids,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Poids (kg)',
              prefixIcon: Icon(Icons.scale_outlined),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _montant,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Montant (FCFA) — vide = calcul auto',
              helperText: 'Renseignez pour forcer le montant',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Text('Enregistrer le bagage'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Widgets partagés ───────────────────────────

class _MonteeBanner extends StatelessWidget {
  const _MonteeBanner({required this.libelle});

  final String? libelle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_bus_filled, color: scheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vente depuis la position du car : ${libelle ?? '—'}',
              style: TextStyle(color: scheme.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrajetTarifBanner extends StatelessWidget {
  const _TrajetTarifBanner({
    required this.montee,
    required this.descente,
    required this.tarif,
  });

  final String? montee;
  final String? descente;
  final int? tarif;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Text('${montee ?? '?'} → ${descente ?? '?'}',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Text(Formatters.money(tarif),
                style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _RecapLine extends StatelessWidget {
  const _RecapLine(this.label, this.value, {this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: strong
                  ? theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)
                  : theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(message, style: TextStyle(color: scheme.onErrorContainer)),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}
