// Fournit les fiches de connaissance à l'écran Guides (tâche P5.3).

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/fiche_repository.dart';
import '../../domain/entities/fiche.dart';

final ficheRepositoryProvider = Provider<FicheRepository>((ref) => const FicheRepository());

/// Chargées une seule fois : le bundle est un asset statique, jamais modifié
/// pendant l'exécution.
final fichesProvider = FutureProvider<List<Fiche>>(
  (ref) => ref.watch(ficheRepositoryProvider).chargerToutes(),
);
