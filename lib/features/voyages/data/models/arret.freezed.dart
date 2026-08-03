// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'arret.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Arret {

 int get id; String get libelle; int get ordre;
/// Create a copy of Arret
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArretCopyWith<Arret> get copyWith => _$ArretCopyWithImpl<Arret>(this as Arret, _$identity);

  /// Serializes this Arret to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Arret&&(identical(other.id, id) || other.id == id)&&(identical(other.libelle, libelle) || other.libelle == libelle)&&(identical(other.ordre, ordre) || other.ordre == ordre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,libelle,ordre);

@override
String toString() {
  return 'Arret(id: $id, libelle: $libelle, ordre: $ordre)';
}


}

/// @nodoc
abstract mixin class $ArretCopyWith<$Res>  {
  factory $ArretCopyWith(Arret value, $Res Function(Arret) _then) = _$ArretCopyWithImpl;
@useResult
$Res call({
 int id, String libelle, int ordre
});




}
/// @nodoc
class _$ArretCopyWithImpl<$Res>
    implements $ArretCopyWith<$Res> {
  _$ArretCopyWithImpl(this._self, this._then);

  final Arret _self;
  final $Res Function(Arret) _then;

/// Create a copy of Arret
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? libelle = null,Object? ordre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,libelle: null == libelle ? _self.libelle : libelle // ignore: cast_nullable_to_non_nullable
as String,ordre: null == ordre ? _self.ordre : ordre // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Arret].
extension ArretPatterns on Arret {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Arret value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Arret() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Arret value)  $default,){
final _that = this;
switch (_that) {
case _Arret():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Arret value)?  $default,){
final _that = this;
switch (_that) {
case _Arret() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String libelle,  int ordre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Arret() when $default != null:
return $default(_that.id,_that.libelle,_that.ordre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String libelle,  int ordre)  $default,) {final _that = this;
switch (_that) {
case _Arret():
return $default(_that.id,_that.libelle,_that.ordre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String libelle,  int ordre)?  $default,) {final _that = this;
switch (_that) {
case _Arret() when $default != null:
return $default(_that.id,_that.libelle,_that.ordre);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Arret implements Arret {
  const _Arret({required this.id, required this.libelle, required this.ordre});
  factory _Arret.fromJson(Map<String, dynamic> json) => _$ArretFromJson(json);

@override final  int id;
@override final  String libelle;
@override final  int ordre;

/// Create a copy of Arret
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArretCopyWith<_Arret> get copyWith => __$ArretCopyWithImpl<_Arret>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ArretToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Arret&&(identical(other.id, id) || other.id == id)&&(identical(other.libelle, libelle) || other.libelle == libelle)&&(identical(other.ordre, ordre) || other.ordre == ordre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,libelle,ordre);

@override
String toString() {
  return 'Arret(id: $id, libelle: $libelle, ordre: $ordre)';
}


}

/// @nodoc
abstract mixin class _$ArretCopyWith<$Res> implements $ArretCopyWith<$Res> {
  factory _$ArretCopyWith(_Arret value, $Res Function(_Arret) _then) = __$ArretCopyWithImpl;
@override @useResult
$Res call({
 int id, String libelle, int ordre
});




}
/// @nodoc
class __$ArretCopyWithImpl<$Res>
    implements _$ArretCopyWith<$Res> {
  __$ArretCopyWithImpl(this._self, this._then);

  final _Arret _self;
  final $Res Function(_Arret) _then;

/// Create a copy of Arret
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? libelle = null,Object? ordre = null,}) {
  return _then(_Arret(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,libelle: null == libelle ? _self.libelle : libelle // ignore: cast_nullable_to_non_nullable
as String,ordre: null == ordre ? _self.ordre : ordre // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
