import 'dart:convert';

/// Une opération encaissée SANS réseau, en attente de remontée.
///
/// C'est l'unité de la file : une vente, un bagage, une avance de position. Elle porte tout ce qu'il
/// faut pour être rejouée telle quelle, y compris son horodatage — celui du TÉLÉPHONE, pas de la
/// synchronisation. Prendre l'heure de l'envoi ferait croire à un car immobile pendant des heures
/// puis téléporté, et fausserait le recalage des durées de tronçon côté serveur.
///
/// La [reference] est la clé d'idempotence : générée une seule fois au moment du geste, elle accompagne
/// l'opération jusqu'au bout. Le serveur s'en sert pour reconnaître un rejeu — coupure en plein
/// envoi, reprise après échec — et rendre le billet déjà créé au lieu d'en fabriquer un second.
class OperationHorsLigne {
  const OperationHorsLigne({
    this.id,
    required this.reference,
    required this.voyageId,
    required this.type,
    required this.instant,
    required this.payload,
    required this.statut,
    this.motif,
    required this.creeLe,
  });

  /// Identifiant local : donne l'ordre FIFO, et cet ordre compte.
  final int? id;

  final String reference;
  final int voyageId;
  final TypeOperation type;

  /// Moment RÉEL du geste, tel que le téléphone l'a horodaté.
  final DateTime instant;

  final Map<String, dynamic> payload;
  final String statut;

  /// Motif du refus renvoyé par le serveur, s'il y en a eu un.
  final String? motif;

  final DateTime creeLe;

  /// Le format attendu par `POST /api/voyages/{id}/me/sync`.
  Map<String, dynamic> versApi() => {
        'reference': reference,
        'type': type.name,
        'instant': instant.toIso8601String(),
        'payload': payload,
      };

  Map<String, Object?> versLigne() => {
        'reference': reference,
        'voyage_id': voyageId,
        'type': type.name,
        'instant': instant.toIso8601String(),
        'payload': jsonEncode(payload),
        'statut': statut,
        'motif': motif,
        'cree_le': creeLe.toIso8601String(),
      };

  static OperationHorsLigne depuisLigne(Map<String, Object?> ligne) => OperationHorsLigne(
        id: ligne['id'] as int?,
        reference: ligne['reference']! as String,
        voyageId: ligne['voyage_id']! as int,
        type: TypeOperation.values.firstWhere(
          (t) => t.name == ligne['type'],
          orElse: () => TypeOperation.VENTE,
        ),
        instant: DateTime.parse(ligne['instant']! as String),
        payload: jsonDecode(ligne['payload']! as String) as Map<String, dynamic>,
        statut: ligne['statut']! as String,
        motif: ligne['motif'] as String?,
        creeLe: DateTime.parse(ligne['cree_le']! as String),
      );

  OperationHorsLigne copyWith({String? statut, String? motif}) => OperationHorsLigne(
        id: id,
        reference: reference,
        voyageId: voyageId,
        type: type,
        instant: instant,
        payload: payload,
        statut: statut ?? this.statut,
        motif: motif ?? this.motif,
        creeLe: creeLe,
      );
}

/// Les gestes qu'un vendeur à bord peut poser sans réseau.
///
/// Volontairement court. Le désistement, la modification d'un billet et la récompense de fidélité en
/// sont absents et doivent le rester : rembourser engage la caisse d'une gare, et la fidélité se
/// dérive de tout l'historique de la compagnie — deux téléphones hors ligne brûleraient la même.
// ignore: constant_identifier_names
enum TypeOperation { VENTE, BAGAGE, POSITION, DEPART }
