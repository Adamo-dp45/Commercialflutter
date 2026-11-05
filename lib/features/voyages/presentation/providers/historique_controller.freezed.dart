// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'historique_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HistoriqueEtat {

 List<VoyageHistorique> get voyages; int get page; int get pages; int get total; bool get chargeLaSuite; String? get erreur;
/// Create a copy of HistoriqueEtat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HistoriqueEtatCopyWith<HistoriqueEtat> get copyWith => _$HistoriqueEtatCopyWithImpl<HistoriqueEtat>(this as HistoriqueEtat, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HistoriqueEtat&&const DeepCollectionEquality().equals(other.voyages, voyages)&&(identical(other.page, page) || other.page == page)&&(identical(other.pages, pages) || other.pages == pages)&&(identical(other.total, total) || other.total == total)&&(identical(other.chargeLaSuite, chargeLaSuite) || other.chargeLaSuite == chargeLaSuite)&&(identical(other.erreur, erreur) || other.erreur == erreur));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(voyages),page,pages,total,chargeLaSuite,erreur);

@override
String toString() {
  return 'HistoriqueEtat(voyages: $voyages, page: $page, pages: $pages, total: $total, chargeLaSuite: $chargeLaSuite, erreur: $erreur)';
}


}

/// @nodoc
abstract mixin class $HistoriqueEtatCopyWith<$Res>  {
  factory $HistoriqueEtatCopyWith(HistoriqueEtat value, $Res Function(HistoriqueEtat) _then) = _$HistoriqueEtatCopyWithImpl;
@useResult
$Res call({
 List<VoyageHistorique> voyages, int page, int pages, int total, bool chargeLaSuite, String? erreur
});




}
/// @nodoc
class _$HistoriqueEtatCopyWithImpl<$Res>
    implements $HistoriqueEtatCopyWith<$Res> {
  _$HistoriqueEtatCopyWithImpl(this._self, this._then);

  final HistoriqueEtat _self;
  final $Res Function(HistoriqueEtat) _then;

/// Create a copy of HistoriqueEtat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voyages = null,Object? page = null,Object? pages = null,Object? total = null,Object? chargeLaSuite = null,Object? erreur = freezed,}) {
  return _then(_self.copyWith(
voyages: null == voyages ? _self.voyages : voyages // ignore: cast_nullable_to_non_nullable
as List<VoyageHistorique>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,chargeLaSuite: null == chargeLaSuite ? _self.chargeLaSuite : chargeLaSuite // ignore: cast_nullable_to_non_nullable
as bool,erreur: freezed == erreur ? _self.erreur : erreur // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HistoriqueEtat].
extension HistoriqueEtatPatterns on HistoriqueEtat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HistoriqueEtat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HistoriqueEtat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HistoriqueEtat value)  $default,){
final _that = this;
switch (_that) {
case _HistoriqueEtat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HistoriqueEtat value)?  $default,){
final _that = this;
switch (_that) {
case _HistoriqueEtat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VoyageHistorique> voyages,  int page,  int pages,  int total,  bool chargeLaSuite,  String? erreur)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HistoriqueEtat() when $default != null:
return $default(_that.voyages,_that.page,_that.pages,_that.total,_that.chargeLaSuite,_that.erreur);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VoyageHistorique> voyages,  int page,  int pages,  int total,  bool chargeLaSuite,  String? erreur)  $default,) {final _that = this;
switch (_that) {
case _HistoriqueEtat():
return $default(_that.voyages,_that.page,_that.pages,_that.total,_that.chargeLaSuite,_that.erreur);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VoyageHistorique> voyages,  int page,  int pages,  int total,  bool chargeLaSuite,  String? erreur)?  $default,) {final _that = this;
switch (_that) {
case _HistoriqueEtat() when $default != null:
return $default(_that.voyages,_that.page,_that.pages,_that.total,_that.chargeLaSuite,_that.erreur);case _:
  return null;

}
}

}

/// @nodoc


class _HistoriqueEtat extends HistoriqueEtat {
  const _HistoriqueEtat({final  List<VoyageHistorique> voyages = const <VoyageHistorique>[], this.page = 0, this.pages = 0, this.total = 0, this.chargeLaSuite = false, this.erreur}): _voyages = voyages,super._();
  

 final  List<VoyageHistorique> _voyages;
@override@JsonKey() List<VoyageHistorique> get voyages {
  if (_voyages is EqualUnmodifiableListView) return _voyages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voyages);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  int pages;
@override@JsonKey() final  int total;
@override@JsonKey() final  bool chargeLaSuite;
@override final  String? erreur;

/// Create a copy of HistoriqueEtat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HistoriqueEtatCopyWith<_HistoriqueEtat> get copyWith => __$HistoriqueEtatCopyWithImpl<_HistoriqueEtat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HistoriqueEtat&&const DeepCollectionEquality().equals(other._voyages, _voyages)&&(identical(other.page, page) || other.page == page)&&(identical(other.pages, pages) || other.pages == pages)&&(identical(other.total, total) || other.total == total)&&(identical(other.chargeLaSuite, chargeLaSuite) || other.chargeLaSuite == chargeLaSuite)&&(identical(other.erreur, erreur) || other.erreur == erreur));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_voyages),page,pages,total,chargeLaSuite,erreur);

@override
String toString() {
  return 'HistoriqueEtat(voyages: $voyages, page: $page, pages: $pages, total: $total, chargeLaSuite: $chargeLaSuite, erreur: $erreur)';
}


}

/// @nodoc
abstract mixin class _$HistoriqueEtatCopyWith<$Res> implements $HistoriqueEtatCopyWith<$Res> {
  factory _$HistoriqueEtatCopyWith(_HistoriqueEtat value, $Res Function(_HistoriqueEtat) _then) = __$HistoriqueEtatCopyWithImpl;
@override @useResult
$Res call({
 List<VoyageHistorique> voyages, int page, int pages, int total, bool chargeLaSuite, String? erreur
});




}
/// @nodoc
class __$HistoriqueEtatCopyWithImpl<$Res>
    implements _$HistoriqueEtatCopyWith<$Res> {
  __$HistoriqueEtatCopyWithImpl(this._self, this._then);

  final _HistoriqueEtat _self;
  final $Res Function(_HistoriqueEtat) _then;

/// Create a copy of HistoriqueEtat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voyages = null,Object? page = null,Object? pages = null,Object? total = null,Object? chargeLaSuite = null,Object? erreur = freezed,}) {
  return _then(_HistoriqueEtat(
voyages: null == voyages ? _self._voyages : voyages // ignore: cast_nullable_to_non_nullable
as List<VoyageHistorique>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,chargeLaSuite: null == chargeLaSuite ? _self.chargeLaSuite : chargeLaSuite // ignore: cast_nullable_to_non_nullable
as bool,erreur: freezed == erreur ? _self.erreur : erreur // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
