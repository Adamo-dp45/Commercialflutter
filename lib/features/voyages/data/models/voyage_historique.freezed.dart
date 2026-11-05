// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voyage_historique.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoyageHistorique {

 int get id; String? get codevoyage; int? get numerodepart; String? get provenance; String? get destination; DateTime? get datedepartprevue; DateTime? get datearriveereelle; bool get demarre; bool get cloture; String? get carMatricule; int get maRecette; int get mesTickets; int get mesBagages;
/// Create a copy of VoyageHistorique
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoyageHistoriqueCopyWith<VoyageHistorique> get copyWith => _$VoyageHistoriqueCopyWithImpl<VoyageHistorique>(this as VoyageHistorique, _$identity);

  /// Serializes this VoyageHistorique to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoyageHistorique&&(identical(other.id, id) || other.id == id)&&(identical(other.codevoyage, codevoyage) || other.codevoyage == codevoyage)&&(identical(other.numerodepart, numerodepart) || other.numerodepart == numerodepart)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.datedepartprevue, datedepartprevue) || other.datedepartprevue == datedepartprevue)&&(identical(other.datearriveereelle, datearriveereelle) || other.datearriveereelle == datearriveereelle)&&(identical(other.demarre, demarre) || other.demarre == demarre)&&(identical(other.cloture, cloture) || other.cloture == cloture)&&(identical(other.carMatricule, carMatricule) || other.carMatricule == carMatricule)&&(identical(other.maRecette, maRecette) || other.maRecette == maRecette)&&(identical(other.mesTickets, mesTickets) || other.mesTickets == mesTickets)&&(identical(other.mesBagages, mesBagages) || other.mesBagages == mesBagages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codevoyage,numerodepart,provenance,destination,datedepartprevue,datearriveereelle,demarre,cloture,carMatricule,maRecette,mesTickets,mesBagages);

@override
String toString() {
  return 'VoyageHistorique(id: $id, codevoyage: $codevoyage, numerodepart: $numerodepart, provenance: $provenance, destination: $destination, datedepartprevue: $datedepartprevue, datearriveereelle: $datearriveereelle, demarre: $demarre, cloture: $cloture, carMatricule: $carMatricule, maRecette: $maRecette, mesTickets: $mesTickets, mesBagages: $mesBagages)';
}


}

/// @nodoc
abstract mixin class $VoyageHistoriqueCopyWith<$Res>  {
  factory $VoyageHistoriqueCopyWith(VoyageHistorique value, $Res Function(VoyageHistorique) _then) = _$VoyageHistoriqueCopyWithImpl;
@useResult
$Res call({
 int id, String? codevoyage, int? numerodepart, String? provenance, String? destination, DateTime? datedepartprevue, DateTime? datearriveereelle, bool demarre, bool cloture, String? carMatricule, int maRecette, int mesTickets, int mesBagages
});




}
/// @nodoc
class _$VoyageHistoriqueCopyWithImpl<$Res>
    implements $VoyageHistoriqueCopyWith<$Res> {
  _$VoyageHistoriqueCopyWithImpl(this._self, this._then);

  final VoyageHistorique _self;
  final $Res Function(VoyageHistorique) _then;

/// Create a copy of VoyageHistorique
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? codevoyage = freezed,Object? numerodepart = freezed,Object? provenance = freezed,Object? destination = freezed,Object? datedepartprevue = freezed,Object? datearriveereelle = freezed,Object? demarre = null,Object? cloture = null,Object? carMatricule = freezed,Object? maRecette = null,Object? mesTickets = null,Object? mesBagages = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codevoyage: freezed == codevoyage ? _self.codevoyage : codevoyage // ignore: cast_nullable_to_non_nullable
as String?,numerodepart: freezed == numerodepart ? _self.numerodepart : numerodepart // ignore: cast_nullable_to_non_nullable
as int?,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,datedepartprevue: freezed == datedepartprevue ? _self.datedepartprevue : datedepartprevue // ignore: cast_nullable_to_non_nullable
as DateTime?,datearriveereelle: freezed == datearriveereelle ? _self.datearriveereelle : datearriveereelle // ignore: cast_nullable_to_non_nullable
as DateTime?,demarre: null == demarre ? _self.demarre : demarre // ignore: cast_nullable_to_non_nullable
as bool,cloture: null == cloture ? _self.cloture : cloture // ignore: cast_nullable_to_non_nullable
as bool,carMatricule: freezed == carMatricule ? _self.carMatricule : carMatricule // ignore: cast_nullable_to_non_nullable
as String?,maRecette: null == maRecette ? _self.maRecette : maRecette // ignore: cast_nullable_to_non_nullable
as int,mesTickets: null == mesTickets ? _self.mesTickets : mesTickets // ignore: cast_nullable_to_non_nullable
as int,mesBagages: null == mesBagages ? _self.mesBagages : mesBagages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [VoyageHistorique].
extension VoyageHistoriquePatterns on VoyageHistorique {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoyageHistorique value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoyageHistorique() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoyageHistorique value)  $default,){
final _that = this;
switch (_that) {
case _VoyageHistorique():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoyageHistorique value)?  $default,){
final _that = this;
switch (_that) {
case _VoyageHistorique() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? codevoyage,  int? numerodepart,  String? provenance,  String? destination,  DateTime? datedepartprevue,  DateTime? datearriveereelle,  bool demarre,  bool cloture,  String? carMatricule,  int maRecette,  int mesTickets,  int mesBagages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoyageHistorique() when $default != null:
return $default(_that.id,_that.codevoyage,_that.numerodepart,_that.provenance,_that.destination,_that.datedepartprevue,_that.datearriveereelle,_that.demarre,_that.cloture,_that.carMatricule,_that.maRecette,_that.mesTickets,_that.mesBagages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? codevoyage,  int? numerodepart,  String? provenance,  String? destination,  DateTime? datedepartprevue,  DateTime? datearriveereelle,  bool demarre,  bool cloture,  String? carMatricule,  int maRecette,  int mesTickets,  int mesBagages)  $default,) {final _that = this;
switch (_that) {
case _VoyageHistorique():
return $default(_that.id,_that.codevoyage,_that.numerodepart,_that.provenance,_that.destination,_that.datedepartprevue,_that.datearriveereelle,_that.demarre,_that.cloture,_that.carMatricule,_that.maRecette,_that.mesTickets,_that.mesBagages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? codevoyage,  int? numerodepart,  String? provenance,  String? destination,  DateTime? datedepartprevue,  DateTime? datearriveereelle,  bool demarre,  bool cloture,  String? carMatricule,  int maRecette,  int mesTickets,  int mesBagages)?  $default,) {final _that = this;
switch (_that) {
case _VoyageHistorique() when $default != null:
return $default(_that.id,_that.codevoyage,_that.numerodepart,_that.provenance,_that.destination,_that.datedepartprevue,_that.datearriveereelle,_that.demarre,_that.cloture,_that.carMatricule,_that.maRecette,_that.mesTickets,_that.mesBagages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoyageHistorique extends VoyageHistorique {
  const _VoyageHistorique({required this.id, this.codevoyage, this.numerodepart, this.provenance, this.destination, this.datedepartprevue, this.datearriveereelle, this.demarre = false, this.cloture = false, this.carMatricule, this.maRecette = 0, this.mesTickets = 0, this.mesBagages = 0}): super._();
  factory _VoyageHistorique.fromJson(Map<String, dynamic> json) => _$VoyageHistoriqueFromJson(json);

@override final  int id;
@override final  String? codevoyage;
@override final  int? numerodepart;
@override final  String? provenance;
@override final  String? destination;
@override final  DateTime? datedepartprevue;
@override final  DateTime? datearriveereelle;
@override@JsonKey() final  bool demarre;
@override@JsonKey() final  bool cloture;
@override final  String? carMatricule;
@override@JsonKey() final  int maRecette;
@override@JsonKey() final  int mesTickets;
@override@JsonKey() final  int mesBagages;

/// Create a copy of VoyageHistorique
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoyageHistoriqueCopyWith<_VoyageHistorique> get copyWith => __$VoyageHistoriqueCopyWithImpl<_VoyageHistorique>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoyageHistoriqueToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoyageHistorique&&(identical(other.id, id) || other.id == id)&&(identical(other.codevoyage, codevoyage) || other.codevoyage == codevoyage)&&(identical(other.numerodepart, numerodepart) || other.numerodepart == numerodepart)&&(identical(other.provenance, provenance) || other.provenance == provenance)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.datedepartprevue, datedepartprevue) || other.datedepartprevue == datedepartprevue)&&(identical(other.datearriveereelle, datearriveereelle) || other.datearriveereelle == datearriveereelle)&&(identical(other.demarre, demarre) || other.demarre == demarre)&&(identical(other.cloture, cloture) || other.cloture == cloture)&&(identical(other.carMatricule, carMatricule) || other.carMatricule == carMatricule)&&(identical(other.maRecette, maRecette) || other.maRecette == maRecette)&&(identical(other.mesTickets, mesTickets) || other.mesTickets == mesTickets)&&(identical(other.mesBagages, mesBagages) || other.mesBagages == mesBagages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,codevoyage,numerodepart,provenance,destination,datedepartprevue,datearriveereelle,demarre,cloture,carMatricule,maRecette,mesTickets,mesBagages);

@override
String toString() {
  return 'VoyageHistorique(id: $id, codevoyage: $codevoyage, numerodepart: $numerodepart, provenance: $provenance, destination: $destination, datedepartprevue: $datedepartprevue, datearriveereelle: $datearriveereelle, demarre: $demarre, cloture: $cloture, carMatricule: $carMatricule, maRecette: $maRecette, mesTickets: $mesTickets, mesBagages: $mesBagages)';
}


}

/// @nodoc
abstract mixin class _$VoyageHistoriqueCopyWith<$Res> implements $VoyageHistoriqueCopyWith<$Res> {
  factory _$VoyageHistoriqueCopyWith(_VoyageHistorique value, $Res Function(_VoyageHistorique) _then) = __$VoyageHistoriqueCopyWithImpl;
@override @useResult
$Res call({
 int id, String? codevoyage, int? numerodepart, String? provenance, String? destination, DateTime? datedepartprevue, DateTime? datearriveereelle, bool demarre, bool cloture, String? carMatricule, int maRecette, int mesTickets, int mesBagages
});




}
/// @nodoc
class __$VoyageHistoriqueCopyWithImpl<$Res>
    implements _$VoyageHistoriqueCopyWith<$Res> {
  __$VoyageHistoriqueCopyWithImpl(this._self, this._then);

  final _VoyageHistorique _self;
  final $Res Function(_VoyageHistorique) _then;

/// Create a copy of VoyageHistorique
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? codevoyage = freezed,Object? numerodepart = freezed,Object? provenance = freezed,Object? destination = freezed,Object? datedepartprevue = freezed,Object? datearriveereelle = freezed,Object? demarre = null,Object? cloture = null,Object? carMatricule = freezed,Object? maRecette = null,Object? mesTickets = null,Object? mesBagages = null,}) {
  return _then(_VoyageHistorique(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,codevoyage: freezed == codevoyage ? _self.codevoyage : codevoyage // ignore: cast_nullable_to_non_nullable
as String?,numerodepart: freezed == numerodepart ? _self.numerodepart : numerodepart // ignore: cast_nullable_to_non_nullable
as int?,provenance: freezed == provenance ? _self.provenance : provenance // ignore: cast_nullable_to_non_nullable
as String?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as String?,datedepartprevue: freezed == datedepartprevue ? _self.datedepartprevue : datedepartprevue // ignore: cast_nullable_to_non_nullable
as DateTime?,datearriveereelle: freezed == datearriveereelle ? _self.datearriveereelle : datearriveereelle // ignore: cast_nullable_to_non_nullable
as DateTime?,demarre: null == demarre ? _self.demarre : demarre // ignore: cast_nullable_to_non_nullable
as bool,cloture: null == cloture ? _self.cloture : cloture // ignore: cast_nullable_to_non_nullable
as bool,carMatricule: freezed == carMatricule ? _self.carMatricule : carMatricule // ignore: cast_nullable_to_non_nullable
as String?,maRecette: null == maRecette ? _self.maRecette : maRecette // ignore: cast_nullable_to_non_nullable
as int,mesTickets: null == mesTickets ? _self.mesTickets : mesTickets // ignore: cast_nullable_to_non_nullable
as int,mesBagages: null == mesBagages ? _self.mesBagages : mesBagages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PageVoyages {

 List<VoyageHistorique> get voyages; int get page; int get parPage; int get total; int get pages;
/// Create a copy of PageVoyages
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PageVoyagesCopyWith<PageVoyages> get copyWith => _$PageVoyagesCopyWithImpl<PageVoyages>(this as PageVoyages, _$identity);

  /// Serializes this PageVoyages to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PageVoyages&&const DeepCollectionEquality().equals(other.voyages, voyages)&&(identical(other.page, page) || other.page == page)&&(identical(other.parPage, parPage) || other.parPage == parPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.pages, pages) || other.pages == pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(voyages),page,parPage,total,pages);

@override
String toString() {
  return 'PageVoyages(voyages: $voyages, page: $page, parPage: $parPage, total: $total, pages: $pages)';
}


}

/// @nodoc
abstract mixin class $PageVoyagesCopyWith<$Res>  {
  factory $PageVoyagesCopyWith(PageVoyages value, $Res Function(PageVoyages) _then) = _$PageVoyagesCopyWithImpl;
@useResult
$Res call({
 List<VoyageHistorique> voyages, int page, int parPage, int total, int pages
});




}
/// @nodoc
class _$PageVoyagesCopyWithImpl<$Res>
    implements $PageVoyagesCopyWith<$Res> {
  _$PageVoyagesCopyWithImpl(this._self, this._then);

  final PageVoyages _self;
  final $Res Function(PageVoyages) _then;

/// Create a copy of PageVoyages
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voyages = null,Object? page = null,Object? parPage = null,Object? total = null,Object? pages = null,}) {
  return _then(_self.copyWith(
voyages: null == voyages ? _self.voyages : voyages // ignore: cast_nullable_to_non_nullable
as List<VoyageHistorique>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,parPage: null == parPage ? _self.parPage : parPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PageVoyages].
extension PageVoyagesPatterns on PageVoyages {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PageVoyages value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PageVoyages() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PageVoyages value)  $default,){
final _that = this;
switch (_that) {
case _PageVoyages():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PageVoyages value)?  $default,){
final _that = this;
switch (_that) {
case _PageVoyages() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<VoyageHistorique> voyages,  int page,  int parPage,  int total,  int pages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PageVoyages() when $default != null:
return $default(_that.voyages,_that.page,_that.parPage,_that.total,_that.pages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<VoyageHistorique> voyages,  int page,  int parPage,  int total,  int pages)  $default,) {final _that = this;
switch (_that) {
case _PageVoyages():
return $default(_that.voyages,_that.page,_that.parPage,_that.total,_that.pages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<VoyageHistorique> voyages,  int page,  int parPage,  int total,  int pages)?  $default,) {final _that = this;
switch (_that) {
case _PageVoyages() when $default != null:
return $default(_that.voyages,_that.page,_that.parPage,_that.total,_that.pages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PageVoyages extends PageVoyages {
  const _PageVoyages({final  List<VoyageHistorique> voyages = const <VoyageHistorique>[], this.page = 1, this.parPage = 20, this.total = 0, this.pages = 0}): _voyages = voyages,super._();
  factory _PageVoyages.fromJson(Map<String, dynamic> json) => _$PageVoyagesFromJson(json);

 final  List<VoyageHistorique> _voyages;
@override@JsonKey() List<VoyageHistorique> get voyages {
  if (_voyages is EqualUnmodifiableListView) return _voyages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voyages);
}

@override@JsonKey() final  int page;
@override@JsonKey() final  int parPage;
@override@JsonKey() final  int total;
@override@JsonKey() final  int pages;

/// Create a copy of PageVoyages
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PageVoyagesCopyWith<_PageVoyages> get copyWith => __$PageVoyagesCopyWithImpl<_PageVoyages>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PageVoyagesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PageVoyages&&const DeepCollectionEquality().equals(other._voyages, _voyages)&&(identical(other.page, page) || other.page == page)&&(identical(other.parPage, parPage) || other.parPage == parPage)&&(identical(other.total, total) || other.total == total)&&(identical(other.pages, pages) || other.pages == pages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_voyages),page,parPage,total,pages);

@override
String toString() {
  return 'PageVoyages(voyages: $voyages, page: $page, parPage: $parPage, total: $total, pages: $pages)';
}


}

/// @nodoc
abstract mixin class _$PageVoyagesCopyWith<$Res> implements $PageVoyagesCopyWith<$Res> {
  factory _$PageVoyagesCopyWith(_PageVoyages value, $Res Function(_PageVoyages) _then) = __$PageVoyagesCopyWithImpl;
@override @useResult
$Res call({
 List<VoyageHistorique> voyages, int page, int parPage, int total, int pages
});




}
/// @nodoc
class __$PageVoyagesCopyWithImpl<$Res>
    implements _$PageVoyagesCopyWith<$Res> {
  __$PageVoyagesCopyWithImpl(this._self, this._then);

  final _PageVoyages _self;
  final $Res Function(_PageVoyages) _then;

/// Create a copy of PageVoyages
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voyages = null,Object? page = null,Object? parPage = null,Object? total = null,Object? pages = null,}) {
  return _then(_PageVoyages(
voyages: null == voyages ? _self._voyages : voyages // ignore: cast_nullable_to_non_nullable
as List<VoyageHistorique>,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,parPage: null == parPage ? _self.parPage : parPage // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pages: null == pages ? _self.pages : pages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
