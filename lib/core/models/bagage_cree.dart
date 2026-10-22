/// Résultat minimal d'une création de bagage (`POST /api/bagages`) : de quoi
/// éditer le reçu en le combinant au contexte du billet (client, trajet).
///
/// `id` est l'identifiant SERVEUR, et il est nul après une création hors ligne : le bagage n'a
/// alors que son code, définitif, et attend dans la file de synchronisation. C'est lui qui permet
/// de demander le reçu à l'API (`GET /api/bagages/{id}/print`) plutôt que de le composer ici ;
/// sans lui, on retombe sur le rendu local, qui est le repli hors-ligne.
typedef BagageCree = ({String codebagage, int montant, bool montantForce, int? id});

/// Extrait un [BagageCree] de la réponse JSON (format `read:Bagage`).
BagageCree bagageCreeFromJson(dynamic data) {
  final map = data is Map ? data : const {};
  return (
    codebagage: (map['codebagage'] as String?) ?? '',
    montant: (map['montant'] as num?)?.toInt() ?? 0,
    montantForce: (map['montantforce'] as bool?) ?? false,
    id: (map['id'] as num?)?.toInt(),
  );
}
