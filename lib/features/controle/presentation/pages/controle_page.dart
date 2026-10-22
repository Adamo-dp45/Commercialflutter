import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/models/verdict_pointage.dart';
import '../providers/controle_providers.dart';
import '../verrou_scan.dart';

/// CONTRÔLE D'EMBARQUEMENT AU QUAI : on scanne le QR d'un billet, on répond en couleur.
///
/// L'agent tient son téléphone à bout de bras, au soleil, avec une file derrière lui et un
/// passager en face. Le verdict doit se lire à la COULEUR avant de se lire au texte, et s'entendre
/// sans regarder l'écran — d'où le retour sonore, distinct selon le sort du billet.
///
/// CE QUE CET ÉCRAN NE FAIT PAS : juger. Signature, départ, statut, double passage sont tranchés
/// par le serveur. Il lit, il envoie, il montre.
class ControlePage extends ConsumerStatefulWidget {
  const ControlePage({super.key, required this.voyageId});

  final int voyageId;

  @override
  ConsumerState<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends ConsumerState<ControlePage> {
  /// Le verrou vit à part : c'est la seule logique de cet écran qui mérite son test.
  final _verrou = VerrouScan();

  final _controleur = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.normal,
  );

  final _saisie = TextEditingController();

  VerdictPointage? _verdict;
  bool _occupe = false;
  int _total = 0;

  @override
  void dispose() {
    _controleur.dispose();
    _saisie.dispose();
    super.dispose();
  }

  Future<void> _pointer(String code) async {
    final propre = code.trim();
    if (propre.isEmpty || _occupe) return;

    if (!_verrou.accepte(propre)) return;

    setState(() => _occupe = true);

    final verdict = await ref.read(controleDataSourceProvider).pointer(
          code: propre,
          voyageId: widget.voyageId,
        );

    if (!mounted) return;

    setState(() {
      _verdict = verdict;
      _occupe = false;
      // Un contrôle qui n'a pas eu lieu ne compte pas : le compteur annonce ce qui a été jugé.
      if (verdict.etat != EtatPointage.indisponible) _total++;
    });

    // Retour sonore et haptique : l'agent regarde le passager, pas l'écran.
    if (verdict.etat == EtatPointage.valide) {
      await _retour(court: true);
    } else {
      await _retour(court: false);
    }
  }

  Future<void> _retour({required bool court}) async {
    // Le vibreur suffit et ne demande aucune permission : un bip coupé par le mode silencieux
    // laisserait l'agent sans retour, alors que le téléphone vibre même en silencieux.
    await HapticFeedbackCompat.vibrer(court: court);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contrôle d\'embarquement'),
        actions: [
          IconButton(
            tooltip: 'Torche',
            icon: const Icon(Icons.flashlight_on_outlined),
            onPressed: () => _controleur.toggleTorch(),
          ),
        ],
      ),
      body: Column(
        children: [
          // LE VERDICT EST EN HAUT, pas sous la caméra : c'est lui qu'on regarde entre deux
          // passagers, et il doit rester lisible quand le téléphone est tenu bas.
          _Verdict(verdict: _verdict, occupe: _occupe),

          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                MobileScanner(
                  controller: _controleur,
                  onDetect: (capture) {
                    final valeur = capture.barcodes.firstOrNull?.rawValue;
                    if (valeur != null) _pointer(valeur);
                  },
                  errorBuilder: (context, erreur) => _CameraIndisponible(erreur: erreur),
                ),
                // Repère de visée : sans lui, l'agent ne sait pas où présenter le billet.
                IgnorePointer(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white70, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // LA SAISIE MANUELLE N'EST PAS UN PIS-ALLER : un QR froissé, mouillé ou imprimé
                // trop pâle ne se lit pas, et le passager est là, devant l'agent.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _saisie,
                        decoration: const InputDecoration(
                          labelText: 'Ou saisir le code du billet',
                          isDense: true,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (valeur) {
                          _pointer(valeur);
                          _saisie.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _occupe
                          ? null
                          : () {
                              _pointer(_saisie.text);
                              _saisie.clear();
                            },
                      child: const Text('Contrôler'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _total == 0
                      ? 'Aucun contrôle pour l\'instant'
                      : '$_total ${_total > 1 ? 'contrôles' : 'contrôle'} sur ce départ',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Le bandeau de verdict : une couleur, un mot, et ce qu'il faut pour parler au passager.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.verdict, required this.occupe});

  final VerdictPointage? verdict;
  final bool occupe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (verdict == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        color: theme.colorScheme.surfaceContainerHighest,
        child: Text(
          occupe ? 'Contrôle en cours…' : 'Présentez le QR du billet',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
      );
    }

    final v = verdict!;
    final (couleur, titre) = switch (v.etat) {
      EtatPointage.valide => (Colors.green.shade600, 'Valide — faites monter'),
      EtatPointage.dejaScanne => (Colors.amber.shade700, 'Déjà scanné'),
      EtatPointage.invalide => (Colors.red.shade600, 'Invalide'),
      // Gris, et surtout PAS rouge : le billet n'a pas été jugé, on ne refuse personne.
      EtatPointage.indisponible => (theme.colorScheme.outline, 'Contrôle impossible'),
    };

    final details = <String>[
      if (v.nomclient != null) v.nomclient!,
      if (v.siege != null) 'siège ${v.siege}',
      if (v.trajet != null) v.trajet!,
      if (v.codeticket != null) v.codeticket!,
      if (v.etat == EtatPointage.dejaScanne && v.embarqueLe != null)
        'monté le ${v.embarqueLe}${v.embarqueGare != null ? ' à ${v.embarqueGare}' : ''}',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: couleur.withValues(alpha: 0.15),
      child: Column(
        children: [
          Text(
            titre,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: couleur,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (v.motif != null) ...[
            const SizedBox(height: 4),
            Text(v.motif!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
          if (details.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              details.join(' · '),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
          // Un billet accepté mais NON SIGNÉ : il prouve son existence en base, pas son origine.
          if (v.etat != EtatPointage.invalide && !v.signe) ...[
            const SizedBox(height: 6),
            Text(
              'Ancien billet : QR non signé, vérifiez la pièce à l\'œil.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber.shade800),
            ),
          ],
        ],
      ),
    );
  }
}

class _CameraIndisponible extends StatelessWidget {
  const _CameraIndisponible({required this.erreur});

  final MobileScannerException erreur;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Caméra indisponible (${erreur.errorCode.name}).\n'
          'Utilisez la saisie manuelle ci-dessous.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Le retour physique du contrôle, isolé pour rester testable et remplaçable.
class HapticFeedbackCompat {
  const HapticFeedbackCompat._();

  static Future<void> vibrer({required bool court}) async {
    // Deux intensités : un contrôle valide doit se distinguer d'un refus SANS regarder l'écran.
    if (court) {
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await HapticFeedback.heavyImpact();
    }
  }
}
