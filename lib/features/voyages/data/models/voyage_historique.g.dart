// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voyage_historique.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VoyageHistorique _$VoyageHistoriqueFromJson(Map<String, dynamic> json) =>
    _VoyageHistorique(
      id: (json['id'] as num).toInt(),
      codevoyage: json['codevoyage'] as String?,
      numerodepart: (json['numerodepart'] as num?)?.toInt(),
      provenance: json['provenance'] as String?,
      destination: json['destination'] as String?,
      datedepartprevue: json['datedepartprevue'] == null
          ? null
          : DateTime.parse(json['datedepartprevue'] as String),
      datearriveereelle: json['datearriveereelle'] == null
          ? null
          : DateTime.parse(json['datearriveereelle'] as String),
      demarre: json['demarre'] as bool? ?? false,
      cloture: json['cloture'] as bool? ?? false,
      carMatricule: json['carMatricule'] as String?,
      maRecette: (json['maRecette'] as num?)?.toInt() ?? 0,
      mesTickets: (json['mesTickets'] as num?)?.toInt() ?? 0,
      mesBagages: (json['mesBagages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$VoyageHistoriqueToJson(_VoyageHistorique instance) =>
    <String, dynamic>{
      'id': instance.id,
      'codevoyage': instance.codevoyage,
      'numerodepart': instance.numerodepart,
      'provenance': instance.provenance,
      'destination': instance.destination,
      'datedepartprevue': instance.datedepartprevue?.toIso8601String(),
      'datearriveereelle': instance.datearriveereelle?.toIso8601String(),
      'demarre': instance.demarre,
      'cloture': instance.cloture,
      'carMatricule': instance.carMatricule,
      'maRecette': instance.maRecette,
      'mesTickets': instance.mesTickets,
      'mesBagages': instance.mesBagages,
    };

_PageVoyages _$PageVoyagesFromJson(Map<String, dynamic> json) => _PageVoyages(
  voyages:
      (json['voyages'] as List<dynamic>?)
          ?.map((e) => VoyageHistorique.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <VoyageHistorique>[],
  page: (json['page'] as num?)?.toInt() ?? 1,
  parPage: (json['parPage'] as num?)?.toInt() ?? 20,
  total: (json['total'] as num?)?.toInt() ?? 0,
  pages: (json['pages'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$PageVoyagesToJson(_PageVoyages instance) =>
    <String, dynamic>{
      'voyages': instance.voyages,
      'page': instance.page,
      'parPage': instance.parPage,
      'total': instance.total,
      'pages': instance.pages,
    };
