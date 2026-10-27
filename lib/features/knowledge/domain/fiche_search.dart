// Recherche plein texte dans les fiches, avec synonymes malgaches (tâche
// P5.3) : « menalavitra » retrouve la pyriculariose et inversement, puisque
// la recherche porte sur noms.fr, noms.mg, noms.autres_noms_mg et les
// symptômes déclarés par organe.
//
// La comparaison ignore les accents : sur un clavier de téléphone, personne
// ne tape « flétrissement » ou « échaudure » avec leurs accents.

import 'entities/fiche.dart';

const _lettresAccentuees = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
const _lettresSimples = 'aaaaaaceeeeiiiinooooouuuuyy';

List<Fiche> rechercherFiches(List<Fiche> fiches, String requete) {
  final motsClefs = _normaliser(requete.trim());
  if (motsClefs.isEmpty) return fiches;
  return fiches.where((fiche) => _correspond(fiche, motsClefs)).toList();
}

String _normaliser(String texte) {
  final tampon = StringBuffer();
  for (final rune in texte.toLowerCase().runes) {
    final caractere = String.fromCharCode(rune);
    final position = _lettresAccentuees.indexOf(caractere);
    tampon.write(position == -1 ? caractere : _lettresSimples[position]);
  }
  return tampon.toString();
}

bool _contient(String? texte, String motsClefs) =>
    texte != null && _normaliser(texte).contains(motsClefs);

bool _correspond(Fiche fiche, String motsClefs) {
  if (_contient(fiche.noms.fr, motsClefs)) return true;
  if (_contient(fiche.noms.mg, motsClefs)) return true;
  if (fiche.noms.autresNomsMg.any((nom) => _contient(nom, motsClefs))) return true;
  if (_contient(fiche.noms.sci, motsClefs)) return true;
  for (final symptomes in fiche.organes.values) {
    if (symptomes.any((symptome) => _contient(symptome, motsClefs))) return true;
  }
  return false;
}
