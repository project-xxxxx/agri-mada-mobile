import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:agri_mada/app/router.dart';

void main() {
  // Régression : la liste des parcelles ouvrait '/parcelle/:id/5', qu'aucune
  // route ne reconnaît (page « not found »).
  Future<void> ouvrir(WidgetTester tester, String chemin) async {
    final router = GoRouter(
      initialLocation: chemin,
      routes: [
        GoRoute(
          path: AppRoutes.parcelleDetail,
          builder: (context, state) => Text('parcelle ${state.pathParameters['id']}'),
        ),
        GoRoute(
          path: AppRoutes.scanDetail,
          builder: (context, state) => Text('scan ${state.pathParameters['id']}'),
        ),
      ],
      errorBuilder: (context, state) => const Text('introuvable'),
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  testWidgets('le chemin d\'une parcelle ouvre bien la route de détail', (tester) async {
    await ouvrir(tester, AppRoutes.parcelleDetailPath(5));

    expect(find.text('parcelle 5'), findsOneWidget);
  });

  testWidgets('le chemin d\'un scan passé ouvre bien la route de détail', (tester) async {
    await ouvrir(tester, AppRoutes.scanDetailPath(42));

    expect(find.text('scan 42'), findsOneWidget);
  });

  testWidgets('coller un identifiant au motif ne mène nulle part', (tester) async {
    await ouvrir(tester, '${AppRoutes.parcelleDetail}/5');

    expect(find.text('introuvable'), findsOneWidget);
  });
}
