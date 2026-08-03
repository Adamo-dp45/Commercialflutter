// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entreprise.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Entreprise _$EntrepriseFromJson(Map<String, dynamic> json) => _Entreprise(
  libelle: json['libelle'] as String?,
  sigle: json['sigle'] as String?,
  contact1: json['contact1'] as String?,
  contact2: json['contact2'] as String?,
);

Map<String, dynamic> _$EntrepriseToJson(_Entreprise instance) =>
    <String, dynamic>{
      'libelle': instance.libelle,
      'sigle': instance.sigle,
      'contact1': instance.contact1,
      'contact2': instance.contact2,
    };
