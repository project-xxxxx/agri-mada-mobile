/// Lit un nombre décimal saisi avec une virgule ou un point (« 0,55 » ou « 0.55 »).
///
/// Les claviers en français et en malgache proposent la virgule : `double.tryParse`
/// seul la refuse et la valeur était perdue sans message (tâche P1.6).
/// Renvoie null pour une saisie vide, invalide ou négative.
double? parseLocalizedDecimal(String input) {
  final normalized =
      input.trim().replaceAll(RegExp(r'\s'), '').replaceAll(',', '.');
  if (normalized.isEmpty) return null;

  final value = double.tryParse(normalized);
  if (value == null || value.isNaN || value.isInfinite || value < 0) {
    return null;
  }
  return value;
}

/// Surface saisie en hectares ou en ares, toujours rendue en hectares
/// (tâche P2.5). Beaucoup de parcelles font quelques ares : « 0,05 ha » est
/// pénible à écrire et facile à rater d'un facteur dix.
double? parseSurfaceEnHectares(String input, {required bool enAres}) {
  final valeur = parseLocalizedDecimal(input);
  if (valeur == null) return null;
  return enAres ? valeur / 100 : valeur;
}
