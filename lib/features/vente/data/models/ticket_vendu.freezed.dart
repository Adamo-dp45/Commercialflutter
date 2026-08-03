// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ticket_vendu.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TicketVendu {

 int? get id; String? get codeticket; int? get prix; int get remise;
/// Create a copy of TicketVendu
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TicketVenduCopyWith<TicketVendu> get copyWith => _$TicketVenduCopyWithImpl<TicketVendu>(this as TicketVendu, _$identity);

  /// Serializes this TicketVendu to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TicketVendu&&(identical(other.id, id) || other.id == id)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.remise, remise) || other.remise == remise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codeticket,prix,remise);

@override
String toString() {
  return 'TicketVendu(id: $id, codeticket: $codeticket, prix: $prix, remise: $remise)';
}


}

/// @nodoc
abstract mixin class $TicketVenduCopyWith<$Res>  {
  factory $TicketVenduCopyWith(TicketVendu value, $Res Function(TicketVendu) _then) = _$TicketVenduCopyWithImpl;
@useResult
$Res call({
 int? id, String? codeticket, int? prix, int remise
});




}
/// @nodoc
class _$TicketVenduCopyWithImpl<$Res>
    implements $TicketVenduCopyWith<$Res> {
  _$TicketVenduCopyWithImpl(this._self, this._then);

  final TicketVendu _self;
  final $Res Function(TicketVendu) _then;

/// Create a copy of TicketVendu
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? codeticket = freezed,Object? prix = freezed,Object? remise = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,prix: freezed == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as int?,remise: null == remise ? _self.remise : remise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TicketVendu].
extension TicketVenduPatterns on TicketVendu {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TicketVendu value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TicketVendu() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TicketVendu value)  $default,){
final _that = this;
switch (_that) {
case _TicketVendu():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TicketVendu value)?  $default,){
final _that = this;
switch (_that) {
case _TicketVendu() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? codeticket,  int? prix,  int remise)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TicketVendu() when $default != null:
return $default(_that.id,_that.codeticket,_that.prix,_that.remise);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? codeticket,  int? prix,  int remise)  $default,) {final _that = this;
switch (_that) {
case _TicketVendu():
return $default(_that.id,_that.codeticket,_that.prix,_that.remise);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? codeticket,  int? prix,  int remise)?  $default,) {final _that = this;
switch (_that) {
case _TicketVendu() when $default != null:
return $default(_that.id,_that.codeticket,_that.prix,_that.remise);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TicketVendu implements TicketVendu {
  const _TicketVendu({this.id, this.codeticket, this.prix, this.remise = 0});
  factory _TicketVendu.fromJson(Map<String, dynamic> json) => _$TicketVenduFromJson(json);

@override final  int? id;
@override final  String? codeticket;
@override final  int? prix;
@override@JsonKey() final  int remise;

/// Create a copy of TicketVendu
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TicketVenduCopyWith<_TicketVendu> get copyWith => __$TicketVenduCopyWithImpl<_TicketVendu>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TicketVenduToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TicketVendu&&(identical(other.id, id) || other.id == id)&&(identical(other.codeticket, codeticket) || other.codeticket == codeticket)&&(identical(other.prix, prix) || other.prix == prix)&&(identical(other.remise, remise) || other.remise == remise));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codeticket,prix,remise);

@override
String toString() {
  return 'TicketVendu(id: $id, codeticket: $codeticket, prix: $prix, remise: $remise)';
}


}

/// @nodoc
abstract mixin class _$TicketVenduCopyWith<$Res> implements $TicketVenduCopyWith<$Res> {
  factory _$TicketVenduCopyWith(_TicketVendu value, $Res Function(_TicketVendu) _then) = __$TicketVenduCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? codeticket, int? prix, int remise
});




}
/// @nodoc
class __$TicketVenduCopyWithImpl<$Res>
    implements _$TicketVenduCopyWith<$Res> {
  __$TicketVenduCopyWithImpl(this._self, this._then);

  final _TicketVendu _self;
  final $Res Function(_TicketVendu) _then;

/// Create a copy of TicketVendu
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? codeticket = freezed,Object? prix = freezed,Object? remise = null,}) {
  return _then(_TicketVendu(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,codeticket: freezed == codeticket ? _self.codeticket : codeticket // ignore: cast_nullable_to_non_nullable
as String?,prix: freezed == prix ? _self.prix : prix // ignore: cast_nullable_to_non_nullable
as int?,remise: null == remise ? _self.remise : remise // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
