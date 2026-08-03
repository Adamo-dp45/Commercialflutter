// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voyage_commercial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoyageCommercial _$VoyageCommercialFromJson(Map<String, dynamic> json) =>
    _VoyageCommercial(
      id: (json['id'] as num).toInt(),
      codevoyage: json['codevoyage'] as String?,
      provenance: json['provenance'] as String?,
      destination: json['destination'] as String?,
      datedepartprevue: json['datedepartprevue'] == null
          ? null
          : DateTime.parse(json['datedepartprevue'] as String),
      demarre: json['demarre'] as bool? ?? false,
      placestotal: (json['placestotal'] as num?)?.toInt() ?? 0,
      placesoccupees: (json['placesoccupees'] as num?)?.toInt() ?? 0,
      garecouranteId: (json['garecouranteId'] as num?)?.toInt(),
      garecouranteLibelle: json['garecouranteLibelle'] as String?,
      carId: (json['carId'] as num?)?.toInt(),
      carMatricule: json['carMatricule'] as String?,
      peutRepartir: json['peutRepartir'] as bool? ?? false,
      arrets:
          (json['arrets'] as List<dynamic>?)
              ?.map((e) => Arret.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Arret>[],
      maRecette: (json['maRecette'] as num?)?.toInt() ?? 0,
      mesTickets: (json['mesTickets'] as num?)?.toInt() ?? 0,
      mesBagages: (json['mesBagages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VoyageCommercialToJson(_VoyageCommercial instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codevoyage': instance.codevoyage,
      'provenance': instance.provenance,
      'destination': instance.destination,
      'datedepartprevue': instance.datedepartprevue?.toIso8601String(),
      'demarre': instance.demarre,
      'placestotal': instance.placestotal,
      'placesoccupees': instance.placesoccupees,
      'garecouranteId': instance.garecouranteId,
      'garecouranteLibelle': instance.garecouranteLibelle,
      'carId': instance.carId,
      'carMatricule': instance.carMatricule,
      'peutRepartir': instance.peutRepartir,
      'arrets': instance.arrets,
      'maRecette': instance.maRecette,
      'mesTickets': instance.mesTickets,
      'mesBagages': instance.mesBagages,
    };
