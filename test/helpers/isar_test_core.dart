import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:isar/isar.dart';

/// Charge la bibliothèque native Isar livrée par `isar_flutter_libs` (cache pub).
///
/// Fonctionne sans réseau, sous Windows, Linux (CI) et macOS : le harnais
/// `flutter test` bloque les requêtes HTTP, donc `download: true` échoue.
Future<void> initIsarCoreForTests() async {
  final configFile = File('.dart_tool/package_config.json');
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final packages =
      (config['packages'] as List<dynamic>).cast<Map<String, dynamic>>();
  final entry = packages.firstWhere((p) => p['name'] == 'isar_flutter_libs');

  final rootUri = entry['rootUri'] as String;
  final root = configFile.absolute.uri
      .resolve(rootUri.endsWith('/') ? rootUri : '$rootUri/');

  final relativePath = switch (Abi.current()) {
    Abi.windowsX64 => 'windows/isar.dll',
    Abi.linuxX64 => 'linux/libisar.so',
    Abi.macosX64 || Abi.macosArm64 => 'macos/libisar.dylib',
    final abi =>
      throw UnsupportedError('Isar non disponible pour les tests sur $abi'),
  };

  await Isar.initializeIsarCore(
    libraries: {Abi.current(): root.resolve(relativePath).toFilePath()},
  );
}
