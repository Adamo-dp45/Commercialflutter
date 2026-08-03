import 'package:freezed_annotation/freezed_annotation.dart';

part 'arret.freezed.dart';
part 'arret.g.dart';

/// Un arrêt d'une ligne : une gare + son ordre le long du trajet.
@freezed
abstract class Arret with _$Arret {
  const factory Arret({
    required int id,
    required String libelle,
    required int ordre,
  }) = _Arret;

  factory Arret.fromJson(Map<String, dynamic> json) => _$ArretFromJson(json);
}
