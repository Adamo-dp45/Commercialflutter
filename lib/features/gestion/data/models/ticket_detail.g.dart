// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketDetail _$TicketDetailFromJson(Map<String, dynamic> json) =>
    _TicketDetail(
      id: (json['id'] as num).toInt(),
      codeticket: json['codeticket'] as String?,
      prix: (json['prix'] as num?)?.toInt() ?? 0,
      remise: (json['remise'] as num?)?.toInt() ?? 0,
      nomclient: json['nomclient'] as String?,
      contactclient: json['contactclient'] as String?,
      statut: json['statut'] as String? ?? 'VALIDE',
      siegeNumero: (json['siegeNumero'] as num?)?.toInt(),
      monteeGareId: (json['monteeGareId'] as num?)?.toInt(),
      monteeLibelle: json['monteeLibelle'] as String?,
      descenteGareId: (json['descenteGareId'] as num?)?.toInt(),
      descenteLibelle: json['descenteLibelle'] as String?,
      dateEmission: json['dateEmission'] == null
          ? null
          : DateTime.parse(json['dateEmission'] as String),
    );

Map<String, dynamic> _$TicketDetailToJson(_TicketDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codeticket': instance.codeticket,
      'prix': instance.prix,
      'remise': instance.remise,
      'nomclient': instance.nomclient,
      'contactclient': instance.contactclient,
      'statut': instance.statut,
      'siegeNumero': instance.siegeNumero,
      'monteeGareId': instance.monteeGareId,
      'monteeLibelle': instance.monteeLibelle,
      'descenteGareId': instance.descenteGareId,
      'descenteLibelle': instance.descenteLibelle,
      'dateEmission': instance.dateEmission?.toIso8601String(),
    };
