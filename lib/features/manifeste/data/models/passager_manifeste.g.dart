// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passager_manifeste.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PassagerManifeste _$PassagerManifesteFromJson(Map<String, dynamic> json) =>
    _PassagerManifeste(
      ticketId: (json['ticketId'] as num?)?.toInt(),
      codeticket: json['codeticket'] as String?,
      siegeNumero: (json['siegeNumero'] as num?)?.toInt(),
      nomclient: json['nomclient'] as String?,
      contactclient: json['contactclient'] as String?,
      monteeLibelle: json['monteeLibelle'] as String?,
      descenteLibelle: json['descenteLibelle'] as String?,
      aBord: json['aBord'] as bool? ?? false,
    );

Map<String, dynamic> _$PassagerManifesteToJson(_PassagerManifeste instance) =>
    <String, dynamic>{
      'ticketId': instance.ticketId,
      'codeticket': instance.codeticket,
      'siegeNumero': instance.siegeNumero,
      'nomclient': instance.nomclient,
      'contactclient': instance.contactclient,
      'monteeLibelle': instance.monteeLibelle,
      'descenteLibelle': instance.descenteLibelle,
      'aBord': instance.aBord,
    };
