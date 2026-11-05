// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bilan_commercial.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BilanChiffres {

 int get recette; int get recetteBillets; int get recetteBagages; int get nbBillets; int get nbBagages;/// Recette (bagages compris) rapportée au nombre de BILLETS. Calculé par le
/// serveur : un bagage est un supplément à une vente, pas une vente de plus,
/// et cette définition ne doit s'écrire qu'à un seul endroit.
 int get panierMoyen; int get nbVoyages;
/// Create a copy of BilanChiffres
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BilanChiffresCopyWith<BilanChiffres> get copyWith => _$BilanChiffresCopyWithImpl<BilanChiffres>(this as BilanChiffres, _$identity);

  /// Serializes this BilanChiffres to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilanChiffres&&(identical(other.recette, recette) || other.recette == recette)&&(identical(other.recetteBillets, recetteBillets) || other.recetteBillets == recetteBillets)&&(identical(other.recetteBagages, recetteBagages) || other.recetteBagages == recetteBagages)&&(identical(other.nbBillets, nbBillets) || other.nbBillets == nbBillets)&&(identical(other.nbBagages, nbBagages) || other.nbBagages == nbBagages)&&(identical(other.panierMoyen, panierMoyen) || other.panierMoyen == panierMoyen)&&(identical(other.nbVoyages, nbVoyages) || other.nbVoyages == nbVoyages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recette,recetteBillets,recetteBagages,nbBillets,nbBagages,panierMoyen,nbVoyages);

@override
String toString() {
  return 'BilanChiffres(recette: $recette, recetteBillets: $recetteBillets, recetteBagages: $recetteBagages, nbBillets: $nbBillets, nbBagages: $nbBagages, panierMoyen: $panierMoyen, nbVoyages: $nbVoyages)';
}


}

/// @nodoc
abstract mixin class $BilanChiffresCopyWith<$Res>  {
  factory $BilanChiffresCopyWith(BilanChiffres value, $Res Function(BilanChiffres) _then) = _$BilanChiffresCopyWithImpl;
@useResult
$Res call({
 int recette, int recetteBillets, int recetteBagages, int nbBillets, int nbBagages, int panierMoyen, int nbVoyages
});




}
/// @nodoc
class _$BilanChiffresCopyWithImpl<$Res>
    implements $BilanChiffresCopyWith<$Res> {
  _$BilanChiffresCopyWithImpl(this._self, this._then);

  final BilanChiffres _self;
  final $Res Function(BilanChiffres) _then;

/// Create a copy of BilanChiffres
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recette = null,Object? recetteBillets = null,Object? recetteBagages = null,Object? nbBillets = null,Object? nbBagages = null,Object? panierMoyen = null,Object? nbVoyages = null,}) {
  return _then(_self.copyWith(
recette: null == recette ? _self.recette : recette // ignore: cast_nullable_to_non_nullable
as int,recetteBillets: null == recetteBillets ? _self.recetteBillets : recetteBillets // ignore: cast_nullable_to_non_nullable
as int,recetteBagages: null == recetteBagages ? _self.recetteBagages : recetteBagages // ignore: cast_nullable_to_non_nullable
as int,nbBillets: null == nbBillets ? _self.nbBillets : nbBillets // ignore: cast_nullable_to_non_nullable
as int,nbBagages: null == nbBagages ? _self.nbBagages : nbBagages // ignore: cast_nullable_to_non_nullable
as int,panierMoyen: null == panierMoyen ? _self.panierMoyen : panierMoyen // ignore: cast_nullable_to_non_nullable
as int,nbVoyages: null == nbVoyages ? _self.nbVoyages : nbVoyages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BilanChiffres].
extension BilanChiffresPatterns on BilanChiffres {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BilanChiffres value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BilanChiffres() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BilanChiffres value)  $default,){
final _that = this;
switch (_that) {
case _BilanChiffres():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BilanChiffres value)?  $default,){
final _that = this;
switch (_that) {
case _BilanChiffres() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int recette,  int recetteBillets,  int recetteBagages,  int nbBillets,  int nbBagages,  int panierMoyen,  int nbVoyages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BilanChiffres() when $default != null:
return $default(_that.recette,_that.recetteBillets,_that.recetteBagages,_that.nbBillets,_that.nbBagages,_that.panierMoyen,_that.nbVoyages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int recette,  int recetteBillets,  int recetteBagages,  int nbBillets,  int nbBagages,  int panierMoyen,  int nbVoyages)  $default,) {final _that = this;
switch (_that) {
case _BilanChiffres():
return $default(_that.recette,_that.recetteBillets,_that.recetteBagages,_that.nbBillets,_that.nbBagages,_that.panierMoyen,_that.nbVoyages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int recette,  int recetteBillets,  int recetteBagages,  int nbBillets,  int nbBagages,  int panierMoyen,  int nbVoyages)?  $default,) {final _that = this;
switch (_that) {
case _BilanChiffres() when $default != null:
return $default(_that.recette,_that.recetteBillets,_that.recetteBagages,_that.nbBillets,_that.nbBagages,_that.panierMoyen,_that.nbVoyages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BilanChiffres extends BilanChiffres {
  const _BilanChiffres({this.recette = 0, this.recetteBillets = 0, this.recetteBagages = 0, this.nbBillets = 0, this.nbBagages = 0, this.panierMoyen = 0, this.nbVoyages = 0}): super._();
  factory _BilanChiffres.fromJson(Map<String, dynamic> json) => _$BilanChiffresFromJson(json);

@override@JsonKey() final  int recette;
@override@JsonKey() final  int recetteBillets;
@override@JsonKey() final  int recetteBagages;
@override@JsonKey() final  int nbBillets;
@override@JsonKey() final  int nbBagages;
/// Recette (bagages compris) rapportée au nombre de BILLETS. Calculé par le
/// serveur : un bagage est un supplément à une vente, pas une vente de plus,
/// et cette définition ne doit s'écrire qu'à un seul endroit.
@override@JsonKey() final  int panierMoyen;
@override@JsonKey() final  int nbVoyages;

/// Create a copy of BilanChiffres
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BilanChiffresCopyWith<_BilanChiffres> get copyWith => __$BilanChiffresCopyWithImpl<_BilanChiffres>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BilanChiffresToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BilanChiffres&&(identical(other.recette, recette) || other.recette == recette)&&(identical(other.recetteBillets, recetteBillets) || other.recetteBillets == recetteBillets)&&(identical(other.recetteBagages, recetteBagages) || other.recetteBagages == recetteBagages)&&(identical(other.nbBillets, nbBillets) || other.nbBillets == nbBillets)&&(identical(other.nbBagages, nbBagages) || other.nbBagages == nbBagages)&&(identical(other.panierMoyen, panierMoyen) || other.panierMoyen == panierMoyen)&&(identical(other.nbVoyages, nbVoyages) || other.nbVoyages == nbVoyages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recette,recetteBillets,recetteBagages,nbBillets,nbBagages,panierMoyen,nbVoyages);

@override
String toString() {
  return 'BilanChiffres(recette: $recette, recetteBillets: $recetteBillets, recetteBagages: $recetteBagages, nbBillets: $nbBillets, nbBagages: $nbBagages, panierMoyen: $panierMoyen, nbVoyages: $nbVoyages)';
}


}

/// @nodoc
abstract mixin class _$BilanChiffresCopyWith<$Res> implements $BilanChiffresCopyWith<$Res> {
  factory _$BilanChiffresCopyWith(_BilanChiffres value, $Res Function(_BilanChiffres) _then) = __$BilanChiffresCopyWithImpl;
@override @useResult
$Res call({
 int recette, int recetteBillets, int recetteBagages, int nbBillets, int nbBagages, int panierMoyen, int nbVoyages
});




}
/// @nodoc
class __$BilanChiffresCopyWithImpl<$Res>
    implements _$BilanChiffresCopyWith<$Res> {
  __$BilanChiffresCopyWithImpl(this._self, this._then);

  final _BilanChiffres _self;
  final $Res Function(_BilanChiffres) _then;

/// Create a copy of BilanChiffres
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recette = null,Object? recetteBillets = null,Object? recetteBagages = null,Object? nbBillets = null,Object? nbBagages = null,Object? panierMoyen = null,Object? nbVoyages = null,}) {
  return _then(_BilanChiffres(
recette: null == recette ? _self.recette : recette // ignore: cast_nullable_to_non_nullable
as int,recetteBillets: null == recetteBillets ? _self.recetteBillets : recetteBillets // ignore: cast_nullable_to_non_nullable
as int,recetteBagages: null == recetteBagages ? _self.recetteBagages : recetteBagages // ignore: cast_nullable_to_non_nullable
as int,nbBillets: null == nbBillets ? _self.nbBillets : nbBillets // ignore: cast_nullable_to_non_nullable
as int,nbBagages: null == nbBagages ? _self.nbBagages : nbBagages // ignore: cast_nullable_to_non_nullable
as int,panierMoyen: null == panierMoyen ? _self.panierMoyen : panierMoyen // ignore: cast_nullable_to_non_nullable
as int,nbVoyages: null == nbVoyages ? _self.nbVoyages : nbVoyages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BilanPeriode {

 String? get debut; String? get fin;
/// Create a copy of BilanPeriode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BilanPeriodeCopyWith<BilanPeriode> get copyWith => _$BilanPeriodeCopyWithImpl<BilanPeriode>(this as BilanPeriode, _$identity);

  /// Serializes this BilanPeriode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilanPeriode&&(identical(other.debut, debut) || other.debut == debut)&&(identical(other.fin, fin) || other.fin == fin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,debut,fin);

@override
String toString() {
  return 'BilanPeriode(debut: $debut, fin: $fin)';
}


}

/// @nodoc
abstract mixin class $BilanPeriodeCopyWith<$Res>  {
  factory $BilanPeriodeCopyWith(BilanPeriode value, $Res Function(BilanPeriode) _then) = _$BilanPeriodeCopyWithImpl;
@useResult
$Res call({
 String? debut, String? fin
});




}
/// @nodoc
class _$BilanPeriodeCopyWithImpl<$Res>
    implements $BilanPeriodeCopyWith<$Res> {
  _$BilanPeriodeCopyWithImpl(this._self, this._then);

  final BilanPeriode _self;
  final $Res Function(BilanPeriode) _then;

/// Create a copy of BilanPeriode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? debut = freezed,Object? fin = freezed,}) {
  return _then(_self.copyWith(
debut: freezed == debut ? _self.debut : debut // ignore: cast_nullable_to_non_nullable
as String?,fin: freezed == fin ? _self.fin : fin // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [BilanPeriode].
extension BilanPeriodePatterns on BilanPeriode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BilanPeriode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BilanPeriode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BilanPeriode value)  $default,){
final _that = this;
switch (_that) {
case _BilanPeriode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BilanPeriode value)?  $default,){
final _that = this;
switch (_that) {
case _BilanPeriode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? debut,  String? fin)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BilanPeriode() when $default != null:
return $default(_that.debut,_that.fin);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? debut,  String? fin)  $default,) {final _that = this;
switch (_that) {
case _BilanPeriode():
return $default(_that.debut,_that.fin);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? debut,  String? fin)?  $default,) {final _that = this;
switch (_that) {
case _BilanPeriode() when $default != null:
return $default(_that.debut,_that.fin);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BilanPeriode implements BilanPeriode {
  const _BilanPeriode({this.debut, this.fin});
  factory _BilanPeriode.fromJson(Map<String, dynamic> json) => _$BilanPeriodeFromJson(json);

@override final  String? debut;
@override final  String? fin;

/// Create a copy of BilanPeriode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BilanPeriodeCopyWith<_BilanPeriode> get copyWith => __$BilanPeriodeCopyWithImpl<_BilanPeriode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BilanPeriodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BilanPeriode&&(identical(other.debut, debut) || other.debut == debut)&&(identical(other.fin, fin) || other.fin == fin));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,debut,fin);

@override
String toString() {
  return 'BilanPeriode(debut: $debut, fin: $fin)';
}


}

/// @nodoc
abstract mixin class _$BilanPeriodeCopyWith<$Res> implements $BilanPeriodeCopyWith<$Res> {
  factory _$BilanPeriodeCopyWith(_BilanPeriode value, $Res Function(_BilanPeriode) _then) = __$BilanPeriodeCopyWithImpl;
@override @useResult
$Res call({
 String? debut, String? fin
});




}
/// @nodoc
class __$BilanPeriodeCopyWithImpl<$Res>
    implements _$BilanPeriodeCopyWith<$Res> {
  __$BilanPeriodeCopyWithImpl(this._self, this._then);

  final _BilanPeriode _self;
  final $Res Function(_BilanPeriode) _then;

/// Create a copy of BilanPeriode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? debut = freezed,Object? fin = freezed,}) {
  return _then(_BilanPeriode(
debut: freezed == debut ? _self.debut : debut // ignore: cast_nullable_to_non_nullable
as String?,fin: freezed == fin ? _self.fin : fin // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$BilanCommercial {

 BilanPeriode? get periode; BilanChiffres get surPeriode; BilanChiffres get total;
/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BilanCommercialCopyWith<BilanCommercial> get copyWith => _$BilanCommercialCopyWithImpl<BilanCommercial>(this as BilanCommercial, _$identity);

  /// Serializes this BilanCommercial to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BilanCommercial&&(identical(other.periode, periode) || other.periode == periode)&&(identical(other.surPeriode, surPeriode) || other.surPeriode == surPeriode)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periode,surPeriode,total);

@override
String toString() {
  return 'BilanCommercial(periode: $periode, surPeriode: $surPeriode, total: $total)';
}


}

/// @nodoc
abstract mixin class $BilanCommercialCopyWith<$Res>  {
  factory $BilanCommercialCopyWith(BilanCommercial value, $Res Function(BilanCommercial) _then) = _$BilanCommercialCopyWithImpl;
@useResult
$Res call({
 BilanPeriode? periode, BilanChiffres surPeriode, BilanChiffres total
});


$BilanPeriodeCopyWith<$Res>? get periode;$BilanChiffresCopyWith<$Res> get surPeriode;$BilanChiffresCopyWith<$Res> get total;

}
/// @nodoc
class _$BilanCommercialCopyWithImpl<$Res>
    implements $BilanCommercialCopyWith<$Res> {
  _$BilanCommercialCopyWithImpl(this._self, this._then);

  final BilanCommercial _self;
  final $Res Function(BilanCommercial) _then;

/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periode = freezed,Object? surPeriode = null,Object? total = null,}) {
  return _then(_self.copyWith(
periode: freezed == periode ? _self.periode : periode // ignore: cast_nullable_to_non_nullable
as BilanPeriode?,surPeriode: null == surPeriode ? _self.surPeriode : surPeriode // ignore: cast_nullable_to_non_nullable
as BilanChiffres,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as BilanChiffres,
  ));
}
/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BilanPeriodeCopyWith<$Res>? get periode {
    if (_self.periode == null) {
    return null;
  }

  return $BilanPeriodeCopyWith<$Res>(_self.periode!, (value) {
    return _then(_self.copyWith(periode: value));
  });
}/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BilanChiffresCopyWith<$Res> get surPeriode {
  
  return $BilanChiffresCopyWith<$Res>(_self.surPeriode, (value) {
    return _then(_self.copyWith(surPeriode: value));
  });
}/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BilanChiffresCopyWith<$Res> get total {
  
  return $BilanChiffresCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}


/// Adds pattern-matching-related methods to [BilanCommercial].
extension BilanCommercialPatterns on BilanCommercial {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BilanCommercial value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BilanCommercial() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BilanCommercial value)  $default,){
final _that = this;
switch (_that) {
case _BilanCommercial():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BilanCommercial value)?  $default,){
final _that = this;
switch (_that) {
case _BilanCommercial() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BilanPeriode? periode,  BilanChiffres surPeriode,  BilanChiffres total)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BilanCommercial() when $default != null:
return $default(_that.periode,_that.surPeriode,_that.total);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BilanPeriode? periode,  BilanChiffres surPeriode,  BilanChiffres total)  $default,) {final _that = this;
switch (_that) {
case _BilanCommercial():
return $default(_that.periode,_that.surPeriode,_that.total);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BilanPeriode? periode,  BilanChiffres surPeriode,  BilanChiffres total)?  $default,) {final _that = this;
switch (_that) {
case _BilanCommercial() when $default != null:
return $default(_that.periode,_that.surPeriode,_that.total);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BilanCommercial implements BilanCommercial {
  const _BilanCommercial({this.periode, this.surPeriode = const BilanChiffres(), this.total = const BilanChiffres()});
  factory _BilanCommercial.fromJson(Map<String, dynamic> json) => _$BilanCommercialFromJson(json);

@override final  BilanPeriode? periode;
@override@JsonKey() final  BilanChiffres surPeriode;
@override@JsonKey() final  BilanChiffres total;

/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BilanCommercialCopyWith<_BilanCommercial> get copyWith => __$BilanCommercialCopyWithImpl<_BilanCommercial>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BilanCommercialToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BilanCommercial&&(identical(other.periode, periode) || other.periode == periode)&&(identical(other.surPeriode, surPeriode) || other.surPeriode == surPeriode)&&(identical(other.total, total) || other.total == total));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periode,surPeriode,total);

@override
String toString() {
  return 'BilanCommercial(periode: $periode, surPeriode: $surPeriode, total: $total)';
}


}

/// @nodoc
abstract mixin class _$BilanCommercialCopyWith<$Res> implements $BilanCommercialCopyWith<$Res> {
  factory _$BilanCommercialCopyWith(_BilanCommercial value, $Res Function(_BilanCommercial) _then) = __$BilanCommercialCopyWithImpl;
@override @useResult
$Res call({
 BilanPeriode? periode, BilanChiffres surPeriode, BilanChiffres total
});


@override $BilanPeriodeCopyWith<$Res>? get periode;@override $BilanChiffresCopyWith<$Res> get surPeriode;@override $BilanChiffresCopyWith<$Res> get total;

}
/// @nodoc
class __$BilanCommercialCopyWithImpl<$Res>
    implements _$BilanCommercialCopyWith<$Res> {
  __$BilanCommercialCopyWithImpl(this._self, this._then);

  final _BilanCommercial _self;
  final $Res Function(_BilanCommercial) _then;

/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periode = freezed,Object? surPeriode = null,Object? total = null,}) {
  return _then(_BilanCommercial(
periode: freezed == periode ? _self.periode : periode // ignore: cast_nullable_to_non_nullable
as BilanPeriode?,surPeriode: null == surPeriode ? _self.surPeriode : surPeriode // ignore: cast_nullable_to_non_nullable
as BilanChiffres,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as BilanChiffres,
  ));
}

/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BilanPeriodeCopyWith<$Res>? get periode {
    if (_self.periode == null) {
    return null;
  }

  return $BilanPeriodeCopyWith<$Res>(_self.periode!, (value) {
    return _then(_self.copyWith(periode: value));
  });
}/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BilanChiffresCopyWith<$Res> get surPeriode {
  
  return $BilanChiffresCopyWith<$Res>(_self.surPeriode, (value) {
    return _then(_self.copyWith(surPeriode: value));
  });
}/// Create a copy of BilanCommercial
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$BilanChiffresCopyWith<$Res> get total {
  
  return $BilanChiffresCopyWith<$Res>(_self.total, (value) {
    return _then(_self.copyWith(total: value));
  });
}
}

// dart format on
