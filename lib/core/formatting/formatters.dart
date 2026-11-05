import 'package:intl/intl.dart';

/// Formatage localisé (fr) des montants et dates, centralisé pour l'app.
class Formatters {
  const Formatters._();

  static final NumberFormat _amount = NumberFormat.decimalPattern('fr');
  static final DateFormat _dayTime = DateFormat('EEE d MMM · HH:mm', 'fr_FR');
  static final DateFormat _day = DateFormat('EEEE d MMMM y', 'fr_FR');
  static final DateFormat _dayShort = DateFormat('d MMM y', 'fr_FR');
  static final DateFormat _time = DateFormat('HH:mm', 'fr_FR');

  /// Date pour l'API (`2026-11-04`) — jamais localisée.
  ///
  /// SANS FUSEAU : le serveur reçoit un JOUR, qu'il borne lui-même du premier au
  /// dernier instant. Envoyer un instant ISO ferait décider la borne par le
  /// décalage du téléphone, et la même journée ne commencerait pas au même
  /// moment selon l'appareil.
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');

  /// Montant en francs CFA, ex. `5 000 FCFA`.
  static String money(int? amount) {
    if (amount == null) return '—';
    return '${_amount.format(amount)} FCFA';
  }

  /// Nombre simple, ex. `1 250`.
  static String number(num? value) {
    if (value == null) return '—';
    return _amount.format(value);
  }

  /// Date + heure courte, ex. `lun. 14 juil. · 08:30`.
  static String dateTime(DateTime? date) {
    if (date == null) return '—';
    return _dayTime.format(date.toLocal());
  }

  /// Date longue, ex. `lundi 14 juillet 2026`.
  static String dateLong(DateTime? date) {
    if (date == null) return '—';
    return _day.format(date.toLocal());
  }

  /// Date courte, ex. `4 nov. 2026` — pour les bornes d'une période.
  static String dateCourte(DateTime? date) {
    if (date == null) return '—';
    return _dayShort.format(date.toLocal());
  }

  /// Heure seule, ex. `08:30`.
  static String time(DateTime? date) {
    if (date == null) return '—';
    return _time.format(date.toLocal());
  }

  /// Date au format attendu par l'API, ex. `2026-11-04`.
  static String dateApi(DateTime date) => _iso.format(date);
}
