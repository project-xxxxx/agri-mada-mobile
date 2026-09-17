# Copilot Instructions — Flutter / Dart

> Ces instructions s'appliquent à **tout** le code généré ou suggéré par GitHub Copilot.
> Elles ont priorité sur les comportements par défaut de Copilot.

---

## 🏗️ Stack

| Rôle | Package |
|---|---|
| Framework | Flutter 3.x — stable channel |
| Langage | Dart 3.x — sound null safety strict |
| State | Riverpod 2.x avec code generation (`@riverpod`) |
| Navigation | GoRouter |
| Réseau | Dio + Retrofit |
| Sérialisation | `json_serializable` + `freezed` |
| Tests unitaires & widget | `flutter_test` + `mocktail` |
| Tests e2e | `patrol` |
| Linting | `flutter_lints` + `analysis_options.yaml` strict |
| Design | Figma MCP (`get_design_context`, `get_variable_defs`) |

---

## 📁 Structure — feature-first, Clean Architecture

```
lib/
├── main.dart
├── app/
│   ├── app.dart                        # MaterialApp / CupertinoApp racine
│   ├── router.dart                     # Toutes les routes GoRouter
│   └── theme/
│       ├── app_theme.dart              # ThemeData assemblé
│       ├── app_colors.dart             # Toutes les couleurs (jamais inline)
│       ├── app_typography.dart         # TextStyles nommés
│       └── app_spacing.dart            # Constantes d'espacement
│
├── core/
│   ├── constants/
│   │   ├── api_constants.dart
│   │   └── app_constants.dart
│   ├── errors/
│   │   ├── failure.dart                # Sealed class Failure
│   │   └── app_exception.dart
│   ├── extensions/
│   │   ├── build_context_extensions.dart
│   │   ├── string_extensions.dart
│   │   └── datetime_extensions.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   └── logger.dart                 # Wrapper logger (jamais print())
│   └── widgets/                        # Widgets atomiques partagés
│       ├── app_button/
│       │   ├── app_button.dart
│       │   └── app_button_test.dart    # Colocalisé avec le widget
│       ├── app_text_field/
│       │   ├── app_text_field.dart
│       │   └── app_text_field_test.dart
│       └── app_loading_indicator/
│           └── app_loading_indicator.dart
│
├── features/
│   └── [feature]/                      # ex: auth, products, profile
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── [feature]_remote_datasource.dart
│       │   │   ├── [feature]_remote_datasource_test.dart
│       │   │   ├── [feature]_local_datasource.dart
│       │   │   └── [feature]_local_datasource_test.dart
│       │   ├── models/
│       │   │   ├── [feature]_model.dart         # @JsonSerializable
│       │   │   └── [feature]_model_test.dart    # Test fromJson/toJson
│       │   └── repositories/
│       │       ├── [feature]_repository_impl.dart
│       │       └── [feature]_repository_impl_test.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   └── [feature]_entity.dart        # @freezed, pas de dépendance Flutter
│       │   ├── repositories/
│       │   │   └── [feature]_repository.dart    # Abstract uniquement
│       │   └── usecases/
│       │       ├── get_[feature]_usecase.dart
│       │       └── get_[feature]_usecase_test.dart
│       └── presentation/
│           ├── providers/
│           │   ├── [feature]_provider.dart
│           │   └── [feature]_provider_test.dart
│           ├── screens/
│           │   ├── [feature]_screen.dart
│           │   └── [feature]_screen_test.dart
│           └── widgets/
│               ├── [feature]_card.dart
│               └── [feature]_card_test.dart
│
integration_test/
└── [feature]_flow_test.dart            # Tests Patrol e2e
```

### Règles de nommage — non négociables

| Élément | Convention | Exemple |
|---|---|---|
| Fichiers | `snake_case` | `user_profile_screen.dart` |
| Classes | `PascalCase` | `UserProfileScreen` |
| Variables / méthodes | `camelCase` | `fetchUserData()` |
| Constantes de classe | `camelCase` statique | `AppColors.primary` |
| Providers | suffixe `Provider` | `userProfileProvider` |
| Notifiers | suffixe `Notifier` | `AuthNotifier` |
| Use cases | verbe + entité + `UseCase` | `GetUserUseCase` |
| Mocks (test) | préfixe `Mock` | `MockAuthRepository` |
| États (freezed) | suffixe `State` | `AuthState` |

---

## 🧹 Clean Code — règles strictes

### 1. Architecture en couches

```
Presentation  →  Domain  ←  Data
```

- **Domain** : zéro import Flutter, zéro import Dio. Dart pur uniquement.
- **Data** : implémente les abstractions du domain, gère la sérialisation et les exceptions réseau.
- **Presentation** : consomme les use cases via Riverpod. Aucune logique métier.

### 2. Null safety

```dart
// ✅ Laisser le compilateur guider
final String name = user.name;

// ✅ Null check explicite avec pattern matching Dart 3
if (user.avatarUrl case final url?) {
  return NetworkImage(url);
}

// ✅ Switch exhaustif sur les états freezed
switch (state) {
  case AuthState.authenticated(:final user): return HomeScreen(user: user);
  case AuthState.loading():                  return const AppLoadingIndicator();
  case AuthState.error(:final message):      return AppErrorWidget(message: message);
  default:                                   return const LoginScreen();
}

// ❌ Jamais
final name = user.name!;            // Bang sans justification
final data = response as Map;       // Cast aveugle
void doSomething(dynamic value) {}  // dynamic interdit
```

### 3. Entités et états — toujours `freezed`

```dart
// ✅ Entité domain
@freezed
class ProductEntity with _$ProductEntity {
  const factory ProductEntity({
    required String id,
    required String name,
    required double price,
    String? imageUrl,
    @Default(false) bool isFavorite,
  }) = _ProductEntity;
}

// ✅ État UI exhaustif — tous les cas obligatoires
@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial()                         = _Initial;
  const factory ProductState.loading()                         = _Loading;
  const factory ProductState.loaded(List<ProductEntity> items) = _Loaded;
  const factory ProductState.empty()                           = _Empty;
  const factory ProductState.error(Failure failure)            = _Error;
}
```

### 4. Gestion des erreurs

```dart
// ✅ Failures typées dans le domain (sealed class Dart 3)
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NetworkFailure    extends Failure { const NetworkFailure(super.message); }
final class CacheFailure      extends Failure { const CacheFailure(super.message); }
final class NotFoundFailure   extends Failure { const NotFoundFailure(super.message); }
final class ValidationFailure extends Failure { const ValidationFailure(super.message); }

// ✅ Try/catch UNIQUEMENT dans la couche datasource
Future<ProductModel> fetchProduct(String id) async {
  try {
    final response = await _dio.get('/products/$id');
    return ProductModel.fromJson(response.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw NetworkException.fromDioError(e);
  } on FormatException catch (e) {
    throw ParseException(e.message);
  }
}

// ✅ Either<Failure, T> dans les repositories
Future<Either<Failure, ProductEntity>> getProduct(String id) async {
  try {
    final model = await _remote.fetchProduct(id);
    return Right(model.toEntity());
  } on NetworkException catch (e) {
    return Left(NetworkFailure(e.message));
  }
}
```

### 5. Widgets — règles de découpe

```dart
// ✅ ConsumerWidget par défaut, StatefulWidget en dernier recours
class ProductCard extends ConsumerWidget {
  const ProductCard({required this.productId, super.key});
  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productProvider(productId));

    // ✅ Early return pour chaque état
    if (product == null) return const ProductCardSkeleton();

    return _ProductCardContent(product: product);
  }
}

// ✅ Sous-widget privé = classe séparée, jamais une méthode _buildXxx()
class _ProductCardContent extends StatelessWidget {
  const _ProductCardContent({required this.product});
  final ProductEntity product;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(children: [
      _ProductImage(imageUrl: product.imageUrl),
      _ProductInfo(name: product.name, price: product.price),
    ]),
  );
}

// ✅ const partout, tokens de design obligatoires
const SizedBox(height: AppSpacing.md)                   // ✅
SizedBox(height: 16)                                    // ❌ magic number
color: AppColors.primary                                // ✅
color: const Color(0xFF6366F1)                          // ❌ inline
```

### 6. Providers Riverpod

```dart
// ✅ Code generation @riverpod sur tout
@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  @override
  ProductState build() => const ProductState.initial();

  Future<void> loadProducts() async {
    state = const ProductState.loading();

    final result = await ref.read(getProductsUseCaseProvider).call();

    state = result.fold(
      (failure) => ProductState.error(failure),
      (items)   => items.isEmpty
          ? const ProductState.empty()
          : ProductState.loaded(items),
    );
  }
}
```

### 7. Logging — jamais `print()`

```dart
AppLogger.debug('Product loaded: ${product.id}');
AppLogger.error('Failed to fetch', error: e, stackTrace: st);
// ❌ print(), debugPrint() interdits hors dev local
```

---

## 🧪 Tests — règles strictes

### Philosophie

> **"Test behavior, not implementation."**
> Un test vérifie ce que l'utilisateur voit ou ce que le système produit — pas les appels internes.

### Règles non négociables

- Tout fichier `.dart` dans `lib/` a son `_test.dart` correspondant
- Toute modification de comportement, correction de bug ou nouvelle feature doit inclure au moins un test adapté dans le même lot de travail
- Aucun travail n'est considéré terminé tant que les tests ciblés du périmètre modifié n'ont pas été exécutés et passés, ou qu'une impossibilité n'a pas été explicitement justifiée
- Tests de widget **colocalisés** avec le widget dans `lib/`
- Tests domain/data en miroir dans `test/`
- Couverture minimum **80%** sur `domain/` et `presentation/providers/`
- `test.skip` interdit sans `// TODO(author): raison — YYYY-MM-DD`
- Nommer les tests comme des phrases lisibles en français

### Ordre de travail obligatoire

1. Identifier le test le plus proche du comportement à modifier
2. Créer ou adapter ce test avant de considérer l'implémentation comme terminée
3. Implémenter le changement minimal nécessaire
4. Exécuter d'abord la validation la plus ciblée possible sur le périmètre modifié
5. N'élargir à `dart analyze`, `flutter test --coverage` ou au run manuel qu'après succès de la validation ciblée

Si aucun test automatisé n'est raisonnablement possible, il faut documenter pourquoi et exécuter au minimum une validation exécutable alternative adaptée au périmètre touché.

### Pattern obligatoire — AAA

```dart
test('description lisible du comportement attendu', () async {
  // Arrange
  // Act
  // Assert
});
```

### Test unitaire — Use case

```dart
// test/features/products/domain/usecases/get_product_usecase_test.dart
class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late GetProductUseCase useCase;
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
    useCase  = GetProductUseCase(mockRepo);
  });

  group('GetProductUseCase', () {
    const tId      = 'product-123';
    const tProduct = ProductEntity(id: tId, name: 'Test', price: 29.99);

    test('retourne un ProductEntity quand le repository répond avec succès', () async {
      // Arrange
      when(() => mockRepo.getProduct(tId))
          .thenAnswer((_) async => const Right(tProduct));

      // Act
      final result = await useCase(tId);

      // Assert
      expect(result, const Right(tProduct));
      verify(() => mockRepo.getProduct(tId)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('retourne un NetworkFailure quand le réseau est indisponible', () async {
      // Arrange
      when(() => mockRepo.getProduct(any()))
          .thenAnswer((_) async => const Left(NetworkFailure('No connection')));

      // Act
      final result = await useCase(tId);

      // Assert
      expect(result, const Left(NetworkFailure('No connection')));
    });

    test('retourne un NotFoundFailure quand le produit n\'existe pas', () async {
      // Arrange
      when(() => mockRepo.getProduct(any()))
          .thenAnswer((_) async => const Left(NotFoundFailure('Not found')));

      // Act
      final result = await useCase(tId);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<NotFoundFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });
}
```

### Test modèle — JSON serialization

```dart
void main() {
  group('ProductModel', () {
    const tJson    = {'id': 'p-1', 'name': 'Test', 'price': 29.99, 'image_url': null};
    const tModel   = ProductModel(id: 'p-1', name: 'Test', price: 29.99);

    test('fromJson crée un ProductModel valide', () {
      expect(ProductModel.fromJson(tJson), tModel);
    });

    test('toJson produit la Map attendue', () {
      final json = tModel.toJson();
      expect(json['id'],    'p-1');
      expect(json['price'], 29.99);
    });

    test('toEntity retourne un ProductEntity cohérent', () {
      final entity = tModel.toEntity();
      expect(entity.id,    tModel.id);
      expect(entity.price, tModel.price);
    });
  });
}
```

### Test de widget

```dart
// lib/core/widgets/app_button/app_button_test.dart
void main() {
  group('AppButton', () {
    testWidgets('affiche le label passé en props', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(
          body: AppButton(label: 'Valider', onPressed: null),
        )),
      );
      // Assert
      expect(find.text('Valider'), findsOneWidget);
    });

    testWidgets('appelle onPressed une seule fois au tap', (tester) async {
      // Arrange
      var callCount = 0;
      await tester.pumpWidget(MaterialApp(home: Scaffold(
        body: AppButton(label: 'Valider', onPressed: () => callCount++),
      )));

      // Act
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      expect(callCount, 1);
    });

    testWidgets('est désactivé quand onPressed est null', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(
        body: AppButton(label: 'Valider', onPressed: null),
      )));

      final btn = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(btn.onPressed, isNull);
    });

    testWidgets('affiche un loader et cache le label quand isLoading=true', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(
        body: AppButton(label: 'Valider', onPressed: null, isLoading: true),
      )));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Valider'), findsNothing);
    });
  });
}
```

### Test de provider Riverpod

```dart
void main() {
  group('ProductsNotifier', () {
    late ProviderContainer container;
    late MockGetProductsUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockGetProductsUseCase();
      container   = ProviderContainer(overrides: [
        getProductsUseCaseProvider.overrideWithValue(mockUseCase),
      ]);
    });

    tearDown(() => container.dispose());

    test('état initial est ProductState.initial', () {
      expect(container.read(productsNotifierProvider), const ProductState.initial());
    });

    test('passe par loading puis loaded après loadProducts()', () async {
      // Arrange
      const tProducts = [ProductEntity(id: '1', name: 'A', price: 9.99)];
      when(() => mockUseCase.call()).thenAnswer((_) async => const Right(tProducts));

      final states = <ProductState>[];
      container.listen(productsNotifierProvider, (_, s) => states.add(s));

      // Act
      await container.read(productsNotifierProvider.notifier).loadProducts();

      // Assert
      expect(states, [
        const ProductState.loading(),
        const ProductState.loaded(tProducts),
      ]);
    });

    test('passe en empty() si la liste retournée est vide', () async {
      when(() => mockUseCase.call()).thenAnswer((_) async => const Right([]));

      await container.read(productsNotifierProvider.notifier).loadProducts();

      expect(container.read(productsNotifierProvider), const ProductState.empty());
    });

    test('passe en error() en cas de NetworkFailure', () async {
      when(() => mockUseCase.call())
          .thenAnswer((_) async => const Left(NetworkFailure('No connection')));

      await container.read(productsNotifierProvider.notifier).loadProducts();

      expect(
        container.read(productsNotifierProvider),
        const ProductState.error(NetworkFailure('No connection')),
      );
    });
  });
}
```

### Test e2e — Patrol

```dart
// integration_test/products_flow_test.dart
void main() {
  patrolTest('un utilisateur peut voir et sélectionner un produit', ($) async {
    await $.pumpWidgetAndSettle(const App());

    await $(#bottomNavProducts).tap();
    await $.pumpAndSettle();

    expect($(ProductListScreen), findsOneWidget);
    expect($(ProductCard), findsWidgets);

    await $(ProductCard).first.tap();
    await $.pumpAndSettle();

    expect($(ProductDetailScreen), findsOneWidget);
  });
}
```

---

## 🎨 Intégration Figma MCP

### Workflow obligatoire

```
1. get_design_context  →  layout, spacing, états du composant
2. get_variable_defs   →  design tokens → app_colors.dart / app_spacing.dart
3. get_screenshot      →  référence pixel-perfect
4. Implémenter         →  TOUS les états visibles dans Figma
5. Tester              →  _test.dart couvrant chaque état immédiatement
```

### Tokens Figma → Dart

```dart
// lib/app/theme/app_colors.dart
abstract final class AppColors {
  static const primary         = Color(0xFF6366F1);
  static const primaryPressed  = Color(0xFF4F46E5);
  static const primaryDisabled = Color(0xFFA5B4FC);
  static const surface         = Color(0xFFF8FAFC);
  static const onSurface       = Color(0xFF0F172A);
  static const onSurfaceWeak   = Color(0xFF64748B);
  static const error           = Color(0xFFEF4444);
  static const success         = Color(0xFF10B981);
  static const warning         = Color(0xFFF59E0B);
}

// lib/app/theme/app_spacing.dart
abstract final class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}
```

### Accessibilité — obligatoire sur tout composant interactif

```dart
Semantics(
  button: true,
  label: semanticLabel ?? label,
  enabled: onPressed != null,
  child: /* widget */,
)
```

---

## ⛔ Ce que Copilot ne doit JAMAIS faire

| Interdit | Alternative |
|---|---|
| `value!` sans commentaire | null check explicite ou `??` |
| `dynamic` comme type | type précis ou `Object?` |
| `print()` / `debugPrint()` | `AppLogger.debug()` |
| Magic numbers (`16`, `24`…) | `AppSpacing.md`, `AppSpacing.lg` |
| Couleurs inline (`Color(0xFF…)`) | `AppColors.primary` |
| `_buildHeader()` retournant `Widget` | Classe `_Header extends StatelessWidget` |
| `StatefulWidget` pour état async | `ConsumerWidget` + Riverpod |
| Logique métier dans un widget | Use case + provider |
| `try/catch` hors datasource | Uniquement dans la couche data |
| `// ignore:` sans explication | Commenter la raison précise |
| Widget sans `_test.dart` | Créer le test immédiatement |
| `test.skip` sans TODO daté | `// TODO(name): raison — YYYY-MM-DD` |

---

## ✅ Checklist avant chaque PR

- [ ] Chaque modification ou feature ajoutée a son test adapté dans le même lot
- [ ] Les tests ciblés du périmètre modifié ont été exécutés avant toute validation globale
- [ ] `dart analyze` — zéro erreur, zéro warning
- [ ] `dart format . --set-exit-if-changed` — code formaté
- [ ] `flutter test --coverage` — tous les tests verts
- [ ] Couverture ≥ 80% sur `domain/` et `presentation/providers/`
- [ ] Toute impossibilité d'exécuter un test ou une couverture est explicitement justifiée
- [ ] Zéro `!` non commenté, zéro `dynamic`, zéro `print()`
- [ ] Zéro magic number — tokens `AppSpacing` et `AppColors` partout
- [ ] Chaque composant Figma : tous les états implémentés **et** testés
- [ ] `const` ajouté sur tous les constructeurs éligibles
- [ ] `Semantics` présent sur tous les widgets interactifs
- [ ] Fichiers générés (`*.g.dart`, `*.freezed.dart`, `*.mocks.dart`) commités après `build_runner`
