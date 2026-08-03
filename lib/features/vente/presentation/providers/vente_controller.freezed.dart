// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vente_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VenteState {

 VoyageCommercial? get voyage; VenteStep get step; Arret? get descente; List<Siege> get sieges; bool get loadingSieges; Siege? get siege; int? get tarif; String get nom; String get contact; String get remiseType; int get remiseValeur; bool get submitting; String? get error; TicketVendu? get ticket;
/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VenteStateCopyWith<VenteState> get copyWith => _$VenteStateCopyWithImpl<VenteState>(this as VenteState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VenteState&&(identical(other.voyage, voyage) || other.voyage == voyage)&&(identical(other.step, step) || other.step == step)&&(identical(other.descente, descente) || other.descente == descente)&&const DeepCollectionEquality().equals(other.sieges, sieges)&&(identical(other.loadingSieges, loadingSieges) || other.loadingSieges == loadingSieges)&&(identical(other.siege, siege) || other.siege == siege)&&(identical(other.tarif, tarif) || other.tarif == tarif)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.remiseType, remiseType) || other.remiseType == remiseType)&&(identical(other.remiseValeur, remiseValeur) || other.remiseValeur == remiseValeur)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.error, error) || other.error == error)&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,voyage,step,descente,const DeepCollectionEquality().hash(sieges),loadingSieges,siege,tarif,nom,contact,remiseType,remiseValeur,submitting,error,ticket);

@override
String toString() {
  return 'VenteState(voyage: $voyage, step: $step, descente: $descente, sieges: $sieges, loadingSieges: $loadingSieges, siege: $siege, tarif: $tarif, nom: $nom, contact: $contact, remiseType: $remiseType, remiseValeur: $remiseValeur, submitting: $submitting, error: $error, ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class $VenteStateCopyWith<$Res>  {
  factory $VenteStateCopyWith(VenteState value, $Res Function(VenteState) _then) = _$VenteStateCopyWithImpl;
@useResult
$Res call({
 VoyageCommercial? voyage, VenteStep step, Arret? descente, List<Siege> sieges, bool loadingSieges, Siege? siege, int? tarif, String nom, String contact, String remiseType, int remiseValeur, bool submitting, String? error, TicketVendu? ticket
});


$VoyageCommercialCopyWith<$Res>? get voyage;$ArretCopyWith<$Res>? get descente;$SiegeCopyWith<$Res>? get siege;$TicketVenduCopyWith<$Res>? get ticket;

}
/// @nodoc
class _$VenteStateCopyWithImpl<$Res>
    implements $VenteStateCopyWith<$Res> {
  _$VenteStateCopyWithImpl(this._self, this._then);

  final VenteState _self;
  final $Res Function(VenteState) _then;

/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? voyage = freezed,Object? step = null,Object? descente = freezed,Object? sieges = null,Object? loadingSieges = null,Object? siege = freezed,Object? tarif = freezed,Object? nom = null,Object? contact = null,Object? remiseType = null,Object? remiseValeur = null,Object? submitting = null,Object? error = freezed,Object? ticket = freezed,}) {
  return _then(_self.copyWith(
voyage: freezed == voyage ? _self.voyage : voyage // ignore: cast_nullable_to_non_nullable
as VoyageCommercial?,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VenteStep,descente: freezed == descente ? _self.descente : descente // ignore: cast_nullable_to_non_nullable
as Arret?,sieges: null == sieges ? _self.sieges : sieges // ignore: cast_nullable_to_non_nullable
as List<Siege>,loadingSieges: null == loadingSieges ? _self.loadingSieges : loadingSieges // ignore: cast_nullable_to_non_nullable
as bool,siege: freezed == siege ? _self.siege : siege // ignore: cast_nullable_to_non_nullable
as Siege?,tarif: freezed == tarif ? _self.tarif : tarif // ignore: cast_nullable_to_non_nullable
as int?,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as String,remiseType: null == remiseType ? _self.remiseType : remiseType // ignore: cast_nullable_to_non_nullable
as String,remiseValeur: null == remiseValeur ? _self.remiseValeur : remiseValeur // ignore: cast_nullable_to_non_nullable
as int,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as TicketVendu?,
  ));
}
/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoyageCommercialCopyWith<$Res>? get voyage {
    if (_self.voyage == null) {
    return null;
  }

  return $VoyageCommercialCopyWith<$Res>(_self.voyage!, (value) {
    return _then(_self.copyWith(voyage: value));
  });
}/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArretCopyWith<$Res>? get descente {
    if (_self.descente == null) {
    return null;
  }

  return $ArretCopyWith<$Res>(_self.descente!, (value) {
    return _then(_self.copyWith(descente: value));
  });
}/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiegeCopyWith<$Res>? get siege {
    if (_self.siege == null) {
    return null;
  }

  return $SiegeCopyWith<$Res>(_self.siege!, (value) {
    return _then(_self.copyWith(siege: value));
  });
}/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TicketVenduCopyWith<$Res>? get ticket {
    if (_self.ticket == null) {
    return null;
  }

  return $TicketVenduCopyWith<$Res>(_self.ticket!, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}


/// Adds pattern-matching-related methods to [VenteState].
extension VenteStatePatterns on VenteState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VenteState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VenteState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VenteState value)  $default,){
final _that = this;
switch (_that) {
case _VenteState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VenteState value)?  $default,){
final _that = this;
switch (_that) {
case _VenteState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VoyageCommercial? voyage,  VenteStep step,  Arret? descente,  List<Siege> sieges,  bool loadingSieges,  Siege? siege,  int? tarif,  String nom,  String contact,  String remiseType,  int remiseValeur,  bool submitting,  String? error,  TicketVendu? ticket)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VenteState() when $default != null:
return $default(_that.voyage,_that.step,_that.descente,_that.sieges,_that.loadingSieges,_that.siege,_that.tarif,_that.nom,_that.contact,_that.remiseType,_that.remiseValeur,_that.submitting,_that.error,_that.ticket);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VoyageCommercial? voyage,  VenteStep step,  Arret? descente,  List<Siege> sieges,  bool loadingSieges,  Siege? siege,  int? tarif,  String nom,  String contact,  String remiseType,  int remiseValeur,  bool submitting,  String? error,  TicketVendu? ticket)  $default,) {final _that = this;
switch (_that) {
case _VenteState():
return $default(_that.voyage,_that.step,_that.descente,_that.sieges,_that.loadingSieges,_that.siege,_that.tarif,_that.nom,_that.contact,_that.remiseType,_that.remiseValeur,_that.submitting,_that.error,_that.ticket);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VoyageCommercial? voyage,  VenteStep step,  Arret? descente,  List<Siege> sieges,  bool loadingSieges,  Siege? siege,  int? tarif,  String nom,  String contact,  String remiseType,  int remiseValeur,  bool submitting,  String? error,  TicketVendu? ticket)?  $default,) {final _that = this;
switch (_that) {
case _VenteState() when $default != null:
return $default(_that.voyage,_that.step,_that.descente,_that.sieges,_that.loadingSieges,_that.siege,_that.tarif,_that.nom,_that.contact,_that.remiseType,_that.remiseValeur,_that.submitting,_that.error,_that.ticket);case _:
  return null;

}
}

}

/// @nodoc


class _VenteState extends VenteState {
  const _VenteState({this.voyage, this.step = VenteStep.descente, this.descente, final  List<Siege> sieges = const <Siege>[], this.loadingSieges = false, this.siege, this.tarif, this.nom = '', this.contact = '', this.remiseType = 'AUCUNE', this.remiseValeur = 0, this.submitting = false, this.error, this.ticket}): _sieges = sieges,super._();
  

@override final  VoyageCommercial? voyage;
@override@JsonKey() final  VenteStep step;
@override final  Arret? descente;
 final  List<Siege> _sieges;
@override@JsonKey() List<Siege> get sieges {
  if (_sieges is EqualUnmodifiableListView) return _sieges;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sieges);
}

@override@JsonKey() final  bool loadingSieges;
@override final  Siege? siege;
@override final  int? tarif;
@override@JsonKey() final  String nom;
@override@JsonKey() final  String contact;
@override@JsonKey() final  String remiseType;
@override@JsonKey() final  int remiseValeur;
@override@JsonKey() final  bool submitting;
@override final  String? error;
@override final  TicketVendu? ticket;

/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VenteStateCopyWith<_VenteState> get copyWith => __$VenteStateCopyWithImpl<_VenteState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VenteState&&(identical(other.voyage, voyage) || other.voyage == voyage)&&(identical(other.step, step) || other.step == step)&&(identical(other.descente, descente) || other.descente == descente)&&const DeepCollectionEquality().equals(other._sieges, _sieges)&&(identical(other.loadingSieges, loadingSieges) || other.loadingSieges == loadingSieges)&&(identical(other.siege, siege) || other.siege == siege)&&(identical(other.tarif, tarif) || other.tarif == tarif)&&(identical(other.nom, nom) || other.nom == nom)&&(identical(other.contact, contact) || other.contact == contact)&&(identical(other.remiseType, remiseType) || other.remiseType == remiseType)&&(identical(other.remiseValeur, remiseValeur) || other.remiseValeur == remiseValeur)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.error, error) || other.error == error)&&(identical(other.ticket, ticket) || other.ticket == ticket));
}


@override
int get hashCode => Object.hash(runtimeType,voyage,step,descente,const DeepCollectionEquality().hash(_sieges),loadingSieges,siege,tarif,nom,contact,remiseType,remiseValeur,submitting,error,ticket);

@override
String toString() {
  return 'VenteState(voyage: $voyage, step: $step, descente: $descente, sieges: $sieges, loadingSieges: $loadingSieges, siege: $siege, tarif: $tarif, nom: $nom, contact: $contact, remiseType: $remiseType, remiseValeur: $remiseValeur, submitting: $submitting, error: $error, ticket: $ticket)';
}


}

/// @nodoc
abstract mixin class _$VenteStateCopyWith<$Res> implements $VenteStateCopyWith<$Res> {
  factory _$VenteStateCopyWith(_VenteState value, $Res Function(_VenteState) _then) = __$VenteStateCopyWithImpl;
@override @useResult
$Res call({
 VoyageCommercial? voyage, VenteStep step, Arret? descente, List<Siege> sieges, bool loadingSieges, Siege? siege, int? tarif, String nom, String contact, String remiseType, int remiseValeur, bool submitting, String? error, TicketVendu? ticket
});


@override $VoyageCommercialCopyWith<$Res>? get voyage;@override $ArretCopyWith<$Res>? get descente;@override $SiegeCopyWith<$Res>? get siege;@override $TicketVenduCopyWith<$Res>? get ticket;

}
/// @nodoc
class __$VenteStateCopyWithImpl<$Res>
    implements _$VenteStateCopyWith<$Res> {
  __$VenteStateCopyWithImpl(this._self, this._then);

  final _VenteState _self;
  final $Res Function(_VenteState) _then;

/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? voyage = freezed,Object? step = null,Object? descente = freezed,Object? sieges = null,Object? loadingSieges = null,Object? siege = freezed,Object? tarif = freezed,Object? nom = null,Object? contact = null,Object? remiseType = null,Object? remiseValeur = null,Object? submitting = null,Object? error = freezed,Object? ticket = freezed,}) {
  return _then(_VenteState(
voyage: freezed == voyage ? _self.voyage : voyage // ignore: cast_nullable_to_non_nullable
as VoyageCommercial?,step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as VenteStep,descente: freezed == descente ? _self.descente : descente // ignore: cast_nullable_to_non_nullable
as Arret?,sieges: null == sieges ? _self._sieges : sieges // ignore: cast_nullable_to_non_nullable
as List<Siege>,loadingSieges: null == loadingSieges ? _self.loadingSieges : loadingSieges // ignore: cast_nullable_to_non_nullable
as bool,siege: freezed == siege ? _self.siege : siege // ignore: cast_nullable_to_non_nullable
as Siege?,tarif: freezed == tarif ? _self.tarif : tarif // ignore: cast_nullable_to_non_nullable
as int?,nom: null == nom ? _self.nom : nom // ignore: cast_nullable_to_non_nullable
as String,contact: null == contact ? _self.contact : contact // ignore: cast_nullable_to_non_nullable
as String,remiseType: null == remiseType ? _self.remiseType : remiseType // ignore: cast_nullable_to_non_nullable
as String,remiseValeur: null == remiseValeur ? _self.remiseValeur : remiseValeur // ignore: cast_nullable_to_non_nullable
as int,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,ticket: freezed == ticket ? _self.ticket : ticket // ignore: cast_nullable_to_non_nullable
as TicketVendu?,
  ));
}

/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoyageCommercialCopyWith<$Res>? get voyage {
    if (_self.voyage == null) {
    return null;
  }

  return $VoyageCommercialCopyWith<$Res>(_self.voyage!, (value) {
    return _then(_self.copyWith(voyage: value));
  });
}/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ArretCopyWith<$Res>? get descente {
    if (_self.descente == null) {
    return null;
  }

  return $ArretCopyWith<$Res>(_self.descente!, (value) {
    return _then(_self.copyWith(descente: value));
  });
}/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SiegeCopyWith<$Res>? get siege {
    if (_self.siege == null) {
    return null;
  }

  return $SiegeCopyWith<$Res>(_self.siege!, (value) {
    return _then(_self.copyWith(siege: value));
  });
}/// Create a copy of VenteState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TicketVenduCopyWith<$Res>? get ticket {
    if (_self.ticket == null) {
    return null;
  }

  return $TicketVenduCopyWith<$Res>(_self.ticket!, (value) {
    return _then(_self.copyWith(ticket: value));
  });
}
}

// dart format on
