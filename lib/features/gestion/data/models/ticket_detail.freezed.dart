// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketDetail {

 int get id; String? get codeticket; int get prix; int get remise; String? get nomclient; String? get contactclient; String get statut; int? get siegeNumero; int? get monteeGareId; String? get monteeLibelle; int? get descenteGareId; String? get descenteLibelle; DateTime? get dateEmission;
/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketDetailCopyWith<TicketDetail> get copyWith => _$TicketDetailCopyWithImpl<TicketDetail>(this as TicketDetail, _$identity);

  /// Serializes this TicketDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.remise, remise) || other.remise == remise)&&(identical(other.nomclient, nomclient) || other.nomclient == nomclient)&&(identical(other.contactclient, contactclient) || other.contactclient == contactclient)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.siegeNumero, siegeNumero) || other.siegeNumero == siegeNumero)&&(identical(other.monteeGareId, monteeGareId) || other.monteeGareId == monteeGareId)&&(identical(other.monteeLibelle, monteeLibelle) || other.monteeLibelle == monteeLibelle)&&(identical(other.descenteGareId, descenteGareId) || other.descenteGareId == descenteGareId)&&(identical(other.descenteLibelle, descenteLibelle) || other.descenteLibelle == descenteLibelle)&&(identical(other.dateEmission, dateEmission) || other.dateEmission == dateEmission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codeticket,prix,remise,nomclient,contactclient,statut,siegeNumero,monteeGareId,monteeLibelle,descenteGareId,descenteLibelle,dateEmission);

@override
String toString() {
  return 'TicketDetail(id: $id, codeticket: $codeticket, prix: $prix, remise: $remise, nomclient: $nomclient, contactclient: $contactclient, statut: $statut, siegeNumero: $siegeNumero, monteeGareId: $monteeGareId, monteeLibelle: $monteeLibelle, descenteGareId: $descenteGareId, descenteLibelle: $descenteLibelle, dateEmission: $dateEmission)';
}


}

/// @nodoc
abstract mixin class $TicketDetailCopyWith<$Res>  {
  factory $TicketDetailCopyWith(TicketDetail value, $Res Function(TicketDetail) _then) = _$TicketDetailCopyWithImpl;
@useResult
$Res call({
 int id, String? codeticket, int prix, int remise, String? nomclient, String? contactclient, String statut, int? siegeNumero, int? monteeGareId, String? monteeLibelle, int? descenteGareId, String? descenteLibelle, DateTime? dateEmission
});




}
/// @nodoc
class _$TicketDetailCopyWithImpl<$Res>
    implements $TicketDetailCopyWith<$Res> {
  _$TicketDetailCopyWithImpl(this._self, this._then);

  final TicketDetail _self;
  final $Res Function(TicketDetail) _then;

/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codeticket = freezed,Object? prix = null,Object? remise = null,Object? nomclient = freezed,Object? contactclient = freezed,Object? statut = null,Object? siegeNumero = freezed,Object? monteeGareId = freezed,Object? monteeLibelle = freezed,Object? descenteGareId = freezed,Object? descenteLibelle = freezed,Object? dateEmission = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,prix: null == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as int,remise: null == remise ? _self.remise : remise // ignore: cast_nullable_to_non_nullable
as int,nomclient: freezed == nomclient ? _self.nomclient : nomclient // ignore: cast_nullable_to_non_nullable
as String?,contactclient: freezed == contactclient ? _self.contactclient : contactclient // ignore: cast_nullable_to_non_nullable
as String?,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,siegeNumero: freezed == siegeNumero ? _self.siegeNumero : siegeNumero // ignore: cast_nullable_to_non_nullable
as int?,monteeGareId: freezed == monteeGareId ? _self.monteeGareId : monteeGareId // ignore: cast_nullable_to_non_nullable
as int?,monteeLibelle: freezed == monteeLibelle ? _self.monteeLibelle : monteeLibelle // ignore: cast_nullable_to_non_nullable
as String?,descenteGareId: freezed == descenteGareId ? _self.descenteGareId : descenteGareId // ignore: cast_nullable_to_non_nullable
as int?,descenteLibelle: freezed == descenteLibelle ? _self.descenteLibelle : descenteLibelle // ignore: cast_nullable_to_non_nullable
as String?,dateEmission: freezed == dateEmission ? _self.dateEmission : dateEmission // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketDetail].
extension TicketDetailPatterns on TicketDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketDetail value)  $default,){
final _that = this;
switch (_that) {
case _TicketDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketDetail value)?  $default,){
final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? codeticket,  int prix,  int remise,  String? nomclient,  String? contactclient,  String statut,  int? siegeNumero,  int? monteeGareId,  String? monteeLibelle,  int? descenteGareId,  String? descenteLibelle,  DateTime? dateEmission)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
return $default(_that.id,_that.codeticket,_that.prix,_that.remise,_that.nomclient,_that.contactclient,_that.statut,_that.siegeNumero,_that.monteeGareId,_that.monteeLibelle,_that.descenteGareId,_that.descenteLibelle,_that.dateEmission);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? codeticket,  int prix,  int remise,  String? nomclient,  String? contactclient,  String statut,  int? siegeNumero,  int? monteeGareId,  String? monteeLibelle,  int? descenteGareId,  String? descenteLibelle,  DateTime? dateEmission)  $default,) {final _that = this;
switch (_that) {
case _TicketDetail():
return $default(_that.id,_that.codeticket,_that.prix,_that.remise,_that.nomclient,_that.contactclient,_that.statut,_that.siegeNumero,_that.monteeGareId,_that.monteeLibelle,_that.descenteGareId,_that.descenteLibelle,_that.dateEmission);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? codeticket,  int prix,  int remise,  String? nomclient,  String? contactclient,  String statut,  int? siegeNumero,  int? monteeGareId,  String? monteeLibelle,  int? descenteGareId,  String? descenteLibelle,  DateTime? dateEmission)?  $default,) {final _that = this;
switch (_that) {
case _TicketDetail() when $default != null:
return $default(_that.id,_that.codeticket,_that.prix,_that.remise,_that.nomclient,_that.contactclient,_that.statut,_that.siegeNumero,_that.monteeGareId,_that.monteeLibelle,_that.descenteGareId,_that.descenteLibelle,_that.dateEmission);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketDetail extends TicketDetail {
  const _TicketDetail({required this.id, this.codeticket, this.prix = 0, this.remise = 0, this.nomclient, this.contactclient, this.statut = 'VALIDE', this.siegeNumero, this.monteeGareId, this.monteeLibelle, this.descenteGareId, this.descenteLibelle, this.dateEmission}): super._();
  factory _TicketDetail.fromJson(Map<String, dynamic> json) => _$TicketDetailFromJson(json);

@override final  int id;
@override final  String? codeticket;
@override@JsonKey() final  int prix;
@override@JsonKey() final  int remise;
@override final  String? nomclient;
@override final  String? contactclient;
@override@JsonKey() final  String statut;
@override final  int? siegeNumero;
@override final  int? monteeGareId;
@override final  String? monteeLibelle;
@override final  int? descenteGareId;
@override final  String? descenteLibelle;
@override final  DateTime? dateEmission;

/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketDetailCopyWith<_TicketDetail> get copyWith => __$TicketDetailCopyWithImpl<_TicketDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.remise, remise) || other.remise == remise)&&(identical(other.nomclient, nomclient) || other.nomclient == nomclient)&&(identical(other.contactclient, contactclient) || other.contactclient == contactclient)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.siegeNumero, siegeNumero) || other.siegeNumero == siegeNumero)&&(identical(other.monteeGareId, monteeGareId) || other.monteeGareId == monteeGareId)&&(identical(other.monteeLibelle, monteeLibelle) || other.monteeLibelle == monteeLibelle)&&(identical(other.descenteGareId, descenteGareId) || other.descenteGareId == descenteGareId)&&(identical(other.descenteLibelle, descenteLibelle) || other.descenteLibelle == descenteLibelle)&&(identical(other.dateEmission, dateEmission) || other.dateEmission == dateEmission));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codeticket,prix,remise,nomclient,contactclient,statut,siegeNumero,monteeGareId,monteeLibelle,descenteGareId,descenteLibelle,dateEmission);

@override
String toString() {
  return 'TicketDetail(id: $id, codeticket: $codeticket, prix: $prix, remise: $remise, nomclient: $nomclient, contactclient: $contactclient, statut: $statut, siegeNumero: $siegeNumero, monteeGareId: $monteeGareId, monteeLibelle: $monteeLibelle, descenteGareId: $descenteGareId, descenteLibelle: $descenteLibelle, dateEmission: $dateEmission)';
}


}

/// @nodoc
abstract mixin class _$TicketDetailCopyWith<$Res> implements $TicketDetailCopyWith<$Res> {
  factory _$TicketDetailCopyWith(_TicketDetail value, $Res Function(_TicketDetail) _then) = __$TicketDetailCopyWithImpl;
@override @useResult
$Res call({
 int id, String? codeticket, int prix, int remise, String? nomclient, String? contactclient, String statut, int? siegeNumero, int? monteeGareId, String? monteeLibelle, int? descenteGareId, String? descenteLibelle, DateTime? dateEmission
});




}
/// @nodoc
class __$TicketDetailCopyWithImpl<$Res>
    implements _$TicketDetailCopyWith<$Res> {
  __$TicketDetailCopyWithImpl(this._self, this._then);

  final _TicketDetail _self;
  final $Res Function(_TicketDetail) _then;

/// Create a copy of TicketDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codeticket = freezed,Object? prix = null,Object? remise = null,Object? nomclient = freezed,Object? contactclient = freezed,Object? statut = null,Object? siegeNumero = freezed,Object? monteeGareId = freezed,Object? monteeLibelle = freezed,Object? descenteGareId = freezed,Object? descenteLibelle = freezed,Object? dateEmission = freezed,}) {
  return _then(_TicketDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,prix: null == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as int,remise: null == remise ? _self.remise : remise // ignore: cast_nullable_to_non_nullable
as int,nomclient: freezed == nomclient ? _self.nomclient : nomclient // ignore: cast_nullable_to_non_nullable
as String?,contactclient: freezed == contactclient ? _self.contactclient : contactclient // ignore: cast_nullable_to_non_nullable
as String?,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,siegeNumero: freezed == siegeNumero ? _self.siegeNumero : siegeNumero // ignore: cast_nullable_to_non_nullable
as int?,monteeGareId: freezed == monteeGareId ? _self.monteeGareId : monteeGareId // ignore: cast_nullable_to_non_nullable
as int?,monteeLibelle: freezed == monteeLibelle ? _self.monteeLibelle : monteeLibelle // ignore: cast_nullable_to_non_nullable
as String?,descenteGareId: freezed == descenteGareId ? _self.descenteGareId : descenteGareId // ignore: cast_nullable_to_non_nullable
as int?,descenteLibelle: freezed == descenteLibelle ? _self.descenteLibelle : descenteLibelle // ignore: cast_nullable_to_non_nullable
as String?,dateEmission: freezed == dateEmission ? _self.dateEmission : dateEmission // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
