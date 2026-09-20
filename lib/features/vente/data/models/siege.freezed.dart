// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'siege.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Siege {

 int get id; int get numero; int get rangee; int get colonne; String get cote; String get statut; bool get revendu; bool get conflit; String? get occupantNom; int? get occupantTicketId; bool get venduAval; String? get avalNom; String? get avalMontee; String? get avalDescente; int get avalNombre;
/// Create a copy of Siege
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SiegeCopyWith<Siege> get copyWith => _$SiegeCopyWithImpl<Siege>(this as Siege, _$identity);

  /// Serializes this Siege to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Siege&&(identical(other.id, id) || other.id == id)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.rangee, rangee) || other.rangee == rangee)&&(identical(other.colonne, colonne) || other.colonne == colonne)&&(identical(other.cote, cote) || other.cote == cote)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.revendu, revendu) || other.revendu == revendu)&&(identical(other.conflit, conflit) || other.conflit == conflit)&&(identical(other.occupantNom, occupantNom) || other.occupantNom == occupantNom)&&(identical(other.occupantTicketId, occupantTicketId) || other.occupantTicketId == occupantTicketId)&&(identical(other.venduAval, venduAval) || other.venduAval == venduAval)&&(identical(other.avalNom, avalNom) || other.avalNom == avalNom)&&(identical(other.avalMontee, avalMontee) || other.avalMontee == avalMontee)&&(identical(other.avalDescente, avalDescente) || other.avalDescente == avalDescente)&&(identical(other.avalNombre, avalNombre) || other.avalNombre == avalNombre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,numero,rangee,colonne,cote,statut,revendu,conflit,occupantNom,occupantTicketId,venduAval,avalNom,avalMontee,avalDescente,avalNombre);

@override
String toString() {
  return 'Siege(id: $id, numero: $numero, rangee: $rangee, colonne: $colonne, cote: $cote, statut: $statut, revendu: $revendu, conflit: $conflit, occupantNom: $occupantNom, occupantTicketId: $occupantTicketId, venduAval: $venduAval, avalNom: $avalNom, avalMontee: $avalMontee, avalDescente: $avalDescente, avalNombre: $avalNombre)';
}


}

/// @nodoc
abstract mixin class $SiegeCopyWith<$Res>  {
  factory $SiegeCopyWith(Siege value, $Res Function(Siege) _then) = _$SiegeCopyWithImpl;
@useResult
$Res call({
 int id, int numero, int rangee, int colonne, String cote, String statut, bool revendu, bool conflit, String? occupantNom, int? occupantTicketId, bool venduAval, String? avalNom, String? avalMontee, String? avalDescente, int avalNombre
});




}
/// @nodoc
class _$SiegeCopyWithImpl<$Res>
    implements $SiegeCopyWith<$Res> {
  _$SiegeCopyWithImpl(this._self, this._then);

  final Siege _self;
  final $Res Function(Siege) _then;

/// Create a copy of Siege
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? numero = null,Object? rangee = null,Object? colonne = null,Object? cote = null,Object? statut = null,Object? revendu = null,Object? conflit = null,Object? occupantNom = freezed,Object? occupantTicketId = freezed,Object? venduAval = null,Object? avalNom = freezed,Object? avalMontee = freezed,Object? avalDescente = freezed,Object? avalNombre = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,numero: null == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as int,rangee: null == rangee ? _self.rangee : rangee // ignore: cast_nullable_to_non_nullable
as int,colonne: null == colonne ? _self.colonne : colonne // ignore: cast_nullable_to_non_nullable
as int,cote: null == cote ? _self.cote : cote // ignore: cast_nullable_to_non_nullable
as String,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,revendu: null == revendu ? _self.revendu : revendu // ignore: cast_nullable_to_non_nullable
as bool,conflit: null == conflit ? _self.conflit : conflit // ignore: cast_nullable_to_non_nullable
as bool,occupantNom: freezed == occupantNom ? _self.occupantNom : occupantNom // ignore: cast_nullable_to_non_nullable
as String?,occupantTicketId: freezed == occupantTicketId ? _self.occupantTicketId : occupantTicketId // ignore: cast_nullable_to_non_nullable
as int?,venduAval: null == venduAval ? _self.venduAval : venduAval // ignore: cast_nullable_to_non_nullable
as bool,avalNom: freezed == avalNom ? _self.avalNom : avalNom // ignore: cast_nullable_to_non_nullable
as String?,avalMontee: freezed == avalMontee ? _self.avalMontee : avalMontee // ignore: cast_nullable_to_non_nullable
as String?,avalDescente: freezed == avalDescente ? _self.avalDescente : avalDescente // ignore: cast_nullable_to_non_nullable
as String?,avalNombre: null == avalNombre ? _self.avalNombre : avalNombre // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Siege].
extension SiegePatterns on Siege {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Siege value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Siege() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Siege value)  $default,){
final _that = this;
switch (_that) {
case _Siege():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Siege value)?  $default,){
final _that = this;
switch (_that) {
case _Siege() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  int numero,  int rangee,  int colonne,  String cote,  String statut,  bool revendu,  bool conflit,  String? occupantNom,  int? occupantTicketId,  bool venduAval,  String? avalNom,  String? avalMontee,  String? avalDescente,  int avalNombre)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Siege() when $default != null:
return $default(_that.id,_that.numero,_that.rangee,_that.colonne,_that.cote,_that.statut,_that.revendu,_that.conflit,_that.occupantNom,_that.occupantTicketId,_that.venduAval,_that.avalNom,_that.avalMontee,_that.avalDescente,_that.avalNombre);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  int numero,  int rangee,  int colonne,  String cote,  String statut,  bool revendu,  bool conflit,  String? occupantNom,  int? occupantTicketId,  bool venduAval,  String? avalNom,  String? avalMontee,  String? avalDescente,  int avalNombre)  $default,) {final _that = this;
switch (_that) {
case _Siege():
return $default(_that.id,_that.numero,_that.rangee,_that.colonne,_that.cote,_that.statut,_that.revendu,_that.conflit,_that.occupantNom,_that.occupantTicketId,_that.venduAval,_that.avalNom,_that.avalMontee,_that.avalDescente,_that.avalNombre);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  int numero,  int rangee,  int colonne,  String cote,  String statut,  bool revendu,  bool conflit,  String? occupantNom,  int? occupantTicketId,  bool venduAval,  String? avalNom,  String? avalMontee,  String? avalDescente,  int avalNombre)?  $default,) {final _that = this;
switch (_that) {
case _Siege() when $default != null:
return $default(_that.id,_that.numero,_that.rangee,_that.colonne,_that.cote,_that.statut,_that.revendu,_that.conflit,_that.occupantNom,_that.occupantTicketId,_that.venduAval,_that.avalNom,_that.avalMontee,_that.avalDescente,_that.avalNombre);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Siege extends Siege {
  const _Siege({required this.id, required this.numero, this.rangee = 0, this.colonne = 0, this.cote = 'GAUCHE', this.statut = 'LIBRE', this.revendu = false, this.conflit = false, this.occupantNom, this.occupantTicketId, this.venduAval = false, this.avalNom, this.avalMontee, this.avalDescente, this.avalNombre = 0}): super._();
  factory _Siege.fromJson(Map<String, dynamic> json) => _$SiegeFromJson(json);

@override final  int id;
@override final  int numero;
@override@JsonKey() final  int rangee;
@override@JsonKey() final  int colonne;
@override@JsonKey() final  String cote;
@override@JsonKey() final  String statut;
@override@JsonKey() final  bool revendu;
@override@JsonKey() final  bool conflit;
@override final  String? occupantNom;
@override final  int? occupantTicketId;
@override@JsonKey() final  bool venduAval;
@override final  String? avalNom;
@override final  String? avalMontee;
@override final  String? avalDescente;
@override@JsonKey() final  int avalNombre;

/// Create a copy of Siege
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SiegeCopyWith<_Siege> get copyWith => __$SiegeCopyWithImpl<_Siege>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SiegeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Siege&&(identical(other.id, id) || other.id == id)&&(identical(other.numero, numero) || other.numero == numero)&&(identical(other.rangee, rangee) || other.rangee == rangee)&&(identical(other.colonne, colonne) || other.colonne == colonne)&&(identical(other.cote, cote) || other.cote == cote)&&(identical(other.statut, statut) || other.statut == statut)&&(identical(other.revendu, revendu) || other.revendu == revendu)&&(identical(other.conflit, conflit) || other.conflit == conflit)&&(identical(other.occupantNom, occupantNom) || other.occupantNom == occupantNom)&&(identical(other.occupantTicketId, occupantTicketId) || other.occupantTicketId == occupantTicketId)&&(identical(other.venduAval, venduAval) || other.venduAval == venduAval)&&(identical(other.avalNom, avalNom) || other.avalNom == avalNom)&&(identical(other.avalMontee, avalMontee) || other.avalMontee == avalMontee)&&(identical(other.avalDescente, avalDescente) || other.avalDescente == avalDescente)&&(identical(other.avalNombre, avalNombre) || other.avalNombre == avalNombre));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,numero,rangee,colonne,cote,statut,revendu,conflit,occupantNom,occupantTicketId,venduAval,avalNom,avalMontee,avalDescente,avalNombre);

@override
String toString() {
  return 'Siege(id: $id, numero: $numero, rangee: $rangee, colonne: $colonne, cote: $cote, statut: $statut, revendu: $revendu, conflit: $conflit, occupantNom: $occupantNom, occupantTicketId: $occupantTicketId, venduAval: $venduAval, avalNom: $avalNom, avalMontee: $avalMontee, avalDescente: $avalDescente, avalNombre: $avalNombre)';
}


}

/// @nodoc
abstract mixin class _$SiegeCopyWith<$Res> implements $SiegeCopyWith<$Res> {
  factory _$SiegeCopyWith(_Siege value, $Res Function(_Siege) _then) = __$SiegeCopyWithImpl;
@override @useResult
$Res call({
 int id, int numero, int rangee, int colonne, String cote, String statut, bool revendu, bool conflit, String? occupantNom, int? occupantTicketId, bool venduAval, String? avalNom, String? avalMontee, String? avalDescente, int avalNombre
});




}
/// @nodoc
class __$SiegeCopyWithImpl<$Res>
    implements _$SiegeCopyWith<$Res> {
  __$SiegeCopyWithImpl(this._self, this._then);

  final _Siege _self;
  final $Res Function(_Siege) _then;

/// Create a copy of Siege
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? numero = null,Object? rangee = null,Object? colonne = null,Object? cote = null,Object? statut = null,Object? revendu = null,Object? conflit = null,Object? occupantNom = freezed,Object? occupantTicketId = freezed,Object? venduAval = null,Object? avalNom = freezed,Object? avalMontee = freezed,Object? avalDescente = freezed,Object? avalNombre = null,}) {
  return _then(_Siege(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,numero: null == numero ? _self.numero : numero // ignore: cast_nullable_to_non_nullable
as int,rangee: null == rangee ? _self.rangee : rangee // ignore: cast_nullable_to_non_nullable
as int,colonne: null == colonne ? _self.colonne : colonne // ignore: cast_nullable_to_non_nullable
as int,cote: null == cote ? _self.cote : cote // ignore: cast_nullable_to_non_nullable
as String,statut: null == statut ? _self.statut : statut // ignore: cast_nullable_to_non_nullable
as String,revendu: null == revendu ? _self.revendu : revendu // ignore: cast_nullable_to_non_nullable
as bool,conflit: null == conflit ? _self.conflit : conflit // ignore: cast_nullable_to_non_nullable
as bool,occupantNom: freezed == occupantNom ? _self.occupantNom : occupantNom // ignore: cast_nullable_to_non_nullable
as String?,occupantTicketId: freezed == occupantTicketId ? _self.occupantTicketId : occupantTicketId // ignore: cast_nullable_to_non_nullable
as int?,venduAval: null == venduAval ? _self.venduAval : venduAval // ignore: cast_nullable_to_non_nullable
as bool,avalNom: freezed == avalNom ? _self.avalNom : avalNom // ignore: cast_nullable_to_non_nullable
as String?,avalMontee: freezed == avalMontee ? _self.avalMontee : avalMontee // ignore: cast_nullable_to_non_nullable
as String?,avalDescente: freezed == avalDescente ? _self.avalDescente : avalDescente // ignore: cast_nullable_to_non_nullable
as String?,avalNombre: null == avalNombre ? _self.avalNombre : avalNombre // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
