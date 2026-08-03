// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bagage_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BagageDetail _$BagageDetailFromJson(Map<String, dynamic> json) =>
    _BagageDetail(
      id: (json['id'] as num).toInt(),
      codebagage: json['codebagage'] as String?,
      nature: json['nature'] as String?,
      type: json['type'] as String?,
      poids: (json['poids'] as num?)?.toInt() ?? 0,
      montant: (json['montant'] as num?)?.toInt() ?? 0,
      montantForce: json['montantforce'] as bool? ?? false,
      statut: json['statut'] as String? ?? 'ENREGISTRE',
      ticketId: (json['ticketId'] as num?)?.toInt(),
      codeticket: json['codeticket'] as String?,
      nomclient: json['nomclient'] as String?,
      contactclient: json['contactclient'] as String?,
      monteeLibelle: json['monteeLibelle'] as String?,
      descenteLibelle: json['descenteLibelle'] as String?,
    );

Map<String, dynamic> _$BagageDetailToJson(_BagageDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codebagage': instance.codebagage,
      'nature': instance.nature,
      'type': instance.type,
      'poids': instance.poids,
      'montant': instance.montant,
      'montantforce': instance.montantForce,
      'statut': instance.statut,
      'ticketId': instance.ticketId,
      'codeticket': instance.codeticket,
      'nomclient': instance.nomclient,
      'contactclient': instance.contactclient,
      'monteeLibelle': instance.monteeLibelle,
      'descenteLibelle': instance.descenteLibelle,
    };
