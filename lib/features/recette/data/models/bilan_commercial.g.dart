// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bilan_commercial.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BilanChiffres _$BilanChiffresFromJson(Map<String, dynamic> json) =>
    _BilanChiffres(
      recette: (json['recette'] as num?)?.toInt() ?? 0,
      recetteBillets: (json['recetteBillets'] as num?)?.toInt() ?? 0,
      recetteBagages: (json['recetteBagages'] as num?)?.toInt() ?? 0,
      nbBillets: (json['nbBillets'] as num?)?.toInt() ?? 0,
      nbBagages: (json['nbBagages'] as num?)?.toInt() ?? 0,
      panierMoyen: (json['panierMoyen'] as num?)?.toInt() ?? 0,
      nbVoyages: (json['nbVoyages'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$BilanChiffresToJson(_BilanChiffres instance) =>
    <String, dynamic>{
      'recette': instance.recette,
      'recetteBillets': instance.recetteBillets,
      'recetteBagages': instance.recetteBagages,
      'nbBillets': instance.nbBillets,
      'nbBagages': instance.nbBagages,
      'panierMoyen': instance.panierMoyen,
      'nbVoyages': instance.nbVoyages,
    };

_BilanPeriode _$BilanPeriodeFromJson(Map<String, dynamic> json) =>
    _BilanPeriode(debut: json['debut'] as String?, fin: json['fin'] as String?);

Map<String, dynamic> _$BilanPeriodeToJson(_BilanPeriode instance) =>
    <String, dynamic>{'debut': instance.debut, 'fin': instance.fin};

_BilanCommercial _$BilanCommercialFromJson(Map<String, dynamic> json) =>
    _BilanCommercial(
      periode: json['periode'] == null
          ? null
          : BilanPeriode.fromJson(json['periode'] as Map<String, dynamic>),
      surPeriode: json['surPeriode'] == null
          ? const BilanChiffres()
          : BilanChiffres.fromJson(json['surPeriode'] as Map<String, dynamic>),
      total: json['total'] == null
          ? const BilanChiffres()
          : BilanChiffres.fromJson(json['total'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BilanCommercialToJson(_BilanCommercial instance) =>
    <String, dynamic>{
      'periode': instance.periode,
      'surPeriode': instance.surPeriode,
      'total': instance.total,
    };
