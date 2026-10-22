// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AuthUser {

 int? get id; String? get email; String? get nom; String? get prenom; List<String> get roles; int? get entrepriseid; String? get fileUrl;@JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false) DroitsEffectifs get droits;
/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthUserCopyWith<AuthUser> get copyWith => _$AuthUserCopyWithImpl<AuthUser>(this as AuthUser, _$identity);

  /// Serializes this AuthUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.prenom, prenom) || other.prenom == prenom)&&const DeepCollectionEquality().equals(other.roles, roles)&&(identical(other.entrepriseid, entrepriseid) || other.entrepriseid == entrepriseid)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.droits, droits) || other.droits == droits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,nom,prenom,const DeepCollectionEquality().hash(roles),entrepriseid,fileUrl,droits);

@override
String toString() {
  return 'AuthUser(id: $id, email: $email, nom: $nom, prenom: $prenom, roles: $roles, entrepriseid: $entrepriseid, fileUrl: $fileUrl, droits: $droits)';
}


}

/// @nodoc
abstract mixin class $AuthUserCopyWith<$Res>  {
  factory $AuthUserCopyWith(AuthUser value, $Res Function(AuthUser) _then) = _$AuthUserCopyWithImpl;
@useResult
$Res call({
 int? id, String? email, String? nom, String? prenom, List<String> roles, int? entrepriseid, String? fileUrl,@JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false) DroitsEffectifs droits
});




}
/// @nodoc
class _$AuthUserCopyWithImpl<$Res>
    implements $AuthUserCopyWith<$Res> {
  _$AuthUserCopyWithImpl(this._self, this._then);

  final AuthUser _self;
  final $Res Function(AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? email = freezed,Object? nom = freezed,Object? prenom = freezed,Object? roles = null,Object? entrepriseid = freezed,Object? fileUrl = freezed,Object? droits = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,nom: freezed == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String?,prenom: freezed == prenom ? _self.prenom : prenom // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self.roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,entrepriseid: freezed == entrepriseid ? _self.entrepriseid : entrepriseid // ignore: cast_nullable_to_non_nullable
as int?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,droits: null == droits ? _self.droits : droits // ignore: cast_nullable_to_non_nullable
as DroitsEffectifs,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthUser].
extension AuthUserPatterns on AuthUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthUser value)  $default,){
final _that = this;
switch (_that) {
case _AuthUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthUser value)?  $default,){
final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? email,  String? nom,  String? prenom,  List<String> roles,  int? entrepriseid,  String? fileUrl, @JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false)  DroitsEffectifs droits)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.id,_that.email,_that.nom,_that.prenom,_that.roles,_that.entrepriseid,_that.fileUrl,_that.droits);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? email,  String? nom,  String? prenom,  List<String> roles,  int? entrepriseid,  String? fileUrl, @JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false)  DroitsEffectifs droits)  $default,) {final _that = this;
switch (_that) {
case _AuthUser():
return $default(_that.id,_that.email,_that.nom,_that.prenom,_that.roles,_that.entrepriseid,_that.fileUrl,_that.droits);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? email,  String? nom,  String? prenom,  List<String> roles,  int? entrepriseid,  String? fileUrl, @JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false)  DroitsEffectifs droits)?  $default,) {final _that = this;
switch (_that) {
case _AuthUser() when $default != null:
return $default(_that.id,_that.email,_that.nom,_that.prenom,_that.roles,_that.entrepriseid,_that.fileUrl,_that.droits);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AuthUser extends AuthUser {
  const _AuthUser({this.id, this.email, this.nom, this.prenom, final  List<String> roles = const <String>[], this.entrepriseid, this.fileUrl, @JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false) this.droits = DroitsEffectifs.aucun}): _roles = roles,super._();
  factory _AuthUser.fromJson(Map<String, dynamic> json) => _$AuthUserFromJson(json);

@override final  int? id;
@override final  String? email;
@override final  String? nom;
@override final  String? prenom;
 final  List<String> _roles;
@override@JsonKey() List<String> get roles {
  if (_roles is EqualUnmodifiableListView) return _roles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_roles);
}

@override final  int? entrepriseid;
@override final  String? fileUrl;
@override@JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false) final  DroitsEffectifs droits;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthUserCopyWith<_AuthUser> get copyWith => __$AuthUserCopyWithImpl<_AuthUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AuthUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.prenom, prenom) || other.prenom == prenom)&&const DeepCollectionEquality().equals(other._roles, _roles)&&(identical(other.entrepriseid, entrepriseid) || other.entrepriseid == entrepriseid)&&(identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl)&&(identical(other.droits, droits) || other.droits == droits));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,nom,prenom,const DeepCollectionEquality().hash(_roles),entrepriseid,fileUrl,droits);

@override
String toString() {
  return 'AuthUser(id: $id, email: $email, nom: $nom, prenom: $prenom, roles: $roles, entrepriseid: $entrepriseid, fileUrl: $fileUrl, droits: $droits)';
}


}

/// @nodoc
abstract mixin class _$AuthUserCopyWith<$Res> implements $AuthUserCopyWith<$Res> {
  factory _$AuthUserCopyWith(_AuthUser value, $Res Function(_AuthUser) _then) = __$AuthUserCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? email, String? nom, String? prenom, List<String> roles, int? entrepriseid, String? fileUrl,@JsonKey(name: 'permissions', fromJson: DroitsEffectifs.depuisJson, includeToJson: false) DroitsEffectifs droits
});




}
/// @nodoc
class __$AuthUserCopyWithImpl<$Res>
    implements _$AuthUserCopyWith<$Res> {
  __$AuthUserCopyWithImpl(this._self, this._then);

  final _AuthUser _self;
  final $Res Function(_AuthUser) _then;

/// Create a copy of AuthUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? email = freezed,Object? nom = freezed,Object? prenom = freezed,Object? roles = null,Object? entrepriseid = freezed,Object? fileUrl = freezed,Object? droits = null,}) {
  return _then(_AuthUser(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,nom: freezed == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String?,prenom: freezed == prenom ? _self.prenom : prenom // ignore: cast_nullable_to_non_nullable
as String?,roles: null == roles ? _self._roles : roles // ignore: cast_nullable_to_non_nullable
as List<String>,entrepriseid: freezed == entrepriseid ? _self.entrepriseid : entrepriseid // ignore: cast_nullable_to_non_nullable
as int?,fileUrl: freezed == fileUrl ? _self.fileUrl : fileUrl // ignore: cast_nullable_to_non_nullable
as String?,droits: null == droits ? _self.droits : droits // ignore: cast_nullable_to_non_nullable
as DroitsEffectifs,
  ));
}


}

// dart format on
