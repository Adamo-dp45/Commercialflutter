import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// Permission métier RBAC : un couple (entité, action), ex. `Bagage` / `CREER`.
@freezed
abstract class Permission with _$Permission {
  const factory Permission({
    required String entity,
    required String action,
  }) = _Permission;

  factory Permission.fromJson(Map<String, dynamic> json) =>
      _$PermissionFromJson(json);
}

/// Utilisateur connecté, tel que renvoyé par `GET /api/me`.
///
/// Les permissions sont APLATIES depuis `userRoles[].role.permissions[]` à la
/// lecture, pour offrir un simple [can] à l'UI (utile ensuite pour la gestion
/// des bagages, conditionnée à `Bagage/CREER`).
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
      name: 'userRoles',
      fromJson: _permissionsFromUserRoles,
      includeToJson: false,
    )
    @Default(<Permission>[]) List<Permission> permissions,
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

  bool get isAdmin =>
      roles.contains('ROLE_ADMIN') || roles.contains('ROLE_SUPER_ADMIN');

  /// Entités BORNÉES PAR LA GARE : miroir EXACT de `GareScopedEntities::ENTITIES`
  /// côté backend. Un `ROLE_ADMIN_GARE` y agit SANS permission explicite (ses
  /// données sont déjà restreintes à sa gare par `GareScopeExtension`).
  static const _gareScopedEntities = {
    'voyage',
    'ticket',
    'reservation',
    'courrier',
    'bagage',
    'user',
    'role',
    // Aucun écran de dépense ici, mais la liste est un MIROIR de 'GareScopedEntities::ENTITIES'
    // côté serveur : la laisser diverger, c'est se préparer à masquer un jour un bouton que le
    // serveur autorise.
    'depense',
  };

  /// L'utilisateur peut-il agir sur [entity] via [action] ?
  ///
  /// Reproduit `PermissionVoter` côté backend, SINON l'UI masque des actions que
  /// l'API autoriserait :
  ///  - `ROLE_ADMIN` / `ROLE_SUPER_ADMIN` → bypass total ;
  ///  - `ROLE_ADMIN_GARE` → bypass sur les entités bornées par sa gare (Ticket,
  ///    Bagage…). C'est CE bypass qui permet à un admin de gare AFFECTÉ COMME
  ///    COMMERCIAL de vendre et de gérer les bagages, alors qu'il n'a aucune
  ///    permission RBAC explicite ;
  ///  - sinon → permission explicite portée par ses rôles.
  bool can(String entity, String action) {
    if (isAdmin) return true;
    final e = entity.toLowerCase();
    final a = action.toUpperCase();
    if (roles.contains('ROLE_ADMIN_GARE') && _gareScopedEntities.contains(e)) {
      return true;
    }
    return permissions.any(
      (p) => p.entity.toLowerCase() == e && p.action.toUpperCase() == a,
    );
  }
}

/// Aplati `userRoles[].role.permissions[]` en une liste de [Permission],
/// tolérant aux formes inattendues (jamais d'exception de parsing ici).
List<Permission> _permissionsFromUserRoles(dynamic userRoles) {
  if (userRoles is! List) return const [];
  final result = <Permission>[];
  for (final ur in userRoles) {
    final role = (ur is Map) ? ur['role'] : null;
    final perms = (role is Map) ? role['permissions'] : null;
    if (perms is List) {
      for (final p in perms) {
        if (p is Map && p['entity'] != null && p['action'] != null) {
          result.add(
            Permission(
              entity: p['entity'].toString(),
              action: p['action'].toString(),
            ),
          );
        }
      }
    }
  }
  return result;
}
