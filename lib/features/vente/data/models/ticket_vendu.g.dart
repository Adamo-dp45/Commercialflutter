// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket_vendu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TicketVendu _$TicketVenduFromJson(Map<String, dynamic> json) => _TicketVendu(
  id: (json['id'] as num?)?.toInt(),
  codeticket: json['codeticket'] as String?,
  prix: (json['prix'] as num?)?.toInt(),
  remise: (json['remise'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TicketVenduToJson(_TicketVendu instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codeticket': instance.codeticket,
      'prix': instance.prix,
      'remise': instance.remise,
    };
