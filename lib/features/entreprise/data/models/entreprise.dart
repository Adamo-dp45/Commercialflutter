import 'package:freezed_annotation/freezed_annotation.dart';

part 'entreprise.freezed.dart';
part 'entreprise.g.dart';

/// La compagnie du commercial connecté, telle que renvoyée par
/// `GET /api/me/entreprise`. Sert l'en-tête du reçu (sigle, nom, téléphones),
/// pour un billet au MÊME format que l'impression du front web.
@freezed
abstract class Entreprise with _$Entreprise {
  const Entreprise._();

  const factory Entreprise({
    String? libelle,
    String? sigle,
    String? contact1,
    String? contact2,
  }) = _Entreprise;

  factory Entreprise.fromJson(Map<String, dynamic> json) =>
      _$EntrepriseFromJson(json);

  /// Sigle affiché : celui saisi, sinon les 4 premières lettres du nom en
  /// majuscules — même repli que le template `thermalpdf.html.twig`.
  String get sigleAffiche {
    final s = sigle?.trim();
    if (s != null && s.isNotEmpty) return s;
    final l = libelle?.trim() ?? '';
    if (l.isEmpty) return 'BILLET';
    return (l.length <= 4 ? l : l.substring(0, 4)).toUpperCase();
  }

  String get nom {
    final l = libelle?.trim();
    return (l != null && l.isNotEmpty) ? l : 'Compagnie de transport';
  }

  /// « contact1 / contact2 », en ignorant les vides.
  String get telephones => [contact1, contact2]
      .map((c) => c?.trim())
      .where((c) => c != null && c.isNotEmpty)
      .join(' / ');
}
