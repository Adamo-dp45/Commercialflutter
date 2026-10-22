import 'package:freezed_annotation/freezed_annotation.dart';

import 'droits_effectifs.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// Utilisateur connecté, tel que renvoyé par `GET /api/me`.
///
/// LES DROITS VIENNENT DU SERVEUR (21/10/2026). L'application ne reproduit plus aucune règle
/// d'accès : elle appelle [can], qui cherche dans ce que l'API a accordé. Voir [DroitsEffectifs]
/// pour ce que cela remplace et pourquoi.
///
/// `roles` reste servi et conservé : c'est une DONNÉE du profil (elle peut s'afficher), plus
/// jamais une entrée de décision. Lui redonner un rôle dans `can` rouvrirait la divergence que ce
/// chantier a fermée.
@freezed
abstract class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    int? id,
    String? email,
    String? nom,
    String? prenom,
    @Default(<String>[]) List<String> roles,
    int? entrepriseid,
    String? fileUrl,
    @JsonKey(
      name: 'permissions',
      fromJson: DroitsEffectifs.depuisJson,
      includeToJson: false,
    )
    @Default(DroitsEffectifs.aucun) DroitsEffectifs droits,
  }) = _AuthUser;

  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  /// Nom affichable : « Prénom Nom », ou l'e-mail à défaut.
  String get displayName {
    final parts = [prenom, nom]
        .where((s) => s != null && s.trim().isNotEmpty)
        .map((s) => s!.trim())
        .toList();
    if (parts.isNotEmpty) return parts.join(' ');
    return email ?? 'Commercial';
  }

  /// L'utilisateur peut-il agir sur [entity] via [action] ?
  bool can(String entity, String action) => droits.permet(entity, action);
}
