import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agri_mada/core/widgets/app_button/app_button.dart';

void main() {
  group('AppButton', () {
    testWidgets('affiche le label passé en props', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Valider', onPressed: null),
          ),
        ),
      );

      // Assert
      expect(find.text('Valider'), findsOneWidget);
    });

    testWidgets('appelle onPressed une seule fois au tap', (tester) async {
      // Arrange
      var callCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Valider', onPressed: () => callCount++),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(callCount, 1);
    });

    testWidgets('est désactivé quand onPressed est null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Valider', onPressed: null),
          ),
        ),
      );

      // Assert
      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('affiche un loader et cache le label quand isLoading=true',
        (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Valider', onPressed: null, isLoading: true),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Valider'), findsNothing);
    });

    testWidgets('bouton secondaire utilise la variante secondary', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: 'Se connecter',
              onPressed: null,
              variant: AppButtonVariant.secondary,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
    });
  });
}
