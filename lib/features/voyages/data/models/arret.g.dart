// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'arret.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Arret _$ArretFromJson(Map<String, dynamic> json) => _Arret(
  id: (json['id'] as num).toInt(),
  libelle: json['libelle'] as String,
  ordre: (json['ordre'] as num).toInt(),
);

Map<String, dynamic> _$ArretToJson(_Arret instance) => <String, dynamic>{
  'id': instance.id,
  'libelle': instance.libelle,
  'ordre': instance.ordre,
};
