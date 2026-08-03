// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Permission _$PermissionFromJson(Map<String, dynamic> json) => _Permission(
  entity: json['entity'] as String,
  action: json['action'] as String,
);

Map<String, dynamic> _$PermissionToJson(_Permission instance) =>
    <String, dynamic>{'entity': instance.entity, 'action': instance.action};

_AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => _AuthUser(
  id: (json['id'] as num?)?.toInt(),
  email: json['email'] as String?,
  nom: json['nom'] as String?,
  prenom: json['prenom'] as String?,
  roles:
      (json['roles'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  entrepriseid: (json['entrepriseid'] as num?)?.toInt(),
  fileUrl: json['fileUrl'] as String?,
  permissions: json['userRoles'] == null
      ? const <Permission>[]
      : _permissionsFromUserRoles(json['userRoles']),
);

Map<String, dynamic> _$AuthUserToJson(_AuthUser instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'roles': instance.roles,
  'entrepriseid': instance.entrepriseid,
  'fileUrl': instance.fileUrl,
};
