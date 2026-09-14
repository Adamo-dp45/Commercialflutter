import 'package:uuid/uuid.dart';

import '../../../../core/models/bagage_cree.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/offline/base_locale.dart';
import '../../../../core/offline/codes_hors_ligne.dart';
import '../../../../core/offline/operation_hors_ligne.dart';
import '../../../../core/offline/synchronisateur.dart';
import '../../domain/repositories/vente_repository.dart';
import '../datasources/vente_local_datasource.dart';
import '../datasources/vente_remote_datasource.dart';
import '../models/siege.dart';
import '../models/ticket_vendu.dart';

/// Le point où l'application choisit entre le serveur et l'instantané embarqué.
///
/// Le choix ne se fait PAS sur l'état déclaré du réseau : un téléphone accroché à une antenne sans
/// débit se dit connecté. Il se fait à l'échec RÉEL de l'appel — [ApiException.estHorsLigne] — ce qui
/// couvre aussi bien la coupure franche que le serveur injoignable ou le délai dépassé.
///
/// Si la couche hors ligne n'est pas armée (base pas encore ouverte, instantané absent), rien ne
/// change : l'erreur remonte comme avant. Vendre sans instantané serait vendre à l'aveugle.
class VenteRepositoryImpl implements VenteRepository {
  // Les champs sont privés et les paramètres publics : une formelle d'initialisation exposerait
  // '_local' comme nom de paramètre à l'appelant. D'où l'affectation explicite.
  // ignore_for_file: prefer_initializing_formals
  VenteRepositoryImpl(
    this._remote, {
    VenteLocalDataSource? local,
    Synchronisateur? synchronisateur,
    CodesHorsLigne? codes,
  })  : _local = local,
        _synchronisateur = synchronisateur,
        _codes = codes;

  final VenteRemoteDataSource _remote;
  final VenteLocalDataSource? _local;
  final Synchronisateur? _synchronisateur;
  final CodesHorsLigne? _codes;

  static const _uuid = Uuid();

  @override
  Future<List<Siege>> sieges({
    required int carId,
    required int voyageId,
    required int monteeId,
    required int descenteId,
  }) async {
    try {
      return await _remote.sieges(
        carId: carId,
        voyageId: voyageId,
        monteeId: monteeId,
        descenteId: descenteId,
      );
    } on ApiException catch (e) {
      final local = _local;
      if (!e.estHorsLigne || local == null) rethrow;

      return local.sieges(voyageId: voyageId, monteeId: monteeId, descenteId: descenteId);
    }
  }

  @override
  Future<int?> tarif({required int monteeId, required int descenteId, int? voyageId}) async {
    try {
      return await _remote.tarif(monteeId: monteeId, descenteId: descenteId);
    } on ApiException catch (e) {
      final local = _local;
      if (!e.estHorsLigne || local == null) rethrow;

      return local.tarif(monteeId: monteeId, descenteId: descenteId, voyageId: voyageId);
    }
  }

  @override
  Future<TicketVendu> vendreTicket({
    required int voyageId,
    required int siegeId,
    required int monteeGareId,
    required int descenteGareId,
    String? nom,
    String? contact,
    String? remiseType,
    int? remiseValeur,
  }) async {
    try {
      return await _remote.vendreTicket(
        voyageId: voyageId,
        siegeId: siegeId,
        monteeGareId: monteeGareId,
        descenteGareId: descenteGareId,
        nom: nom,
        contact: contact,
        remiseType: remiseType,
        remiseValeur: remiseValeur,
      );
    } on ApiException catch (e) {
      if (!e.estHorsLigne) rethrow;

      return _vendreHorsLigne(
        voyageId: voyageId,
        siegeId: siegeId,
        monteeGareId: monteeGareId,
        descenteGareId: descenteGareId,
        nom: nom,
        contact: contact,
        remiseType: remiseType,
        remiseValeur: remiseValeur,
      );
    }
  }

  /// Encaisse sans réseau : le billet est composé ICI, imprimable immédiatement.
  ///
  /// Le client ne doit pas attendre le retour du réseau pour avoir son reçu — et ce reçu porte un
  /// code DÉFINITIF, encodé en QR. Le serveur le reprendra tel quel : le papier remis au client ne
  /// changera jamais de sens.
  ///
  /// Le prix inscrit ici est celui de la grille embarquée. C'est le montant encaissé, et il remonte
  /// comme tel — mais la grille du SERVEUR reste seule juge au moment de la synchronisation. Si un
  /// tarif a changé entre-temps, l'écart est consigné pour que la gare régularise.
  Future<TicketVendu> _vendreHorsLigne({
    required int voyageId,
    required int siegeId,
    required int monteeGareId,
    required int descenteGareId,
    String? nom,
    String? contact,
    String? remiseType,
    int? remiseValeur,
  }) async {
    final local = _local;
    final synchronisateur = _synchronisateur;
    final codes = _codes;

    if (local == null || synchronisateur == null || codes == null) {
      throw const ApiException(
        'Vente hors ligne indisponible : la préparation du voyage n\'a pas été faite.',
      );
    }

    final codevoyage = await local.codevoyage(voyageId);
    final tarif = await local.tarif(
      monteeId: monteeGareId,
      descenteId: descenteGareId,
      voyageId: voyageId,
    );

    if (codevoyage == null || tarif == null) {
      /*
        Sans instantané ou sans tarif pour ce trajet, on REFUSE plutôt que d'inventer un prix. Le
        serveur refuserait de la même façon ; encaisser ici créerait une dette impossible à
        rattacher.
      */
      throw const ApiException(
        'Aucun tarif embarqué pour ce trajet : impossible de vendre hors ligne.',
      );
    }

    final remise = _remise(tarif, remiseType, remiseValeur);
    await _verifierPlafond(local, voyageId: voyageId, tarif: tarif, remise: remise);

    final code = await codes.billet(voyageId: voyageId, codevoyage: codevoyage);

    await synchronisateur.deposer(OperationHorsLigne(
      reference: _uuid.v4(),
      voyageId: voyageId,
      type: TypeOperation.VENTE,
      instant: DateTime.now(),
      payload: {
        'codeticket': code,
        'gare': monteeGareId,
        'garedescente': descenteGareId,
        'siege': siegeId,
        'nomclient': nom,
        'contactclient': contact,
        'remisetype': remiseType,
        'remisevaleur': remiseValeur,
        'montantEncaisse': tarif - remise,
      },
      statut: BaseLocale.enAttente,
      creeLe: DateTime.now(),
    ));

    // Pas d'identifiant serveur : il n'existera qu'à la synchronisation. Le reçu, lui, n'en a pas
    // besoin — il porte le code, et c'est le code qui fait foi au contrôle.
    return TicketVendu(codeticket: code, prix: tarif - remise, remise: remise);
  }

  /// La même arithmétique QUE LES MÊMES REFUS que `TicketProcessor::resoudreRemise` côté serveur.
  ///
  /// Les refus comptent autant que le calcul. Ce qui se passait avant : le téléphone bornait
  /// silencieusement une remise excessive au tarif, encaissait, imprimait — et le serveur REFUSAIT la
  /// vente à la synchronisation. Le passager repartait avec un billet qui n'existerait jamais. Une
  /// règle rejouée doit refuser là où l'originale refuse, sinon elle ne protège personne.
  static int _remise(int tarif, String? type, int? valeur) {
    if (type == null || valeur == null || valeur <= 0) return 0;

    final remise = switch (type) {
      'POURCENTAGE' => (tarif * (valeur > 100 ? 100 : valeur) / 100).round(),
      'MONTANT' => valeur,
      _ => throw const ApiException('Type de remise invalide'),
    };

    if (remise > tarif) {
      throw ApiException(
        'La remise ne peut pas dépasser le prix du billet ($tarif FCFA)',
      );
    }

    return remise < 0 ? 0 : remise;
  }

  /// Le PLAFOND de remise de la compagnie, appliqué ICI et non plus supposé appliqué ailleurs.
  ///
  /// Il était embarqué dans l'instantané depuis le début… et personne ne le lisait. Un commentaire
  /// affirmait que l'écran de vente s'en chargeait : c'était faux, l'écran s'en remet au serveur. En
  /// ligne c'est sans conséquence — le serveur refuse avant qu'un billet n'existe. Hors ligne, la
  /// vente était encaissée et imprimée, puis refusée à la synchronisation.
  ///
  /// Même arithmétique que `TicketProcessor`, tolérance comprise : sans le `+ 0.001`, un arrondi
  /// ferait refuser une remise exactement au plafond.
  static Future<void> _verifierPlafond(
    VenteLocalDataSource local, {
    required int voyageId,
    required int tarif,
    required int remise,
  }) async {
    if (remise <= 0 || tarif <= 0) return;

    final plafond = await local.plafondRemisePourcentage(voyageId);
    if (plafond == null) return;

    final pourcentage = remise / tarif * 100;
    if (pourcentage > plafond + 0.001) {
      throw ApiException(
        'La remise de ${pourcentage.round()}% dépasse le plafond autorisé '
        '($plafond%) de votre compagnie.',
      );
    }
  }

  @override
  Future<BagageCree> ajouterBagage({
    required int voyageId,
    required String codeticket,
    int? ticketId,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    // Billet vendu hors ligne : il n'a aucun identifiant serveur, l'API ne peut rien en faire. On
    // n'essaie donc même pas — on met en file directement.
    if (ticketId == null) {
      return _bagageHorsLigne(
        voyageId: voyageId,
        codeticket: codeticket,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );
    }

    try {
      return await _remote.ajouterBagage(
        ticketId: ticketId,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );
    } on ApiException catch (e) {
      if (!e.estHorsLigne) rethrow;

      return _bagageHorsLigne(
        voyageId: voyageId,
        codeticket: codeticket,
        nature: nature,
        type: type,
        poids: poids,
        montant: montant,
      );
    }
  }

  /// Enregistre le bagage sans réseau : l'étiquette est composée ICI, imprimable immédiatement.
  ///
  /// Comme pour le billet, le code est DÉFINITIF : il est collé sur le bagage et lu à la livraison.
  /// Le montant, lui, est celui de la grille de poids embarquée — c'est ce que le vendeur a perçu,
  /// et il remonte comme tel. La grille du SERVEUR reste seule juge à la synchronisation ; un écart
  /// est consigné pour que la gare régularise.
  Future<BagageCree> _bagageHorsLigne({
    required int voyageId,
    required String codeticket,
    required String nature,
    required String type,
    required int poids,
    int? montant,
  }) async {
    final local = _local;
    final synchronisateur = _synchronisateur;
    final codes = _codes;

    if (local == null || synchronisateur == null || codes == null) {
      throw const ApiException(
        'Bagage hors ligne indisponible : la préparation du voyage n\'a pas été faite.',
      );
    }

    final codevoyage = await local.codevoyage(voyageId);
    if (codevoyage == null) {
      throw const ApiException(
        'Aucun instantané embarqué pour ce voyage : impossible d\'enregistrer un bagage hors ligne.',
      );
    }

    // Même arbitrage que `BagageProcessor::resoudreMontant` : la grille décide, sauf si l'agent a
    // saisi un montant — et ce montant-là est alors FORCÉ, comme au guichet.
    final grille = await local.tarifBagage(voyageId: voyageId, poids: poids);
    final force = montant != null && montant != grille;
    final facture = montant ?? grille;

    if (facture == null) {
      /*
        Aucune tranche ne couvre ce poids et l'agent n'a rien saisi. Le serveur refuserait de la
        même façon — mieux vaut le dire ici, avant d'encaisser, que d'accumuler une opération qui
        sera rejetée à la synchronisation.
      */
      throw ApiException(
        'Aucun tarif embarqué pour $poids kg. Veuillez saisir le montant manuellement.',
      );
    }

    final code = await codes.bagage(voyageId: voyageId, codevoyage: codevoyage);

    await synchronisateur.deposer(OperationHorsLigne(
      reference: _uuid.v4(),
      voyageId: voyageId,
      type: TypeOperation.BAGAGE,
      instant: DateTime.now(),
      payload: {
        'codebagage': code,
        // Le billet est désigné par son CODE : hors ligne, sa propre vente attend souvent dans la
        // même file et il n'a pas encore d'identifiant serveur.
        'codeticket': codeticket,
        'nature': nature,
        'type': type,
        'poids': poids,
        'montant': force ? facture : null,
        'montantEncaisse': facture,
      },
      statut: BaseLocale.enAttente,
      creeLe: DateTime.now(),
    ));

    return (codebagage: code, montant: facture, montantForce: force);
  }
}
