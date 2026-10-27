// Variétés de riz proposées à la saisie (tâche P2.5).
//
// Toutes proviennent des documents FOFIFA rassemblés dans knowledge/sources :
// catalogue variétal, carte variétale et fiches de variétés. Aucune n'est
// inventée. La liste reste à trier par écosystème avec l'agronome : ici, elle
// sert seulement à écrire le même nom d'une parcelle à l'autre.
//
// « Locale ou inconnue » est le premier choix, et le choix par défaut : la
// plupart des agriculteurs sèment une variété locale sans nom de catalogue.

/// Code stocké quand l'agriculteur ne connaît pas le nom de sa variété.
const String varieteLocaleOuInconnue = 'locale_ou_inconnue';

/// Variétés nommées dans les fiches FOFIFA consultées.
const List<String> varietesNommeesFofifa = [
  'Aja-Mizesta',
  'Mahafatrosa',
  'Mangafototra',
  'Sambatra (FOFIFA 200)',
  'Soafintsanga',
  'Soary (FOFIFA 201)',
  'Vary manitra',
  'Vary mavitrika (FOFIFA 7279)',
  'Vesainky',
];

/// Numéros relevés dans le catalogue et la carte variétale.
const List<String> varietesNumeroteesFofifa = [
  'FOFIFA 133',
  'FOFIFA 134',
  'FOFIFA 154',
  'FOFIFA 159',
  'FOFIFA 160',
  'FOFIFA 161',
  'FOFIFA 167',
  'FOFIFA 168',
  'FOFIFA 169',
  'FOFIFA 170',
  'FOFIFA 171',
  'FOFIFA 172',
  'FOFIFA 173',
  'FOFIFA 174',
  'FOFIFA 175',
  'FOFIFA 176',
  'FOFIFA 177',
  'FOFIFA 178',
  'FOFIFA 179',
  'FOFIFA 180',
  'FOFIFA 181',
  'FOFIFA 182',
  'FOFIFA 183',
  'FOFIFA 184',
  'FOFIFA 185',
  'FOFIFA 186',
  'FOFIFA 7255',
  'X243',
  'X265',
  'X360',
  'X372',
  'X398',
  'X915',
  'X1648',
];

/// Liste complète proposée dans le formulaire, dans l'ordre d'affichage.
const List<String> varietesRiz = [
  ...varietesNommeesFofifa,
  ...varietesNumeroteesFofifa,
];
