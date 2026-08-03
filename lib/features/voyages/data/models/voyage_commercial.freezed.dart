// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voyage_commercial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoyageCommercial {

 int get id; String? get codevoyage; String? get provenance; String? get destination; DateTime? get datedepartprevue; bool get demarre; int get placestotal; int get placesoccupees; int? get garecouranteId; String? get garecouranteLibelle; int? get carId; String? get carMatricule; bool get peutRepartir; List<Arret> get arrets; int get maRecette; int get mesTickets; int get mesBagages;
/// Create a copy of VoyageCommercial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoyageCommercialCopyWith<VoyageCommercial> get copyWith => _$VoyageCommercialCopyWithImpl<VoyageCommercial>(this as VoyageCommercial, _$identity);

  /// Serializes this VoyageCommercial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoyageCommercial&&(identical(other.id, id) || other.id == id)&&(identical(other.codevoyage, codevoyage) || other.codevoyage == codevoyage)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.datedepartprevue, datedepartprevue) || other.datedepartprevue == datedepartprevue)&&(identical(other.demarre, demarre) || other.demarre == demarre)&&(identical(other.placestotal, placestotal) || other.placestotal == placestotal)&&(identical(other.placesoccupees, placesoccupees) || other.placesoccupees == placesoccupees)&&(identical(other.garecouranteId, garecouranteId) || other.garecouranteId == garecouranteId)&&(identical(other.garecouranteLibelle, garecouranteLibelle) || other.garecouranteLibelle == garecouranteLibelle)&&(identical(other.carId, carId) || other.carId == carId)&&(identical(other.carMatricule, carMatricule) || other.carMatricule == carMatricule)&&(identical(other.peutRepartir, peutRepartir) || other.peutRepartir == peutRepartir)&&const DeepCollectionEquality().equals(other.arrets, arrets)&&(identical(other.maRecette, maRecette) || other.maRecette == maRecette)&&(identical(other.mesTickets, mesTickets) || other.mesTickets == mesTickets)&&(identical(other.mesBagages, mesBagages) || other.mesBagages == mesBagages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codevoyage,provenance,destination,datedepartprevue,demarre,placestotal,placesoccupees,garecouranteId,garecouranteLibelle,carId,carMatricule,peutRepartir,const DeepCollectionEquality().hash(arrets),maRecette,mesTickets,mesBagages);

@override
String toString() {
  return 'VoyageCommercial(id: $id, codevoyage: $codevoyage, provenance: $provenance, destination: $destination, datedepartprevue: $datedepartprevue, demarre: $demarre, placestotal: $placestotal, placesoccupees: $placesoccupees, garecouranteId: $garecouranteId, garecouranteLibelle: $garecouranteLibelle, carId: $carId, carMatricule: $carMatricule, peutRepartir: $peutRepartir, arrets: $arrets, maRecette: $maRecette, mesTickets: $mesTickets, mesBagages: $mesBagages)';
}


}

/// @nodoc
abstract mixin class $VoyageCommercialCopyWith<$Res>  {
  factory $VoyageCommercialCopyWith(VoyageCommercial value, $Res Function(VoyageCommercial) _then) = _$VoyageCommercialCopyWithImpl;
@useResult
$Res call({
 int id, String? codevoyage, String? provenance, String? destination, DateTime? datedepartprevue, bool demarre, int placestotal, int placesoccupees, int? garecouranteId, String? garecouranteLibelle, int? carId, String? carMatricule, bool peutRepartir, List<Arret> arrets, int maRecette, int mesTickets, int mesBagages
});




}
/// @nodoc
class _$VoyageCommercialCopyWithImpl<$Res>
    implements $VoyageCommercialCopyWith<$Res> {
  _$VoyageCommercialCopyWithImpl(this._self, this._then);

  final VoyageCommercial _self;
  final $Res Function(VoyageCommercial) _then;

/// Create a copy of VoyageCommercial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codevoyage = freezed,Object? provenance = freezed,Object? destination = freezed,Object? datedepartprevue = freezed,Object? demarre = null,Object? placestotal = null,Object? placesoccupees = null,Object? garecouranteId = freezed,Object? garecouranteLibelle = freezed,Object? carId = freezed,Object? carMatricule = freezed,Object? peutRepartir = null,Object? arrets = null,Object? maRecette = null,Object? mesTickets = null,Object? mesBagages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codevoyage: freezed == codevoyage ? _self.codevoyage : codevoyage // ignore: cast_nullable_to_non_nullable
as String?,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,datedepartprevue: freezed == datedepartprevue ? _self.datedepartprevue : datedepartprevue // ignore: cast_nullable_to_non_nullable
as DateTime?,demarre: null == demarre ? _self.demarre : demarre // ignore: cast_nullable_to_non_nullable
as bool,placestotal: null == placestotal ? _self.placestotal : placestotal // ignore: cast_nullable_to_non_nullable
as int,placesoccupees: null == placesoccupees ? _self.placesoccupees : placesoccupees // ignore: cast_nullable_to_non_nullable
as int,garecouranteId: freezed == garecouranteId ? _self.garecouranteId : garecouranteId // ignore: cast_nullable_to_non_nullable
as int?,garecouranteLibelle: freezed == garecouranteLibelle ? _self.garecouranteLibelle : garecouranteLibelle // ignore: cast_nullable_to_non_nullable
as String?,carId: freezed == carId ? _self.carId : carId // ignore: cast_nullable_to_non_nullable
as int?,carMatricule: freezed == carMatricule ? _self.carMatricule : carMatricule // ignore: cast_nullable_to_non_nullable
as String?,peutRepartir: null == peutRepartir ? _self.peutRepartir : peutRepartir // ignore: cast_nullable_to_non_nullable
as bool,arrets: null == arrets ? _self.arrets : arrets // ignore: cast_nullable_to_non_nullable
as List<Arret>,maRecette: null == maRecette ? _self.maRecette : maRecette // ignore: cast_nullable_to_non_nullable
as int,mesTickets: null == mesTickets ? _self.mesTickets : mesTickets // ignore: cast_nullable_to_non_nullable
as int,mesBagages: null == mesBagages ? _self.mesBagages : mesBagages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoyageCommercial].
extension VoyageCommercialPatterns on VoyageCommercial {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoyageCommercial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoyageCommercial() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoyageCommercial value)  $default,){
final _that = this;
switch (_that) {
case _VoyageCommercial():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoyageCommercial value)?  $default,){
final _that = this;
switch (_that) {
case _VoyageCommercial() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? codevoyage,  String? provenance,  String? destination,  DateTime? datedepartprevue,  bool demarre,  int placestotal,  int placesoccupees,  int? garecouranteId,  String? garecouranteLibelle,  int? carId,  String? carMatricule,  bool peutRepartir,  List<Arret> arrets,  int maRecette,  int mesTickets,  int mesBagages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoyageCommercial() when $default != null:
return $default(_that.id,_that.codevoyage,_that.provenance,_that.destination,_that.datedepartprevue,_that.demarre,_that.placestotal,_that.placesoccupees,_that.garecouranteId,_that.garecouranteLibelle,_that.carId,_that.carMatricule,_that.peutRepartir,_that.arrets,_that.maRecette,_that.mesTickets,_that.mesBagages);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? codevoyage,  String? provenance,  String? destination,  DateTime? datedepartprevue,  bool demarre,  int placestotal,  int placesoccupees,  int? garecouranteId,  String? garecouranteLibelle,  int? carId,  String? carMatricule,  bool peutRepartir,  List<Arret> arrets,  int maRecette,  int mesTickets,  int mesBagages)  $default,) {final _that = this;
switch (_that) {
case _VoyageCommercial():
return $default(_that.id,_that.codevoyage,_that.provenance,_that.destination,_that.datedepartprevue,_that.demarre,_that.placestotal,_that.placesoccupees,_that.garecouranteId,_that.garecouranteLibelle,_that.carId,_that.carMatricule,_that.peutRepartir,_that.arrets,_that.maRecette,_that.mesTickets,_that.mesBagages);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? codevoyage,  String? provenance,  String? destination,  DateTime? datedepartprevue,  bool demarre,  int placestotal,  int placesoccupees,  int? garecouranteId,  String? garecouranteLibelle,  int? carId,  String? carMatricule,  bool peutRepartir,  List<Arret> arrets,  int maRecette,  int mesTickets,  int mesBagages)?  $default,) {final _that = this;
switch (_that) {
case _VoyageCommercial() when $default != null:
return $default(_that.id,_that.codevoyage,_that.provenance,_that.destination,_that.datedepartprevue,_that.demarre,_that.placestotal,_that.placesoccupees,_that.garecouranteId,_that.garecouranteLibelle,_that.carId,_that.carMatricule,_that.peutRepartir,_that.arrets,_that.maRecette,_that.mesTickets,_that.mesBagages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoyageCommercial extends VoyageCommercial {
  const _VoyageCommercial({required this.id, this.codevoyage, this.provenance, this.destination, this.datedepartprevue, this.demarre = false, this.placestotal = 0, this.placesoccupees = 0, this.garecouranteId, this.garecouranteLibelle, this.carId, this.carMatricule, this.peutRepartir = false, final  List<Arret> arrets = const <Arret>[], this.maRecette = 0, this.mesTickets = 0, this.mesBagages = 0}): _arrets = arrets,super._();
  factory _VoyageCommercial.fromJson(Map<String, dynamic> json) => _$VoyageCommercialFromJson(json);

@override final  int id;
@override final  String? codevoyage;
@override final  String? provenance;
@override final  String? destination;
@override final  DateTime? datedepartprevue;
@override@JsonKey() final  bool demarre;
@override@JsonKey() final  int placestotal;
@override@JsonKey() final  int placesoccupees;
@override final  int? garecouranteId;
@override final  String? garecouranteLibelle;
@override final  int? carId;
@override final  String? carMatricule;
@override@JsonKey() final  bool peutRepartir;
 final  List<Arret> _arrets;
@override@JsonKey() List<Arret> get arrets {
  if (_arrets is EqualUnmodifiableListView) return _arrets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_arrets);
}

@override@JsonKey() final  int maRecette;
@override@JsonKey() final  int mesTickets;
@override@JsonKey() final  int mesBagages;

/// Create a copy of VoyageCommercial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoyageCommercialCopyWith<_VoyageCommercial> get copyWith => __$VoyageCommercialCopyWithImpl<_VoyageCommercial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoyageCommercialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoyageCommercial&&(identical(other.id, id) || other.id == id)&&(identical(other.codevoyage, codevoyage) || other.codevoyage == codevoyage)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.datedepartprevue, datedepartprevue) || other.datedepartprevue == datedepartprevue)&&(identical(other.demarre, demarre) || other.demarre == demarre)&&(identical(other.placestotal, placestotal) || other.placestotal == placestotal)&&(identical(other.placesoccupees, placesoccupees) || other.placesoccupees == placesoccupees)&&(identical(other.garecouranteId, garecouranteId) || other.garecouranteId == garecouranteId)&&(identical(other.garecouranteLibelle, garecouranteLibelle) || other.garecouranteLibelle == garecouranteLibelle)&&(identical(other.carId, carId) || other.carId == carId)&&(identical(other.carMatricule, carMatricule) || other.carMatricule == carMatricule)&&(identical(other.peutRepartir, peutRepartir) || other.peutRepartir == peutRepartir)&&const DeepCollectionEquality().equals(other._arrets, _arrets)&&(identical(other.maRecette, maRecette) || other.maRecette == maRecette)&&(identical(other.mesTickets, mesTickets) || other.mesTickets == mesTickets)&&(identical(other.mesBagages, mesBagages) || other.mesBagages == mesBagages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codevoyage,provenance,destination,datedepartprevue,demarre,placestotal,placesoccupees,garecouranteId,garecouranteLibelle,carId,carMatricule,peutRepartir,const DeepCollectionEquality().hash(_arrets),maRecette,mesTickets,mesBagages);

@override
String toString() {
  return 'VoyageCommercial(id: $id, codevoyage: $codevoyage, provenance: $provenance, destination: $destination, datedepartprevue: $datedepartprevue, demarre: $demarre, placestotal: $placestotal, placesoccupees: $placesoccupees, garecouranteId: $garecouranteId, garecouranteLibelle: $garecouranteLibelle, carId: $carId, carMatricule: $carMatricule, peutRepartir: $peutRepartir, arrets: $arrets, maRecette: $maRecette, mesTickets: $mesTickets, mesBagages: $mesBagages)';
}


}

/// @nodoc
abstract mixin class _$VoyageCommercialCopyWith<$Res> implements $VoyageCommercialCopyWith<$Res> {
  factory _$VoyageCommercialCopyWith(_VoyageCommercial value, $Res Function(_VoyageCommercial) _then) = __$VoyageCommercialCopyWithImpl;
@override @useResult
$Res call({
 int id, String? codevoyage, String? provenance, String? destination, DateTime? datedepartprevue, bool demarre, int placestotal, int placesoccupees, int? garecouranteId, String? garecouranteLibelle, int? carId, String? carMatricule, bool peutRepartir, List<Arret> arrets, int maRecette, int mesTickets, int mesBagages
});




}
/// @nodoc
class __$VoyageCommercialCopyWithImpl<$Res>
    implements _$VoyageCommercialCopyWith<$Res> {
  __$VoyageCommercialCopyWithImpl(this._self, this._then);

  final _VoyageCommercial _self;
  final $Res Function(_VoyageCommercial) _then;

/// Create a copy of VoyageCommercial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codevoyage = freezed,Object? provenance = freezed,Object? destination = freezed,Object? datedepartprevue = freezed,Object? demarre = null,Object? placestotal = null,Object? placesoccupees = null,Object? garecouranteId = freezed,Object? garecouranteLibelle = freezed,Object? carId = freezed,Object? carMatricule = freezed,Object? peutRepartir = null,Object? arrets = null,Object? maRecette = null,Object? mesTickets = null,Object? mesBagages = null,}) {
  return _then(_VoyageCommercial(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codevoyage: freezed == codevoyage ? _self.codevoyage : codevoyage // ignore: cast_nullable_to_non_nullable
as String?,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,datedepartprevue: freezed == datedepartprevue ? _self.datedepartprevue : datedepartprevue // ignore: cast_nullable_to_non_nullable
as DateTime?,demarre: null == demarre ? _self.demarre : demarre // ignore: cast_nullable_to_non_nullable
as bool,placestotal: null == placestotal ? _self.placestotal : placestotal // ignore: cast_nullable_to_non_nullable
as int,placesoccupees: null == placesoccupees ? _self.placesoccupees : placesoccupees // ignore: cast_nullable_to_non_nullable
as int,garecouranteId: freezed == garecouranteId ? _self.garecouranteId : garecouranteId // ignore: cast_nullable_to_non_nullable
as int?,garecouranteLibelle: freezed == garecouranteLibelle ? _self.garecouranteLibelle : garecouranteLibelle // ignore: cast_nullable_to_non_nullable
as String?,carId: freezed == carId ? _self.carId : carId // ignore: cast_nullable_to_non_nullable
as int?,carMatricule: freezed == carMatricule ? _self.carMatricule : carMatricule // ignore: cast_nullable_to_non_nullable
as String?,peutRepartir: null == peutRepartir ? _self.peutRepartir : peutRepartir // ignore: cast_nullable_to_non_nullable
as bool,arrets: null == arrets ? _self._arrets : arrets // ignore: cast_nullable_to_non_nullable
as List<Arret>,maRecette: null == maRecette ? _self.maRecette : maRecette // ignore: cast_nullable_to_non_nullable
as int,mesTickets: null == mesTickets ? _self.mesTickets : mesTickets // ignore: cast_nullable_to_non_nullable
as int,mesBagages: null == mesBagages ? _self.mesBagages : mesBagages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
