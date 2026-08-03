// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entreprise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entreprise {

 String? get libelle; String? get sigle; String? get contact1; String? get contact2;
/// Create a copy of Entreprise
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntrepriseCopyWith<Entreprise> get copyWith => _$EntrepriseCopyWithImpl<Entreprise>(this as Entreprise, _$identity);

  /// Serializes this Entreprise to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entreprise&&(identical(other.libelle, libelle) || other.libelle == libelle)&&(identical(other.sigle, sigle) || other.sigle == sigle)&&(identical(other.contact1, contact1) || other.contact1 == contact1)&&(identical(other.contact2, contact2) || other.contact2 == contact2));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,libelle,sigle,contact1,contact2);

@override
String toString() {
  return 'Entreprise(libelle: $libelle, sigle: $sigle, contact1: $contact1, contact2: $contact2)';
}


}

/// @nodoc
abstract mixin class $EntrepriseCopyWith<$Res>  {
  factory $EntrepriseCopyWith(Entreprise value, $Res Function(Entreprise) _then) = _$EntrepriseCopyWithImpl;
@useResult
$Res call({
 String? libelle, String? sigle, String? contact1, String? contact2
});




}
/// @nodoc
class _$EntrepriseCopyWithImpl<$Res>
    implements $EntrepriseCopyWith<$Res> {
  _$EntrepriseCopyWithImpl(this._self, this._then);

  final Entreprise _self;
  final $Res Function(Entreprise) _then;

/// Create a copy of Entreprise
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? libelle = freezed,Object? sigle = freezed,Object? contact1 = freezed,Object? contact2 = freezed,}) {
  return _then(_self.copyWith(
libelle: freezed == libelle ? _self.libelle : libelle // ignore: cast_nullable_to_non_nullable
as String?,sigle: freezed == sigle ? _self.sigle : sigle // ignore: cast_nullable_to_non_nullable
as String?,contact1: freezed == contact1 ? _self.contact1 : contact1 // ignore: cast_nullable_to_non_nullable
as String?,contact2: freezed == contact2 ? _self.contact2 : contact2 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Entreprise].
extension EntreprisePatterns on Entreprise {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entreprise value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entreprise() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entreprise value)  $default,){
final _that = this;
switch (_that) {
case _Entreprise():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entreprise value)?  $default,){
final _that = this;
switch (_that) {
case _Entreprise() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? libelle,  String? sigle,  String? contact1,  String? contact2)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entreprise() when $default != null:
return $default(_that.libelle,_that.sigle,_that.contact1,_that.contact2);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? libelle,  String? sigle,  String? contact1,  String? contact2)  $default,) {final _that = this;
switch (_that) {
case _Entreprise():
return $default(_that.libelle,_that.sigle,_that.contact1,_that.contact2);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? libelle,  String? sigle,  String? contact1,  String? contact2)?  $default,) {final _that = this;
switch (_that) {
case _Entreprise() when $default != null:
return $default(_that.libelle,_that.sigle,_that.contact1,_that.contact2);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entreprise extends Entreprise {
  const _Entreprise({this.libelle, this.sigle, this.contact1, this.contact2}): super._();
  factory _Entreprise.fromJson(Map<String, dynamic> json) => _$EntrepriseFromJson(json);

@override final  String? libelle;
@override final  String? sigle;
@override final  String? contact1;
@override final  String? contact2;

/// Create a copy of Entreprise
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntrepriseCopyWith<_Entreprise> get copyWith => __$EntrepriseCopyWithImpl<_Entreprise>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntrepriseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entreprise&&(identical(other.libelle, libelle) || other.libelle == libelle)&&(identical(other.sigle, sigle) || other.sigle == sigle)&&(identical(other.contact1, contact1) || other.contact1 == contact1)&&(identical(other.contact2, contact2) || other.contact2 == contact2));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,libelle,sigle,contact1,contact2);

@override
String toString() {
  return 'Entreprise(libelle: $libelle, sigle: $sigle, contact1: $contact1, contact2: $contact2)';
}


}

/// @nodoc
abstract mixin class _$EntrepriseCopyWith<$Res> implements $EntrepriseCopyWith<$Res> {
  factory _$EntrepriseCopyWith(_Entreprise value, $Res Function(_Entreprise) _then) = __$EntrepriseCopyWithImpl;
@override @useResult
$Res call({
 String? libelle, String? sigle, String? contact1, String? contact2
});




}
/// @nodoc
class __$EntrepriseCopyWithImpl<$Res>
    implements _$EntrepriseCopyWith<$Res> {
  __$EntrepriseCopyWithImpl(this._self, this._then);

  final _Entreprise _self;
  final $Res Function(_Entreprise) _then;

/// Create a copy of Entreprise
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? libelle = freezed,Object? sigle = freezed,Object? contact1 = freezed,Object? contact2 = freezed,}) {
  return _then(_Entreprise(
libelle: freezed == libelle ? _self.libelle : libelle // ignore: cast_nullable_to_non_nullable
as String?,sigle: freezed == sigle ? _self.sigle : sigle // ignore: cast_nullable_to_non_nullable
as String?,contact1: freezed == contact1 ? _self.contact1 : contact1 // ignore: cast_nullable_to_non_nullable
as String?,contact2: freezed == contact2 ? _self.contact2 : contact2 // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
