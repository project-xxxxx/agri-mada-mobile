// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'cf46cdb8b693a3420659a1f315926c06bd798289';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$authRemoteDatasourceHash() =>
    r'e80921f39c874ab92eaaf9d0cd60ba9b05766e88';

/// See also [authRemoteDatasource].
@ProviderFor(authRemoteDatasource)
final authRemoteDatasourceProvider =
    AutoDisposeProvider<AuthRemoteDatasource>.internal(
  authRemoteDatasource,
  name: r'authRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRemoteDatasourceRef = AutoDisposeProviderRef<AuthRemoteDatasource>;
String _$authRepositoryHash() => r'06428315d15e5470ec66ab507b918c6713d85afd';

/// See also [authRepository].
@ProviderFor(authRepository)
final authRepositoryProvider = AutoDisposeProvider<AuthRepositoryImpl>.internal(
  authRepository,
  name: r'authRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AuthRepositoryRef = AutoDisposeProviderRef<AuthRepositoryImpl>;
String _$loginUseCaseHash() => r'5a95b111ff086652f0c947b88bcfe26ea7ce95be';

/// See also [loginUseCase].
@ProviderFor(loginUseCase)
final loginUseCaseProvider = AutoDisposeProvider<LoginUseCase>.internal(
  loginUseCase,
  name: r'loginUseCaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$loginUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LoginUseCaseRef = AutoDisposeProviderRef<LoginUseCase>;
String _$registerUseCaseHash() => r'18669430c22e1c7844c19dd3dcbe2285a2250a73';

/// See also [registerUseCase].
@ProviderFor(registerUseCase)
final registerUseCaseProvider = AutoDisposeProvider<RegisterUseCase>.internal(
  registerUseCase,
  name: r'registerUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$registerUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RegisterUseCaseRef = AutoDisposeProviderRef<RegisterUseCase>;
String _$forgotPasswordUseCaseHash() =>
    r'fbdfcfd332abb715b8d3fc0b285a896d26dafb3c';

/// See also [forgotPasswordUseCase].
@ProviderFor(forgotPasswordUseCase)
final forgotPasswordUseCaseProvider =
    AutoDisposeProvider<ForgotPasswordUseCase>.internal(
  forgotPasswordUseCase,
  name: r'forgotPasswordUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$forgotPasswordUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ForgotPasswordUseCaseRef
    = AutoDisposeProviderRef<ForgotPasswordUseCase>;
String _$authNotifierHash() => r'a8eee807e42fb5ede98149b8f42f02bf8fe9de1d';

/// See also [AuthNotifier].
@ProviderFor(AuthNotifier)
final authNotifierProvider =
    AutoDisposeNotifierProvider<AuthNotifier, AuthState>.internal(
  AuthNotifier.new,
  name: r'authNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$authNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthNotifier = AutoDisposeNotifier<AuthState>;
String _$registerNotifierHash() => r'91cac6d73e769e1ceb27dfa2b607b10c84016521';

/// See also [RegisterNotifier].
@ProviderFor(RegisterNotifier)
final registerNotifierProvider =
    AutoDisposeNotifierProvider<RegisterNotifier, RegisterState>.internal(
  RegisterNotifier.new,
  name: r'registerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$registerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RegisterNotifier = AutoDisposeNotifier<RegisterState>;
String _$forgotPasswordNotifierHash() =>
    r'384c229d05bc952a848f82dc90a560a3f3a6f201';

/// See also [ForgotPasswordNotifier].
@ProviderFor(ForgotPasswordNotifier)
final forgotPasswordNotifierProvider = AutoDisposeNotifierProvider<
    ForgotPasswordNotifier, ForgotPasswordState>.internal(
  ForgotPasswordNotifier.new,
  name: r'forgotPasswordNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$forgotPasswordNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ForgotPasswordNotifier = AutoDisposeNotifier<ForgotPasswordState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
