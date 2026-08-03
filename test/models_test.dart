import 'package:commercialflutter/core/pdf/bagage_recu_pdf.dart';
import 'package:commercialflutter/core/pdf/recu_pdf.dart';
import 'package:commercialflutter/features/auth/data/models/auth_user.dart';
import 'package:commercialflutter/features/gestion/data/models/bagage_detail.dart';
import 'package:commercialflutter/features/gestion/data/models/ticket_detail.dart';
import 'package:commercialflutter/features/manifeste/data/models/passager_manifeste.dart';
import 'package:commercialflutter/features/recette/domain/recette_synthese.dart';
import 'package:commercialflutter/features/vente/presentation/providers/vente_controller.dart';
import 'package:commercialflutter/features/voyages/data/models/arret.dart';
import 'package:commercialflutter/features/voyages/data/models/voyage_commercial.dart';
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

  group('RecetteSynthese — agrégation', () {
    test('cumule recette/billets/bagages et compte les voyages', () {
      final s = RecetteSynthese.fromVoyages(const [
        VoyageCommercial(id: 1, maRecette: 5000, mesTickets: 2, mesBagages: 1),
        VoyageCommercial(id: 2, maRecette: 3000, mesTickets: 1, mesBagages: 0),
      ]);
      expect(s.recetteTotale, 8000);
      expect(s.nbBillets, 3);
      expect(s.nbBagages, 1);
      expect(s.nbVoyages, 2);
      expect(s.panierMoyen, 2667); // 8000 / 3 arrondi
      expect(s.estVide, isFalse);
    });

    test('liste vide → synthèse vide, panier moyen nul (pas de division par 0)',
        () {
      final s = RecetteSynthese.fromVoyages(const []);
      expect(s.estVide, isTrue);
      expect(s.panierMoyen, 0);
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

  group('AuthUser — permissions', () {
    test('admin bypasse toute permission', () {
      const user = AuthUser(roles: ['ROLE_ADMIN']);
      expect(user.can('Bagage', 'CREER'), isTrue);
    });

    test('permission explicite, insensible à la casse', () {
      const user = AuthUser(
        roles: ['ROLE_USER'],
        permissions: [Permission(entity: 'Bagage', action: 'CREER')],
      );
      expect(user.can('bagage', 'creer'), isTrue);
      expect(user.can('Ticket', 'SUPPRIMER'), isFalse);
    });

    test('aplatissement des permissions depuis /api/me (userRoles)', () {
      final user = AuthUser.fromJson(const {
        'id': 1,
        'nom': 'Kone',
        'prenom': 'Awa',
        'roles': ['ROLE_USER'],
        'userRoles': [
          {
            'role': {
              'permissions': [
                {'entity': 'Bagage', 'action': 'CREER'},
                {'entity': 'Ticket', 'action': 'VOIR'},
              ],
            },
          },
        ],
      });
      expect(user.displayName, 'Awa Kone');
      expect(user.can('Bagage', 'CREER'), isTrue);
      expect(user.can('Ticket', 'CREER'), isFalse);
    });
  });
}
