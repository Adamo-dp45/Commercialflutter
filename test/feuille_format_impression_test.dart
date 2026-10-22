import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:commercialflutter/core/pdf/format_impression.dart';
import 'package:commercialflutter/core/pdf/impression_providers.dart';
import 'package:commercialflutter/core/widgets/feuille_format_impression.dart';

/// « MON IMPRIMANTE » : L'ÉCRAN DU RÉGLAGE (21/10/2026).
///
/// Le format du papier ne peut pas être deviné par le serveur — il décrit la machine posée devant
/// le vendeur. Il se règle donc ici, et ce réglage commande ensuite TOUT ce que l'application
/// imprime : billet et reçu de bagage, du serveur comme composés hors ligne.
///
/// !! POURQUOI UNE SENTINELLE D'ÉCRAN, LA PREMIÈRE DU PROJET. Le reste des sentinelles tient la
///    décision de format une fois qu'elle est prise ; aucune ne dit que le vendeur peut la
///    prendre. Un choix qui ne s'enregistre pas, ou une feuille qui ne se referme pas, laisseraient
///    tout le dispositif derrière sans que rien ne tombe au rouge — et l'app du commercial ne
///    tourne ni sur ce poste ni dans un émulateur ici.
void main() {
  /// Le coffre du téléphone en mémoire : `FlutterSecureStorage` lèverait, faute de canal de
  /// plate-forme dans un test.
  late Map<String, String> coffre;

  Widget app() => ProviderScope(
        overrides: [
          reglageFormatProvider.overrideWithValue(
            ReglageFormatImpression(_MagasinMemoire(coffre)),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => ouvrirFeuilleFormatImpression(context),
                child: const Text('Mon imprimante'),
              ),
            ),
          ),
        ),
      );

  setUp(() => coffre = {});

  testWidgets('la feuille propose les deux papiers et coche le thermique par défaut',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Mon imprimante'));
    await tester.pumpAndSettle();

    expect(find.text(FormatImpression.thermique80.libelle), findsOneWidget);
    expect(find.text(FormatImpression.large.libelle), findsOneWidget);

    // Une seule coche, et c'est le thermique : le format le plus courant, et celui qu'un réglage
    // jamais touché doit donner.
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(
      tester.widget<ListTile>(find.ancestor(
        of: find.text(FormatImpression.thermique80.libelle),
        matching: find.byType(ListTile),
      )).selected,
      isTrue,
    );
  });

  testWidgets('choisir le terminal large enregistre le réglage et referme la feuille',
      (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Mon imprimante'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(FormatImpression.large.libelle));
    await tester.pumpAndSettle();

    expect(
      coffre['format_impression'],
      FormatImpression.large.cle,
      reason: 'un choix qui ne survit pas au redémarrage serait à refaire chaque matin',
    );
    expect(find.text(FormatImpression.large.libelle), findsNothing, reason: 'la feuille se referme');
  });

  testWidgets('le choix enregistré est celui qui revient à la réouverture', (tester) async {
    coffre['format_impression'] = FormatImpression.large.cle;

    await tester.pumpWidget(app());
    await tester.tap(find.text('Mon imprimante'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ListTile>(find.ancestor(
        of: find.text(FormatImpression.large.libelle),
        matching: find.byType(ListTile),
      )).selected,
      isTrue,
      reason: 'le vendeur doit retrouver son matériel coché, sinon il le rerègle à l\'aveugle',
    );
  });
}

/// Le coffre en mémoire, adossé à une Map que la sentinelle inspecte.
class _MagasinMemoire implements MagasinReglage {
  const _MagasinMemoire(this._valeurs);

  final Map<String, String> _valeurs;

  @override
  Future<String?> lire(String cle) async => _valeurs[cle];

  @override
  Future<void> ecrire(String cle, String valeur) async => _valeurs[cle] = valeur;
}
