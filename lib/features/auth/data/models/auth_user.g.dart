// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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
  droits: json['permissions'] == null
      ? DroitsEffectifs.aucun
      : DroitsEffectifs.depuisJson(json['permissions']),
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
