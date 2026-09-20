// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'siege.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Siege _$SiegeFromJson(Map<String, dynamic> json) => _Siege(
  id: (json['id'] as num).toInt(),
  numero: (json['numero'] as num).toInt(),
  rangee: (json['rangee'] as num?)?.toInt() ?? 0,
  colonne: (json['colonne'] as num?)?.toInt() ?? 0,
  cote: json['cote'] as String? ?? 'GAUCHE',
  statut: json['statut'] as String? ?? 'LIBRE',
  revendu: json['revendu'] as bool? ?? false,
  conflit: json['conflit'] as bool? ?? false,
  occupantNom: json['occupantNom'] as String?,
  occupantTicketId: (json['occupantTicketId'] as num?)?.toInt(),
  venduAval: json['venduAval'] as bool? ?? false,
  avalNom: json['avalNom'] as String?,
  avalMontee: json['avalMontee'] as String?,
  avalDescente: json['avalDescente'] as String?,
  avalNombre: (json['avalNombre'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$SiegeToJson(_Siege instance) => <String, dynamic>{
  'id': instance.id,
  'numero': instance.numero,
  'rangee': instance.rangee,
  'colonne': instance.colonne,
  'cote': instance.cote,
  'statut': instance.statut,
  'revendu': instance.revendu,
  'conflit': instance.conflit,
  'occupantNom': instance.occupantNom,
  'occupantTicketId': instance.occupantTicketId,
  'venduAval': instance.venduAval,
  'avalNom': instance.avalNom,
  'avalMontee': instance.avalMontee,
  'avalDescente': instance.avalDescente,
  'avalNombre': instance.avalNombre,
};
