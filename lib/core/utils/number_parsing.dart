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
