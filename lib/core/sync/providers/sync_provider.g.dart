// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$syncRemoteDatasourceHash() =>
    r'480ce5b9037473053b2c28976fffe6e4581ff9df';

/// See also [syncRemoteDatasource].
@ProviderFor(syncRemoteDatasource)
final syncRemoteDatasourceProvider =
    AutoDisposeProvider<SyncRemoteDatasource>.internal(
  syncRemoteDatasource,
  name: r'syncRemoteDatasourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$syncRemoteDatasourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SyncRemoteDatasourceRef = AutoDisposeProviderRef<SyncRemoteDatasource>;
String _$syncNotifierHash() => r'3f7cbfced59587f4f985719f9ec1f5262f6178a4';

/// See also [SyncNotifier].
@ProviderFor(SyncNotifier)
final syncNotifierProvider = NotifierProvider<SyncNotifier, SyncState>.internal(
  SyncNotifier.new,
  name: r'syncNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$syncNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SyncNotifier = Notifier<SyncState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
