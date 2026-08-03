// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bagage_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BagageDetail {

 int get id; String? get codebagage; String? get nature; String? get type; int get poids; int get montant;@JsonKey(name: 'montantforce') bool get montantForce; String get statut; int? get ticketId; String? get codeticket; String? get nomclient; String? get contactclient; String? get monteeLibelle; String? get descenteLibelle;
/// Create a copy of BagageDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BagageDetailCopyWith<BagageDetail> get copyWith => _$BagageDetailCopyWithImpl<BagageDetail>(this as BagageDetail, _$identity);

  /// Serializes this BagageDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BagageDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.codebagage, codebagage) || other.codebagage == codebagage)&&(identical(other.nature, nature) || other.nature == nature)&&(identical(other.type, type) || other.type == type)&&(identical(other.poids, poids) || other.poids == poids)&&(identical(other.montant, montant) || other.montant == montant)&&(identical(other.montantForce, montantForce) || other.montantForce == montantForce)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.nomclient, nomclient) || other.nomclient == nomclient)&&(identical(other.contactclient, contactclient) || other.contactclient == contactclient)&&(identical(other.monteeLibelle, monteeLibelle) || other.monteeLibelle == monteeLibelle)&&(identical(other.descenteLibelle, descenteLibelle) || other.descenteLibelle == descenteLibelle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codebagage,nature,type,poids,montant,montantForce,statut,ticketId,codeticket,nomclient,contactclient,monteeLibelle,descenteLibelle);

@override
String toString() {
  return 'BagageDetail(id: $id, codebagage: $codebagage, nature: $nature, type: $type, poids: $poids, montant: $montant, montantForce: $montantForce, statut: $statut, ticketId: $ticketId, codeticket: $codeticket, nomclient: $nomclient, contactclient: $contactclient, monteeLibelle: $monteeLibelle, descenteLibelle: $descenteLibelle)';
}


}

/// @nodoc
abstract mixin class $BagageDetailCopyWith<$Res>  {
  factory $BagageDetailCopyWith(BagageDetail value, $Res Function(BagageDetail) _then) = _$BagageDetailCopyWithImpl;
@useResult
$Res call({
 int id, String? codebagage, String? nature, String? type, int poids, int montant,@JsonKey(name: 'montantforce') bool montantForce, String statut, int? ticketId, String? codeticket, String? nomclient, String? contactclient, String? monteeLibelle, String? descenteLibelle
});




}
/// @nodoc
class _$BagageDetailCopyWithImpl<$Res>
    implements $BagageDetailCopyWith<$Res> {
  _$BagageDetailCopyWithImpl(this._self, this._then);

  final BagageDetail _self;
  final $Res Function(BagageDetail) _then;

/// Create a copy of BagageDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codebagage = freezed,Object? nature = freezed,Object? type = freezed,Object? poids = null,Object? montant = null,Object? montantForce = null,Object? statut = null,Object? ticketId = freezed,Object? codeticket = freezed,Object? nomclient = freezed,Object? contactclient = freezed,Object? monteeLibelle = freezed,Object? descenteLibelle = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codebagage: freezed == codebagage ? _self.codebagage : codebagage // ignore: cast_nullable_to_non_nullable
as String?,nature: freezed == nature ? _self.nature : nature // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,poids: null == poids ? _self.poids : poids // ignore: cast_nullable_to_non_nullable
as int,montant: null == montant ? _self.montant : montant // ignore: cast_nullable_to_non_nullable
as int,montantForce: null == montantForce ? _self.montantForce : montantForce // ignore: cast_nullable_to_non_nullable
as bool,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as int?,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,nomclient: freezed == nomclient ? _self.nomclient : nomclient // ignore: cast_nullable_to_non_nullable
as String?,contactclient: freezed == contactclient ? _self.contactclient : contactclient // ignore: cast_nullable_to_non_nullable
as String?,monteeLibelle: freezed == monteeLibelle ? _self.monteeLibelle : monteeLibelle // ignore: cast_nullable_to_non_nullable
as String?,descenteLibelle: freezed == descenteLibelle ? _self.descenteLibelle : descenteLibelle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BagageDetail].
extension BagageDetailPatterns on BagageDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BagageDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BagageDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BagageDetail value)  $default,){
final _that = this;
switch (_that) {
case _BagageDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BagageDetail value)?  $default,){
final _that = this;
switch (_that) {
case _BagageDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? codebagage,  String? nature,  String? type,  int poids,  int montant, @JsonKey(name: 'montantforce')  bool montantForce,  String statut,  int? ticketId,  String? codeticket,  String? nomclient,  String? contactclient,  String? monteeLibelle,  String? descenteLibelle)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BagageDetail() when $default != null:
return $default(_that.id,_that.codebagage,_that.nature,_that.type,_that.poids,_that.montant,_that.montantForce,_that.statut,_that.ticketId,_that.codeticket,_that.nomclient,_that.contactclient,_that.monteeLibelle,_that.descenteLibelle);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? codebagage,  String? nature,  String? type,  int poids,  int montant, @JsonKey(name: 'montantforce')  bool montantForce,  String statut,  int? ticketId,  String? codeticket,  String? nomclient,  String? contactclient,  String? monteeLibelle,  String? descenteLibelle)  $default,) {final _that = this;
switch (_that) {
case _BagageDetail():
return $default(_that.id,_that.codebagage,_that.nature,_that.type,_that.poids,_that.montant,_that.montantForce,_that.statut,_that.ticketId,_that.codeticket,_that.nomclient,_that.contactclient,_that.monteeLibelle,_that.descenteLibelle);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? codebagage,  String? nature,  String? type,  int poids,  int montant, @JsonKey(name: 'montantforce')  bool montantForce,  String statut,  int? ticketId,  String? codeticket,  String? nomclient,  String? contactclient,  String? monteeLibelle,  String? descenteLibelle)?  $default,) {final _that = this;
switch (_that) {
case _BagageDetail() when $default != null:
return $default(_that.id,_that.codebagage,_that.nature,_that.type,_that.poids,_that.montant,_that.montantForce,_that.statut,_that.ticketId,_that.codeticket,_that.nomclient,_that.contactclient,_that.monteeLibelle,_that.descenteLibelle);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BagageDetail extends BagageDetail {
  const _BagageDetail({required this.id, this.codebagage, this.nature, this.type, this.poids = 0, this.montant = 0, @JsonKey(name: 'montantforce') this.montantForce = false, this.statut = 'ENREGISTRE', this.ticketId, this.codeticket, this.nomclient, this.contactclient, this.monteeLibelle, this.descenteLibelle}): super._();
  factory _BagageDetail.fromJson(Map<String, dynamic> json) => _$BagageDetailFromJson(json);

@override final  int id;
@override final  String? codebagage;
@override final  String? nature;
@override final  String? type;
@override@JsonKey() final  int poids;
@override@JsonKey() final  int montant;
@override@JsonKey(name: 'montantforce') final  bool montantForce;
@override@JsonKey() final  String statut;
@override final  int? ticketId;
@override final  String? codeticket;
@override final  String? nomclient;
@override final  String? contactclient;
@override final  String? monteeLibelle;
@override final  String? descenteLibelle;

/// Create a copy of BagageDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BagageDetailCopyWith<_BagageDetail> get copyWith => __$BagageDetailCopyWithImpl<_BagageDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BagageDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BagageDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.codebagage, codebagage) || other.codebagage == codebagage)&&(identical(other.nature, nature) || other.nature == nature)&&(identical(other.type, type) || other.type == type)&&(identical(other.poids, poids) || other.poids == poids)&&(identical(other.montant, montant) || other.montant == montant)&&(identical(other.montantForce, montantForce) || other.montantForce == montantForce)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.nomclient, nomclient) || other.nomclient == nomclient)&&(identical(other.contactclient, contactclient) || other.contactclient == contactclient)&&(identical(other.monteeLibelle, monteeLibelle) || other.monteeLibelle == monteeLibelle)&&(identical(other.descenteLibelle, descenteLibelle) || other.descenteLibelle == descenteLibelle));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codebagage,nature,type,poids,montant,montantForce,statut,ticketId,codeticket,nomclient,contactclient,monteeLibelle,descenteLibelle);

@override
String toString() {
  return 'BagageDetail(id: $id, codebagage: $codebagage, nature: $nature, type: $type, poids: $poids, montant: $montant, montantForce: $montantForce, statut: $statut, ticketId: $ticketId, codeticket: $codeticket, nomclient: $nomclient, contactclient: $contactclient, monteeLibelle: $monteeLibelle, descenteLibelle: $descenteLibelle)';
}


}

/// @nodoc
abstract mixin class _$BagageDetailCopyWith<$Res> implements $BagageDetailCopyWith<$Res> {
  factory _$BagageDetailCopyWith(_BagageDetail value, $Res Function(_BagageDetail) _then) = __$BagageDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, String? codebagage, String? nature, String? type, int poids, int montant,@JsonKey(name: 'montantforce') bool montantForce, String statut, int? ticketId, String? codeticket, String? nomclient, String? contactclient, String? monteeLibelle, String? descenteLibelle
});




}
/// @nodoc
class __$BagageDetailCopyWithImpl<$Res>
    implements _$BagageDetailCopyWith<$Res> {
  __$BagageDetailCopyWithImpl(this._self, this._then);

  final _BagageDetail _self;
  final $Res Function(_BagageDetail) _then;

/// Create a copy of BagageDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codebagage = freezed,Object? nature = freezed,Object? type = freezed,Object? poids = null,Object? montant = null,Object? montantForce = null,Object? statut = null,Object? ticketId = freezed,Object? codeticket = freezed,Object? nomclient = freezed,Object? contactclient = freezed,Object? monteeLibelle = freezed,Object? descenteLibelle = freezed,}) {
  return _then(_BagageDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codebagage: freezed == codebagage ? _self.codebagage : codebagage // ignore: cast_nullable_to_non_nullable
as String?,nature: freezed == nature ? _self.nature : nature // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,poids: null == poids ? _self.poids : poids // ignore: cast_nullable_to_non_nullable
as int,montant: null == montant ? _self.montant : montant // ignore: cast_nullable_to_non_nullable
as int,montantForce: null == montantForce ? _self.montantForce : montantForce // ignore: cast_nullable_to_non_nullable
as bool,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as int?,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,nomclient: freezed == nomclient ? _self.nomclient : nomclient // ignore: cast_nullable_to_non_nullable
as String?,contactclient: freezed == contactclient ? _self.contactclient : contactclient // ignore: cast_nullable_to_non_nullable
as String?,monteeLibelle: freezed == monteeLibelle ? _self.monteeLibelle : monteeLibelle // ignore: cast_nullable_to_non_nullable
as String?,descenteLibelle: freezed == descenteLibelle ? _self.descenteLibelle : descenteLibelle // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
