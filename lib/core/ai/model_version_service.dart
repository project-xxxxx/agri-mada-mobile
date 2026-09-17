import 'dart:convert';

import 'package:flutter/services.dart';

class ModelVersionInfo {
  const ModelVersionInfo({
    required this.version,
    required this.date,
    required this.maladiesSupportees,
  });

  final String version;
  final String date;
  final List<String> maladiesSupportees;
}

class ModelVersionService {
  ModelVersionService._();

  static final ModelVersionService instance = ModelVersionService._();

  ModelVersionInfo? _cached;

  Future<ModelVersionInfo> load() async {
    if (_cached != null) return _cached!;

    final rawJson =
        await rootBundle.loadString('assets/model/model_version.json');
    final json = jsonDecode(rawJson) as Map<String, dynamic>;

    final maladies =
        (json['maladies_supportees'] as List<dynamic>? ?? const <dynamic>[])
            .map((item) => item.toString())
            .toList();

    _cached = ModelVersionInfo(
      version: json['version']?.toString() ?? 'inconnue',
      date: json['date']?.toString() ?? 'inconnue',
      maladiesSupportees: maladies,
    );

    return _cached!;
  }
}
