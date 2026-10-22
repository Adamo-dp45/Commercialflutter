import 'package:commercialflutter/features/controle/data/models/verdict_pointage.dart';
import 'package:commercialflutter/features/controle/presentation/verrou_scan.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE CONTRÔLE D'EMBARQUEMENT CÔTÉ TÉLÉPHONE (19/10/2026).
///
/// Deux choses seulement méritent un test ici — le reste de l'écran n'est que de l'affichage, et
/// tout le jugement (signature, départ, statut, double passage) appartient au serveur :
///
///  · LE VERROU, parce qu'une caméra relit le même QR plusieurs fois par seconde : sans lui, le
///    premier envoi marque l'embarquement et les suivants reviennent « déjà scanné », sous les
///    yeux de l'agent qui croit à un duplicata et arrête un passager en règle ;
///  · LA LECTURE DU VERDICT, parce qu'un état inconnu ne doit JAMAIS se traduire par « invalide ».
void main() {
  group('Verrou de scan', () {
    test('la première lecture passe', () {
      final verrou = VerrouScan();

      expect(verrou.accepte('IT1.42.abc'), isTrue);
    });

    test('la même lecture, aussitôt relue, est ignorée', () {
      final verrou = VerrouScan();
      final t0 = DateTime(2026, 10, 19, 7, 30);

      expect(verrou.accepte('IT1.42.abc', maintenant: t0), isTrue);
      expect(verrou.accepte('IT1.42.abc', maintenant: t0.add(const Duration(milliseconds: 60))), isFalse);
      expect(verrou.accepte('IT1.42.abc', maintenant: t0.add(const Duration(seconds: 2))), isFalse);
    });

    test('passé le délai, le même billet peut être représenté', () {
      final verrou = VerrouScan();
      final t0 = DateTime(2026, 10, 19, 7, 30);

      verrou.accepte('IT1.42.abc', maintenant: t0);

      expect(verrou.accepte('IT1.42.abc', maintenant: t0.add(const Duration(seconds: 4))), isTrue);
    });

    test('DEUX BILLETS DIFFÉRENTS passent coup sur coup — une famille embarque', () {
      final verrou = VerrouScan();
      final t0 = DateTime(2026, 10, 19, 7, 30);

      expect(verrou.accepte('IT1.42.abc', maintenant: t0), isTrue);
      expect(verrou.accepte('IT1.43.def', maintenant: t0.add(const Duration(milliseconds: 300))), isTrue);
      expect(verrou.accepte('IT1.44.ghi', maintenant: t0.add(const Duration(milliseconds: 600))), isTrue);
    });
  });

  group('Lecture du verdict', () {
    test('les trois états du serveur sont reconnus', () {
      expect(VerdictPointage.fromJson({'etat': 'VALIDE'}).etat, EtatPointage.valide);
      expect(VerdictPointage.fromJson({'etat': 'DEJA_SCANNE'}).etat, EtatPointage.dejaScanne);
      expect(VerdictPointage.fromJson({'etat': 'INVALIDE'}).etat, EtatPointage.invalide);
    });

    test("un état INCONNU devient « indisponible », jamais « invalide »", () {
      // Un serveur plus récent, une réponse tronquée, un proxy qui s'en mêle : le billet n'a pas
      // été jugé. Le traduire par « invalide » ferait refuser un passager qui a payé.
      expect(VerdictPointage.fromJson({'etat': 'AUTRE_CHOSE'}).etat, EtatPointage.indisponible);
      expect(VerdictPointage.fromJson(const {}).etat, EtatPointage.indisponible);
    });

    test('le détail du billet est repris pour que l\'agent puisse parler au passager', () {
      final v = VerdictPointage.fromJson({
        'etat': 'DEJA_SCANNE',
        'motif': 'Ce billet est déjà monté.',
        'codeticket': 'LI-ABI-KOR-0001-V3-TCK-2026-2',
        'nomclient': 'Moussa Bamba',
        'siege': 12,
        'trajet': 'Abidjan → Korhogo',
        'embarqueLe': '19/10/2026 07:12',
        'embarqueGare': "Gare d'Adjamé",
        'signe': true,
      });

      expect(v.nomclient, 'Moussa Bamba');
      expect(v.siege, 12);
      // Au second passage, l'agent doit pouvoir dire QUAND et OÙ le billet est déjà passé.
      expect(v.embarqueLe, '19/10/2026 07:12');
      expect(v.embarqueGare, "Gare d'Adjamé");
    });

    test('un QR non signé est signalé comme tel', () {
      final v = VerdictPointage.fromJson({'etat': 'VALIDE', 'signe': false});

      expect(v.etat, EtatPointage.valide);
      expect(v.signe, isFalse, reason: 'un ancien billet passe, mais ne prouve pas son origine');
    });

    test('« indisponible » porte son motif : le contrôle n\'a pas eu lieu', () {
      final v = VerdictPointage.indisponible('Pas de réseau');

      expect(v.etat, EtatPointage.indisponible);
      expect(v.motif, 'Pas de réseau');
      expect(v.codeticket, isNull);
    });
  });
}
