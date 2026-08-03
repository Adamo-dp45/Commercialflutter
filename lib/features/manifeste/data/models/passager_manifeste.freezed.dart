// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'passager_manifeste.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PassagerManifeste {

 int? get ticketId; String? get codeticket; int? get siegeNumero; String? get nomclient; String? get contactclient; String? get monteeLibelle; String? get descenteLibelle; bool get aBord;
/// Create a copy of PassagerManifeste
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PassagerManifesteCopyWith<PassagerManifeste> get copyWith => _$PassagerManifesteCopyWithImpl<PassagerManifeste>(this as PassagerManifeste, _$identity);

  /// Serializes this PassagerManifeste to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PassagerManifeste&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.siegeNumero, siegeNumero) || other.siegeNumero == siegeNumero)&&(identical(other.nomclient, nomclient) || other.nomclient == nomclient)&&(identical(other.contactclient, contactclient) || other.contactclient == contactclient)&&(identical(other.monteeLibelle, monteeLibelle) || other.monteeLibelle == monteeLibelle)&&(identical(other.descenteLibelle, descenteLibelle) || other.descenteLibelle == descenteLibelle)&&(identical(other.aBord, aBord) || other.aBord == aBord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,codeticket,siegeNumero,nomclient,contactclient,monteeLibelle,descenteLibelle,aBord);

@override
String toString() {
  return 'PassagerManifeste(ticketId: $ticketId, codeticket: $codeticket, siegeNumero: $siegeNumero, nomclient: $nomclient, contactclient: $contactclient, monteeLibelle: $monteeLibelle, descenteLibelle: $descenteLibelle, aBord: $aBord)';
}


}

/// @nodoc
abstract mixin class $PassagerManifesteCopyWith<$Res>  {
  factory $PassagerManifesteCopyWith(PassagerManifeste value, $Res Function(PassagerManifeste) _then) = _$PassagerManifesteCopyWithImpl;
@useResult
$Res call({
 int? ticketId, String? codeticket, int? siegeNumero, String? nomclient, String? contactclient, String? monteeLibelle, String? descenteLibelle, bool aBord
});




}
/// @nodoc
class _$PassagerManifesteCopyWithImpl<$Res>
    implements $PassagerManifesteCopyWith<$Res> {
  _$PassagerManifesteCopyWithImpl(this._self, this._then);

  final PassagerManifeste _self;
  final $Res Function(PassagerManifeste) _then;

/// Create a copy of PassagerManifeste
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ticketId = freezed,Object? codeticket = freezed,Object? siegeNumero = freezed,Object? nomclient = freezed,Object? contactclient = freezed,Object? monteeLibelle = freezed,Object? descenteLibelle = freezed,Object? aBord = null,}) {
  return _then(_self.copyWith(
ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as int?,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,siegeNumero: freezed == siegeNumero ? _self.siegeNumero : siegeNumero // ignore: cast_nullable_to_non_nullable
as int?,nomclient: freezed == nomclient ? _self.nomclient : nomclient // ignore: cast_nullable_to_non_nullable
as String?,contactclient: freezed == contactclient ? _self.contactclient : contactclient // ignore: cast_nullable_to_non_nullable
as String?,monteeLibelle: freezed == monteeLibelle ? _self.monteeLibelle : monteeLibelle // ignore: cast_nullable_to_non_nullable
as String?,descenteLibelle: freezed == descenteLibelle ? _self.descenteLibelle : descenteLibelle // ignore: cast_nullable_to_non_nullable
as String?,aBord: null == aBord ? _self.aBord : aBord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PassagerManifeste].
extension PassagerManifestePatterns on PassagerManifeste {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PassagerManifeste value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PassagerManifeste() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PassagerManifeste value)  $default,){
final _that = this;
switch (_that) {
case _PassagerManifeste():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PassagerManifeste value)?  $default,){
final _that = this;
switch (_that) {
case _PassagerManifeste() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? ticketId,  String? codeticket,  int? siegeNumero,  String? nomclient,  String? contactclient,  String? monteeLibelle,  String? descenteLibelle,  bool aBord)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PassagerManifeste() when $default != null:
return $default(_that.ticketId,_that.codeticket,_that.siegeNumero,_that.nomclient,_that.contactclient,_that.monteeLibelle,_that.descenteLibelle,_that.aBord);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? ticketId,  String? codeticket,  int? siegeNumero,  String? nomclient,  String? contactclient,  String? monteeLibelle,  String? descenteLibelle,  bool aBord)  $default,) {final _that = this;
switch (_that) {
case _PassagerManifeste():
return $default(_that.ticketId,_that.codeticket,_that.siegeNumero,_that.nomclient,_that.contactclient,_that.monteeLibelle,_that.descenteLibelle,_that.aBord);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? ticketId,  String? codeticket,  int? siegeNumero,  String? nomclient,  String? contactclient,  String? monteeLibelle,  String? descenteLibelle,  bool aBord)?  $default,) {final _that = this;
switch (_that) {
case _PassagerManifeste() when $default != null:
return $default(_that.ticketId,_that.codeticket,_that.siegeNumero,_that.nomclient,_that.contactclient,_that.monteeLibelle,_that.descenteLibelle,_that.aBord);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PassagerManifeste extends PassagerManifeste {
  const _PassagerManifeste({this.ticketId, this.codeticket, this.siegeNumero, this.nomclient, this.contactclient, this.monteeLibelle, this.descenteLibelle, this.aBord = false}): super._();
  factory _PassagerManifeste.fromJson(Map<String, dynamic> json) => _$PassagerManifesteFromJson(json);

@override final  int? ticketId;
@override final  String? codeticket;
@override final  int? siegeNumero;
@override final  String? nomclient;
@override final  String? contactclient;
@override final  String? monteeLibelle;
@override final  String? descenteLibelle;
@override@JsonKey() final  bool aBord;

/// Create a copy of PassagerManifeste
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PassagerManifesteCopyWith<_PassagerManifeste> get copyWith => __$PassagerManifesteCopyWithImpl<_PassagerManifeste>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PassagerManifesteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PassagerManifeste&&(identical(other.ticketId, ticketId) || other.ticketId == ticketId)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.siegeNumero, siegeNumero) || other.siegeNumero == siegeNumero)&&(identical(other.nomclient, nomclient) || other.nomclient == nomclient)&&(identical(other.contactclient, contactclient) || other.contactclient == contactclient)&&(identical(other.monteeLibelle, monteeLibelle) || other.monteeLibelle == monteeLibelle)&&(identical(other.descenteLibelle, descenteLibelle) || other.descenteLibelle == descenteLibelle)&&(identical(other.aBord, aBord) || other.aBord == aBord));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,ticketId,codeticket,siegeNumero,nomclient,contactclient,monteeLibelle,descenteLibelle,aBord);

@override
String toString() {
  return 'PassagerManifeste(ticketId: $ticketId, codeticket: $codeticket, siegeNumero: $siegeNumero, nomclient: $nomclient, contactclient: $contactclient, monteeLibelle: $monteeLibelle, descenteLibelle: $descenteLibelle, aBord: $aBord)';
}


}

/// @nodoc
abstract mixin class _$PassagerManifesteCopyWith<$Res> implements $PassagerManifesteCopyWith<$Res> {
  factory _$PassagerManifesteCopyWith(_PassagerManifeste value, $Res Function(_PassagerManifeste) _then) = __$PassagerManifesteCopyWithImpl;
@override @useResult
$Res call({
 int? ticketId, String? codeticket, int? siegeNumero, String? nomclient, String? contactclient, String? monteeLibelle, String? descenteLibelle, bool aBord
});




}
/// @nodoc
class __$PassagerManifesteCopyWithImpl<$Res>
    implements _$PassagerManifesteCopyWith<$Res> {
  __$PassagerManifesteCopyWithImpl(this._self, this._then);

  final _PassagerManifeste _self;
  final $Res Function(_PassagerManifeste) _then;

/// Create a copy of PassagerManifeste
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ticketId = freezed,Object? codeticket = freezed,Object? siegeNumero = freezed,Object? nomclient = freezed,Object? contactclient = freezed,Object? monteeLibelle = freezed,Object? descenteLibelle = freezed,Object? aBord = null,}) {
  return _then(_PassagerManifeste(
ticketId: freezed == ticketId ? _self.ticketId : ticketId // ignore: cast_nullable_to_non_nullable
as int?,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,siegeNumero: freezed == siegeNumero ? _self.siegeNumero : siegeNumero // ignore: cast_nullable_to_non_nullable
as int?,nomclient: freezed == nomclient ? _self.nomclient : nomclient // ignore: cast_nullable_to_non_nullable
as String?,contactclient: freezed == contactclient ? _self.contactclient : contactclient // ignore: cast_nullable_to_non_nullable
as String?,monteeLibelle: freezed == monteeLibelle ? _self.monteeLibelle : monteeLibelle // ignore: cast_nullable_to_non_nullable
as String?,descenteLibelle: freezed == descenteLibelle ? _self.descenteLibelle : descenteLibelle // ignore: cast_nullable_to_non_nullable
as String?,aBord: null == aBord ? _self.aBord : aBord // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
