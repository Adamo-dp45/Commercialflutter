import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../../../core/formatting/formatters.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/pdf/bagage_recu_pdf.dart';
import '../../../../core/pdf/recu_pdf.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/async_value_widget.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../entreprise/data/models/entreprise.dart';
import '../../../entreprise/presentation/providers/entreprise_providers.dart';
import '../../../voyages/data/models/voyage_commercial.dart';
import '../../../voyages/presentation/providers/voyage_providers.dart';
import '../../data/models/bagage_detail.dart';
import '../../data/models/ticket_detail.dart';
import '../providers/gestion_providers.dart';

/// « Mes ventes » d'un voyage : mes billets et bagages, pour les RÉIMPRIMER
/// (billet/bagage non imprimé après la vente), les corriger, libérer un siège
/// (passager descendu en route) et rattacher un bagage.
class MesVentesPage extends ConsumerWidget {
  const MesVentesPage({super.key, required this.voyageId});

  final int voyageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mes ventes'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Billets', icon: Icon(Icons.confirmation_number_outlined)),
            Tab(text: 'Bagages', icon: Icon(Icons.luggage_outlined)),
          ]),
        ),
        body: TabBarView(
          children: [
            _BilletsTab(voyageId: voyageId),
            _BagagesTab(voyageId: voyageId),
          ],
        ),
      ),
    );
  }
}

/// Récupère l'entreprise (en-tête des reçus), en tolérant son absence.
Future<Entreprise?> _entreprise(WidgetRef ref) async {
  try {
    return await ref.read(monEntrepriseProvider.future);
  } catch (_) {
    return null;
  }
}

Future<void> _refreshVentes(WidgetRef ref, int voyageId) async {
  ref.invalidate(mesVentesProvider(voyageId));
  await ref.read(mesVentesProvider(voyageId).future);
}

/// Ordre d'une gare sur la ligne du voyage (null si inconnue).
int? _ordre(VoyageCommercial? v, int? gareId) {
  if (v == null || gareId == null) return null;
  for (final a in v.arrets) {
    if (a.id == gareId) return a.ordre;
  }
  return null;
}

// ─────────────────────────── Onglet billets ───────────────────────────

class _BilletsTab extends ConsumerWidget {
  const _BilletsTab({required this.voyageId});

  final int voyageId;

  Future<void> _reimprimer(
      WidgetRef ref, TicketDetail t, VoyageCommercial? voyage) async {
    final ent = await _entreprise(ref);
    final bytes = await buildRecuPdf(RecuData(
      codeticket: t.codeticket ?? '-',
      prixNet: t.prix,
      remise: t.remise,
      monteeLibelle: t.monteeLibelle,
      descenteLibelle: t.descenteLibelle,
      codevoyage: voyage?.codevoyage,
      vehicule: voyage?.carMatricule,
      dateDepart: voyage?.datedepartprevue,
      dateEmission: t.dateEmission,
      siege: t.siegeNumero?.toString(),
      nomclient: t.nomclient,
      statut: t.statut,
      sigle: ent?.sigleAffiche ?? 'BILLET',
      compagnie: ent?.nom ?? 'Compagnie de transport',
      telephones: ent?.telephones ?? '',
    ));
    await Printing.sharePdf(
        bytes: bytes, filename: 'billet-${t.codeticket ?? t.id}.pdf');
  }

  Future<void> _descendre(BuildContext context, WidgetRef ref, TicketDetail t,
      VoyageCommercial? voyage) async {
    final gareId = voyage?.garecouranteId;
    final messenger = ScaffoldMessenger.of(context);
    if (gareId == null) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Position du car inconnue : action indisponible.')));
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descendre le passager'),
        content: Text(
            'Le passager du billet ${t.codeticket ?? ''} descend à '
            '${voyage?.garecouranteLibelle ?? 'la position actuelle'} ? '
            'Son siège sera libéré pour la revente.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmer')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(gestionActionsProvider.notifier).descendrePassager(
            voyageId: voyageId,
            ticketId: t.id,
            gareId: gareId,
          );
      messenger.showSnackBar(
          const SnackBar(content: Text('Siège libéré (passager descendu).')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventes = ref.watch(mesVentesProvider(voyageId));
    final voyage = ref.watch(voyageByIdProvider(voyageId));
    final user = ref.watch(authControllerProvider).user;
    final peutModif = user?.can('Ticket', 'MODIFIER') ?? false;
    final peutCreer = user?.can('Ticket', 'CREER') ?? false;
    final peutBagage = user?.can('Bagage', 'CREER') ?? false;
    final oCourante = _ordre(voyage, voyage?.garecouranteId);

    return RefreshIndicator(
      onRefresh: () => _refreshVentes(ref, voyageId),
      child: AsyncValueWidget(
        value: ventes.whenData((v) => v.tickets),
        onRetry: () => ref.invalidate(mesVentesProvider(voyageId)),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 120),
              AppEmptyView(
                icon: Icons.confirmation_number_outlined,
                message: 'Aucun billet vendu par vous sur ce voyage.',
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final t = list[i];
              final oMontee = _ordre(voyage, t.monteeGareId);
              final oDescente = _ordre(voyage, t.descenteGareId);
              // Correction client : autorisée seulement tant que le car est
              // ENCORE à la gare de montée du billet (garde TicketUpdateProcessor).
              final aLaMontee =
                  oCourante != null && oMontee != null && oCourante == oMontee;
              // Descente en route : la position doit être après la montée et au
              // plus tard à la descente vendue (garde DescendreTicketProcessor).
              final surTroncon = oCourante != null &&
                  oMontee != null &&
                  oDescente != null &&
                  oCourante > oMontee &&
                  oCourante <= oDescente;
              return _TicketCard(
                ticket: t,
                peutModifierClient: peutModif && t.estValide && aLaMontee,
                peutDescendre: peutCreer && t.estValide && surTroncon,
                peutAjouterBagage: peutBagage && t.estValide,
                onReimprimer: () => _reimprimer(ref, t, voyage),
                onModifier: () => _ClientDialog.show(context, ref, voyageId, t),
                onDescendre: () => _descendre(context, ref, t, voyage),
                onAjouterBagage: () =>
                    _BagageAddSheet.show(context, ref, voyageId, t),
              );
            },
          );
        },
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.ticket,
    required this.peutModifierClient,
    required this.peutDescendre,
    required this.peutAjouterBagage,
    required this.onReimprimer,
    required this.onModifier,
    required this.onDescendre,
    required this.onAjouterBagage,
  });

  final TicketDetail ticket;
  final bool peutModifierClient;
  final bool peutDescendre;
  final bool peutAjouterBagage;
  final VoidCallback onReimprimer;
  final VoidCallback onModifier;
  final VoidCallback onDescendre;
  final VoidCallback onAjouterBagage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = <PopupMenuEntry<String>>[
      if (peutModifierClient)
        const PopupMenuItem(value: 'client', child: Text('Modifier le client')),
      if (peutDescendre)
        const PopupMenuItem(value: 'descendre', child: Text('Descendre ici')),
      if (peutAjouterBagage)
        const PopupMenuItem(value: 'bagage', child: Text('Ajouter un bagage')),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(ticket.codeticket ?? '—',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                _StatutChip(statut: ticket.statut),
              ],
            ),
            const SizedBox(height: 6),
            Text(ticket.trajet, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              'Siège ${ticket.siegeNumero ?? '—'} · ${ticket.clientAffiche} · '
              '${Formatters.money(ticket.prix)}'
              '${ticket.remise > 0 ? ' (remise ${Formatters.money(ticket.remise)})' : ''}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReimprimer,
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Réimprimer'),
                ),
                if (actions.isNotEmpty)
                  PopupMenuButton<String>(
                    itemBuilder: (_) => actions,
                    onSelected: (v) => switch (v) {
                      'client' => onModifier(),
                      'descendre' => onDescendre(),
                      'bagage' => onAjouterBagage(),
                      _ => null,
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Onglet bagages ───────────────────────────

class _BagagesTab extends ConsumerWidget {
  const _BagagesTab({required this.voyageId});

  final int voyageId;

  Future<void> _reimprimer(
      WidgetRef ref, BagageDetail b, VoyageCommercial? voyage) async {
    final ent = await _entreprise(ref);
    final bytes = await buildBagageRecuPdf(BagageRecuData(
      codebagage: b.codebagage ?? '-',
      nature: b.nature,
      type: b.type,
      poids: b.poids,
      montant: b.montant,
      montantForce: b.montantForce,
      statut: b.statut,
      nomclient: b.nomclient,
      contactclient: b.contactclient,
      codeticket: b.codeticket,
      codevoyage: voyage?.codevoyage,
      monteeLibelle: b.monteeLibelle,
      descenteLibelle: b.descenteLibelle,
      sigle: ent?.sigleAffiche ?? 'BILLET',
      compagnie: ent?.nom ?? 'Compagnie de transport',
      telephones: ent?.telephones ?? '',
    ));
    await Printing.sharePdf(
        bytes: bytes, filename: 'bagage-${b.codebagage ?? b.id}.pdf');
  }

  Future<void> _annuler(
      BuildContext context, WidgetRef ref, BagageDetail b) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler le bagage'),
        content: Text('Annuler le bagage ${b.codebagage ?? ''} ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Annuler le bagage')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(gestionActionsProvider.notifier)
          .annulerBagage(voyageId: voyageId, bagageId: b.id);
      messenger.showSnackBar(const SnackBar(content: Text('Bagage annulé.')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ventes = ref.watch(mesVentesProvider(voyageId));
    final voyage = ref.watch(voyageByIdProvider(voyageId));
    final peutModifier =
        ref.watch(authControllerProvider).user?.can('Bagage', 'MODIFIER') ??
            false;

    return RefreshIndicator(
      onRefresh: () => _refreshVentes(ref, voyageId),
      child: AsyncValueWidget(
        value: ventes.whenData((v) => v.bagages),
        onRetry: () => ref.invalidate(mesVentesProvider(voyageId)),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 120),
              AppEmptyView(
                icon: Icons.luggage_outlined,
                message: 'Aucun bagage enregistré par vous sur ce voyage.',
              ),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            itemCount: list.length,
            itemBuilder: (context, i) => _BagageCard(
              bagage: list[i],
              peutModifier: peutModifier,
              onReimprimer: () => _reimprimer(ref, list[i], voyage),
              onModifier: () =>
                  _BagageEditSheet.show(context, ref, voyageId, list[i]),
              onAnnuler: () => _annuler(context, ref, list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _BagageCard extends StatelessWidget {
  const _BagageCard({
    required this.bagage,
    required this.peutModifier,
    required this.onReimprimer,
    required this.onModifier,
    required this.onAnnuler,
  });

  final BagageDetail bagage;
  final bool peutModifier;
  final VoidCallback onReimprimer;
  final VoidCallback onModifier;
  final VoidCallback onAnnuler;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(bagage.codebagage ?? '—',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
                _StatutChip(statut: bagage.statut),
              ],
            ),
            const SizedBox(height: 6),
            Text('${bagage.nature ?? '—'} · ${bagage.type ?? '—'} · ${bagage.poids} kg',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              '${Formatters.money(bagage.montant)}'
              '${bagage.montantForce ? ' (forcé)' : ''}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onReimprimer,
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Réimprimer'),
                ),
                // Un bagage EMBARQUE/LIVRE/PERDU n'est plus modifiable ni
                // annulable (BagageProcessor / AnnulerBagageProcessor).
                if (peutModifier && bagage.estEnregistre) ...[
                  TextButton.icon(
                    onPressed: onAnnuler,
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Annuler'),
                  ),
                  TextButton.icon(
                    onPressed: onModifier,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Modifier'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────── Dialogues / feuilles ───────────────────────────

/// Correction de l'identité client d'un billet.
class _ClientDialog extends ConsumerStatefulWidget {
  const _ClientDialog({required this.voyageId, required this.ticket});

  final int voyageId;
  final TicketDetail ticket;

  static Future<void> show(
      BuildContext context, WidgetRef ref, int voyageId, TicketDetail t) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ClientDialog(voyageId: voyageId, ticket: t),
    );
  }

  @override
  ConsumerState<_ClientDialog> createState() => _ClientDialogState();
}

class _ClientDialogState extends ConsumerState<_ClientDialog> {
  late final TextEditingController _nom;
  late final TextEditingController _contact;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nom = TextEditingController(text: widget.ticket.nomclient ?? '');
    _contact = TextEditingController(text: widget.ticket.contactclient ?? '');
  }

  @override
  void dispose() {
    _nom.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref.read(gestionActionsProvider.notifier).modifierClient(
            voyageId: widget.voyageId,
            ticketId: widget.ticket.id,
            nom: _nom.text,
            contact: _contact.text,
          );
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Billet mis à jour.')));
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le client'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nom,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nom du client'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contact,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _save,
          child: _submitting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}

/// Formulaire bagage partagé — ajout (sur un billet existant) ou modification.
class _BagageFormSheet extends ConsumerStatefulWidget {
  const _BagageFormSheet({
    required this.voyageId,
    required this.ticketId,
    this.bagage,
    this.ticket,
  });

  final int voyageId;
  final int ticketId;
  final BagageDetail? bagage; // null = ajout, sinon modification
  final TicketDetail? ticket; // contexte du billet (reçu, à l'ajout)

  @override
  ConsumerState<_BagageFormSheet> createState() => _BagageFormSheetState();
}

class _BagageFormSheetState extends ConsumerState<_BagageFormSheet> {
  late final TextEditingController _nature;
  late final TextEditingController _poids;
  late final TextEditingController _montant;
  late String _type;
  bool _submitting = false;

  static const _types = {
    'LEGER': 'Léger',
    'LOURD': 'Lourd',
    'VOLUMINEUX': 'Volumineux',
    'FRAGILE': 'Fragile',
  };

  bool get _edition => widget.bagage != null;

  @override
  void initState() {
    super.initState();
    final b = widget.bagage;
    _nature = TextEditingController(text: b?.nature ?? '');
    _poids =
        TextEditingController(text: (b?.poids ?? 0) > 0 ? '${b!.poids}' : '');
    _montant = TextEditingController(
        text: (b?.montant ?? 0) > 0 ? '${b!.montant}' : '');
    _type = _types.containsKey(b?.type) ? b!.type! : 'LEGER';
  }

  @override
  void dispose() {
    _nature.dispose();
    _poids.dispose();
    _montant.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final poids = int.tryParse(_poids.text.trim());
    if (_nature.text.trim().length < 2 || poids == null || poids <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nature et poids (kg) sont requis.')),
      );
      return;
    }
    final montant = int.tryParse(_montant.text.trim());
    final nature = _nature.text.trim();
    setState(() => _submitting = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final notifier = ref.read(gestionActionsProvider.notifier);
    try {
      if (_edition) {
        await notifier.modifierBagage(
          voyageId: widget.voyageId,
          bagageId: widget.bagage!.id,
          ticketId: widget.ticketId,
          nature: nature,
          type: _type,
          poids: poids,
          montant: montant,
        );
        if (!mounted) return;
        navigator.pop();
        messenger.showSnackBar(const SnackBar(content: Text('Bagage mis à jour.')));
        return;
      }
      final cree = await notifier.ajouterBagage(
        voyageId: widget.voyageId,
        ticketId: widget.ticketId,
        nature: nature,
        type: _type,
        poids: poids,
        montant: montant,
      );
      final recu = await _recuBagage(cree, nature, poids);
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

  Future<BagageRecuData> _recuBagage(
      ({String codebagage, int montant, bool montantForce}) cree,
      String nature,
      int poids) async {
    final t = widget.ticket;
    final voyage = ref.read(voyageByIdProvider(widget.voyageId));
    final ent = await _entreprise(ref);
    return BagageRecuData(
      codebagage: cree.codebagage,
      nature: nature,
      type: _type,
      poids: poids,
      montant: cree.montant,
      montantForce: cree.montantForce,
      nomclient: t?.nomclient,
      contactclient: t?.contactclient,
      codeticket: t?.codeticket,
      codevoyage: voyage?.codevoyage,
      monteeLibelle: t?.monteeLibelle,
      descenteLibelle: t?.descenteLibelle,
      sigle: ent?.sigleAffiche ?? 'BILLET',
      compagnie: ent?.nom ?? 'Compagnie de transport',
      telephones: ent?.telephones ?? '',
    );
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
          Text(_edition ? 'Modifier le bagage' : 'Nouveau bagage',
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
            onPressed: _submitting ? null : _save,
            child: _submitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4))
                : const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

/// Ajout d'un bagage à un billet existant.
abstract class _BagageAddSheet {
  static Future<void> show(
      BuildContext context, WidgetRef ref, int voyageId, TicketDetail ticket) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BagageFormSheet(
        voyageId: voyageId,
        ticketId: ticket.id,
        ticket: ticket,
      ),
    );
  }
}

/// Modification d'un bagage existant.
abstract class _BagageEditSheet {
  static Future<void> show(
      BuildContext context, WidgetRef ref, int voyageId, BagageDetail b) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BagageFormSheet(
        voyageId: voyageId,
        ticketId: b.ticketId ?? 0,
        bagage: b,
      ),
    );
  }
}

// ─────────────────────────── Widgets partagés ───────────────────────────

class _StatutChip extends StatelessWidget {
  const _StatutChip({required this.statut});

  final String statut;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ok = statut == 'VALIDE' ||
        statut == 'ENREGISTRE' ||
        statut == 'EMBARQUE' ||
        statut == 'LIVRE';
    final color = ok ? scheme.primary : scheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statut,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}
