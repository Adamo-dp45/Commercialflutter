/// Résultat minimal d'une création de bagage (`POST /api/bagages`) : de quoi
/// éditer le reçu en le combinant au contexte du billet (client, trajet).
typedef BagageCree = ({String codebagage, int montant, bool montantForce});

/// Extrait un [BagageCree] de la réponse JSON (format `read:Bagage`).
BagageCree bagageCreeFromJson(dynamic data) {
  final map = data is Map ? data : const {};
  return (
    codebagage: (map['codebagage'] as String?) ?? '',
    montant: (map['montant'] as num?)?.toInt() ?? 0,
    montantForce: (map['montantforce'] as bool?) ?? false,
  );
}
