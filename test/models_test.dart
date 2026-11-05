import 'package:commercialflutter/core/pdf/bagage_recu_pdf.dart';
import 'package:commercialflutter/core/pdf/recu_pdf.dart';
import 'package:commercialflutter/features/auth/data/models/auth_user.dart';
import 'package:commercialflutter/features/gestion/data/models/bagage_detail.dart';
import 'package:commercialflutter/features/gestion/data/models/ticket_detail.dart';
import 'package:commercialflutter/features/manifeste/data/models/passager_manifeste.dart';
import 'package:commercialflutter/features/recette/data/models/bilan_commercial.dart';
import 'package:commercialflutter/features/vente/presentation/providers/vente_controller.dart';
import 'package:commercialflutter/features/voyages/data/models/arret.dart';
import 'package:commercialflutter/features/voyages/data/models/voyage_commercial.dart';
import 'package:commercialflutter/features/voyages/data/models/voyage_historique.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoyageCommercial — progression', () {
    VoyageCommercial voyage({int? courant, bool demarre = true}) =>
        VoyageCommercial(
          id: 1,
          demarre: demarre,
          garecouranteId: courant,
          arrets: const [
            Arret(id: 10, libelle: 'Abidjan', ordre: 0),
            Arret(id: 20, libelle: 'Bouaké', ordre: 1),
            Arret(id: 30, libelle: 'Korhogo', ordre: 2),
          ],
        );

    test('prochainArret est le suivant en aval de la position', () {
      expect(voyage(courant: 10).prochainArret?.id, 20);
      expect(voyage(courant: 20).prochainArret?.id, 30);
    });

    test('pas de prochain arrêt au terminus', () {
      expect(voyage(courant: 30).prochainArret, isNull);
    });

    test('peutAvancer exige un voyage parti avec un arrêt en aval', () {
      expect(voyage(courant: 10).peutAvancer, isTrue);
      expect(voyage(courant: 30).peutAvancer, isFalse);
      expect(voyage(courant: 10, demarre: false).peutAvancer, isFalse);
    });

    test('descentesPossibles = arrêts strictement en aval de la position', () {
      final d = voyage(courant: 10).descentesPossibles.map((a) => a.id).toList();
      expect(d, [20, 30]);
      expect(voyage(courant: 20).descentesPossibles.map((a) => a.id), [30]);
    });

    test('peutVendre exige un car, une position et une destination en aval', () {
      // Sans car → pas de plan de sièges.
      expect(voyage(courant: 10).peutVendre, isFalse);
      expect(
        voyage(courant: 10).copyWith(carId: 7).peutVendre,
        isTrue,
      );
      // Au terminus → aucune destination vendable.
      expect(
        voyage(courant: 30).copyWith(carId: 7).peutVendre,
        isFalse,
      );
    });
  });

  /*
    CE GROUPE A REMPLACÉ `RecetteSynthese — agrégation`. L'application n'additionne plus elle-même
    ses voyages actifs : le bilan vient de `GET /api/commercial/me`, qui sait compter les départs
    CLÔTURÉS — ce que le cumul local ne pouvait pas faire, et qui effaçait la journée du vendeur au
    moment où son car arrivait. Ce qui se teste ici n'est donc plus un calcul mais une LECTURE : un
    champ absent de la réponse ne doit jamais devenir un écran vide ou une exception.
  */
  group('BilanCommercial — lecture de la réponse', () {
    test('lit la période et le total', () {
      final b = BilanCommercial.fromJson(const {
        'periode': {'debut': '2026-11-01', 'fin': '2026-11-04'},
        'surPeriode': {
          'recette': 8000,
          'recetteBillets': 6000,
          'recetteBagages': 2000,
          'nbBillets': 3,
          'nbBagages': 1,
          'panierMoyen': 2667,
        },
        'total': {'recette': 125000, 'nbBillets': 40, 'nbVoyages': 12},
      });

      expect(b.periode?.debut, '2026-11-01');
      expect(b.surPeriode.recette, 8000);
      expect(b.surPeriode.recetteBagages, 2000);
      expect(b.surPeriode.panierMoyen, 2667);
      expect(b.total.nbVoyages, 12);
      expect(b.surPeriode.estVide, isFalse);
    });

    test('réponse vide → zéros, jamais de nul (un écran de bilan reste lisible)',
        () {
      final b = BilanCommercial.fromJson(const <String, dynamic>{});

      expect(b.surPeriode.recette, 0);
      expect(b.total.recette, 0);
      expect(b.surPeriode.estVide, isTrue);
      expect(b.periode, isNull);
    });
  });

  group('PageVoyages — pagination de l\'historique', () {
    PageVoyages page(int p, int pages) => PageVoyages.fromJson({
          'voyages': const [
            {
              'id': 7,
              'codevoyage': 'LI-ABI-KOR-0001-V3',
              'numerodepart': 2,
              'provenance': 'Abidjan',
              'destination': 'Korhogo',
              'cloture': true,
              'maRecette': 9000,
              'mesTickets': 2,
              'mesBagages': 1,
            }
          ],
          'page': p,
          'parPage': 20,
          'total': 41,
          'pages': pages,
        });

    test('aUneSuite tant que la dernière page n\'est pas atteinte', () {
      expect(page(1, 3).aUneSuite, isTrue);
      expect(page(3, 3).aUneSuite, isFalse);
    });

    test('lit une ligne d\'historique, clôture comprise', () {
      final v = page(1, 3).voyages.single;

      expect(v.id, 7);
      expect(v.cloture, isTrue);
      expect(v.trajet, 'Abidjan → Korhogo');
      expect(v.libelleDepart, 'Départ 2 · LI-ABI-KOR-0001-V3');
      expect(v.maRecette, 9000);
    });

    test(
        'sans numéro de départ, le libellé retombe sur le code et n\'affiche pas « Départ null »',
        () {
      const v = VoyageHistorique(id: 7, codevoyage: 'LI-ABI-KOR-0001-V3');

      expect(v.libelleDepart, 'LI-ABI-KOR-0001-V3');
    });
  });

  group('VenteState — remise estimée', () {
    const base = VenteState(tarif: 10000);

    test('pourcentage', () {
      final s = base.copyWith(remiseType: 'POURCENTAGE', remiseValeur: 10);
      expect(s.remiseEstimee, 1000);
      expect(s.netEstime, 9000);
    });

    test('montant fixe', () {
      final s = base.copyWith(remiseType: 'MONTANT', remiseValeur: 2500);
      expect(s.remiseEstimee, 2500);
      expect(s.netEstime, 7500);
    });

    test('remise bornée au tarif, aucune remise = 0', () {
      expect(base.copyWith(remiseType: 'MONTANT', remiseValeur: 99999).remiseEstimee,
          10000);
      expect(base.remiseEstimee, 0); // type AUCUNE par défaut
      expect(base.netEstime, 10000);
    });
  });

  group('RecuData — tarif brut', () {
    test('tarif affiché = net + remise', () {
      const d = RecuData(codeticket: 'X', prixNet: 9000, remise: 1000);
      expect(d.tarifBrut, 10000);
    });

    test('sigle de repli = 4 premières lettres si non fourni', () {
      const d = RecuData(codeticket: 'X');
      expect(d.tarifBrut, 0);
      expect(d.estAnnuleOuReporte, isFalse);
    });
  });

  group('TicketDetail — lecture (format plat de /me/ventes)', () {
    final t = TicketDetail.fromJson(const {
      'id': 234,
      'codeticket': 'V1-TCK-2026-3',
      'prix': 9000,
      'remise': 1000,
      'nomclient': 'Awa',
      'statut': 'VALIDE',
      'siegeNumero': 12,
      'monteeLibelle': 'Bouaké',
      'descenteLibelle': 'Korhogo',
      'dateEmission': '2026-07-30T10:00:00+00:00',
    });

    test('champs plats + trajet + état', () {
      expect(t.siegeNumero, 12);
      expect(t.monteeLibelle, 'Bouaké');
      expect(t.descenteLibelle, 'Korhogo');
      expect(t.trajet, 'Bouaké → Korhogo');
      expect(t.estValide, isTrue);
      expect(t.dateEmission?.year, 2026);
    });
  });

  group('BagageDetail — lecture (format plat de /me/ventes)', () {
    test('ticketId + montant forcé + état', () {
      final b = BagageDetail.fromJson(const {
        'id': 11,
        'codebagage': 'BAG-1',
        'nature': 'valise',
        'type': 'LOURD',
        'poids': 20,
        'montant': 3000,
        'montantforce': true,
        'statut': 'ENREGISTRE',
        'ticketId': 234,
      });
      expect(b.ticketId, 234);
      expect(b.montantForce, isTrue);
      expect(b.estEnregistre, isTrue);
    });
  });

  group('BagageRecuData — reçu', () {
    test('libellé de type et statut', () {
      const d = BagageRecuData(
        codebagage: 'BAG-1',
        type: 'LOURD',
        montant: 500,
        statut: 'PERDU',
      );
      expect(d.typeLabel, 'Lourd');
      expect(d.estPerduOuAnnule, isTrue);
    });

    test('statut normal → pas de bandeau', () {
      const d = BagageRecuData(codebagage: 'BAG-2', statut: 'ENREGISTRE');
      expect(d.estPerduOuAnnule, isFalse);
    });
  });

  group('PassagerManifeste — lecture', () {
    test('trajet, client, canal', () {
      final p = PassagerManifeste.fromJson(const {
        'ticketId': 234,
        'codeticket': 'V1-TCK-2026-3',
        'siegeNumero': 5,
        'nomclient': 'Awa',
        'monteeLibelle': 'Abidjan',
        'descenteLibelle': 'Korhogo',
        'aBord': true,
      });
      expect(p.siegeNumero, 5);
      expect(p.clientAffiche, 'Awa');
      expect(p.trajet, 'Abidjan → Korhogo');
      expect(p.aBord, isTrue);
    });

    test('sans nom → Anonyme', () {
      const p = PassagerManifeste(siegeNumero: 3);
      expect(p.clientAffiche, 'Anonyme');
      expect(p.aBord, isFalse);
    });
  });

  group('AuthUser — droits servis par /api/me', () {
    test('les droits viennent du serveur, entité par entité', () {
      final user = AuthUser.fromJson(const {
        'id': 1,
        'roles': ['ROLE_USER'],
        'permissions': {
          'tout': false,
          'accordees': ['bagage:CREER', 'bagage:VOIR'],
        },
      });

      expect(user.can('Bagage', 'CREER'), isTrue);
      expect(user.can('bagage', 'creer'), isTrue, reason: 'la casse ne compte pas');
      expect(user.can('Bagage', 'SUPPRIMER'), isFalse);
      expect(user.can('Ticket', 'VOIR'), isFalse);
    });

    test('le drapeau « tout » ouvre tout, sans énumérer', () {
      final user = AuthUser.fromJson(const {
        'id': 1,
        'roles': ['ROLE_USER'],
        'permissions': {'tout': true, 'accordees': <String>[]},
      });

      expect(user.can('NimporteQuoi', 'CLOTURER'), isTrue);
    });

    test("l'application n'ajoute aucun contournement au profil servi", () {
      /*
        LE CAS QUI COMPTE. Ce compte porte les deux rôles qui déclenchaient un bypass dans le
        calcul hérité — et le serveur, lui, n'accorde rien. Si `can` regardait encore les rôles,
        il répondrait vrai : c'est exactement la divergence que ce chantier ferme.
      */
      final user = AuthUser.fromJson(const {
        'id': 1,
        'roles': ['ROLE_SUPER_ADMIN', 'ROLE_ADMIN_GARE'],
        'permissions': {'tout': false, 'accordees': <String>[]},
        'userRoles': [
          {
            'role': {
              'permissions': [
                {'entity': 'Ticket', 'action': 'VOIR'},
              ],
            },
          },
        ],
      });

      expect(user.can('Ticket', 'VOIR'), isFalse, reason: 'le serveur fait foi');
      expect(user.can('Bagage', 'CREER'), isFalse);
    });

    test("un profil abîmé n'accorde rien, et ne lève pas", () {
      final user = AuthUser.fromJson(const {
        'id': 1,
        'roles': ['ROLE_ADMIN'],
        'permissions': "ceci n'est pas un profil",
      });

      expect(
        user.can('Bagage', 'CREER'),
        isFalse,
        reason: "aucun repli local : 'ROLE_ADMIN' dans les rôles ne décide plus de rien",
      );
    });

    test('deux profils identiques sont égaux (Riverpod ne redessine pas pour rien)', () {
      const profil = {
        'id': 1,
        'roles': ['ROLE_USER'],
        'permissions': {
          'tout': false,
          'accordees': ['bagage:CREER'],
        },
      };

      expect(AuthUser.fromJson(profil), equals(AuthUser.fromJson(profil)));
    });
  });

}
