/// CE QUE LE SERVEUR AUTORISE, tel qu'il le dit lui-même (21/10/2026).
///
/// `GET /api/me` sert désormais les droits EFFECTIFS de l'utilisateur :
/// `{"tout": false, "accordees": ["ticket:CREER", "ticket:VOIR"]}`. L'application lit, elle ne
/// décide plus.
///
/// !! CE QU'ELLE FAISAIT AVANT, ET POURQUOI C'ÉTAIT UN PROBLÈME. `AuthUser.can()` rejouait la
/// règle du `PermissionVoter` du serveur — bypass administrateur, bypass partiel de l'admin de
/// gare, et la liste de ses entités recopiée à la main — exactement comme le front web de son
/// côté. Trois écritures de la même règle, qu'aucun code n'obligeait à rester d'accord. Elles
/// avaient d'ailleurs cessé de l'être : cette application accordait TOUT à un `ROLE_SUPER_ADMIN`
/// que le serveur, lui, n'autorisait à rien.
///
/// !! AUCUN REPLI SUR UN CALCUL LOCAL, et c'est voulu : un profil sans le champ n'accorde RIEN.
/// Le calcul d'avant a d'abord été gardé pour les profils mis en cache par une version
/// antérieure, puis supprimé — l'application n'est pas en production, aucun cache ancien ne
/// circule, et garder une seconde écriture de la règle « au cas où » aurait rouvert ce que ce
/// chantier ferme. Un profil vide se répare par une reconnexion.
class DroitsEffectifs {
  const DroitsEffectifs({
    this.tout = false,
    this.accordees = const <String>{},
  });

  /// Aucun droit : profil absent, abîmé, ou simplement vide.
  static const aucun = DroitsEffectifs();

  /// L'utilisateur passe avant toute vérification (administrateur d'entreprise).
  ///
  /// Un drapeau, et non l'énumération de toutes les entités : une énumération pourrait être
  /// INCOMPLÈTE, et un oubli masquerait un écran sans que rien ne le signale.
  final bool tout;

  /// Les droits accordés, sous la forme `entite:ACTION` que sert l'API.
  ///
  /// Un `Set` plutôt que la `List` reçue : la recherche est le seul usage, et elle a lieu à
  /// chaque bouton dessiné. Un admin de gare en porte plus de quatre-vingts.
  final Set<String> accordees;

  bool permet(String entite, String action) {
    if (tout) return true;
    return accordees.contains('${entite.toLowerCase()}:${action.toUpperCase()}');
  }

  /// Lit la charge de `/api/me`, sans jamais lever : un profil abîmé ou d'une autre version
  /// n'accorde rien, mais il ne doit pas renvoyer le vendeur à l'écran de connexion.
  static DroitsEffectifs depuisJson(dynamic json) {
    if (json is! Map) return aucun;

    final brut = json['accordees'];

    return DroitsEffectifs(
      tout: json['tout'] == true,
      accordees: brut is List
          ? brut.map((d) => d.toString()).toSet()
          : const <String>{},
    );
  }

  /*
    ÉGALITÉ ÉCRITE À LA MAIN, et sur le CONTENU.

    Riverpod compare les états pour décider s'il reconstruit : sans cela, deux profils lus du même
    JSON seraient tenus pour différents (deux `Set` distincts), et chaque rafraîchissement de jeton
    redessinerait l'application. `DeepCollectionEquality` du paquet `collection` ferait le travail,
    mais ce paquet n'est qu'une dépendance TRANSITIVE ici — l'importer sans le déclarer est
    précisément ce que l'analyseur signale, et le déclarer pour trois lignes serait disproportionné.
  */
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DroitsEffectifs &&
          other.tout == tout &&
          other.accordees.length == accordees.length &&
          other.accordees.containsAll(accordees);

  @override
  int get hashCode => Object.hash(
        tout,
        // L'API sert une liste TRIÉE, mais un `Set` ne promet aucun ordre de parcours : on somme
        // les empreintes plutôt que de les enchaîner, pour que deux ensembles égaux donnent la
        // même valeur quel que soit l'ordre.
        accordees.fold<int>(0, (acc, droit) => acc ^ droit.hashCode),
      );
}
