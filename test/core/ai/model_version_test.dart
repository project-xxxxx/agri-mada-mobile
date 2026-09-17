import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

// Tâche P1.4 : les métadonnées affichées par l'app doivent décrire le modèle
// réellement embarqué. En cas d'échec : dart run tool/gen_model_version.dart
void main() {
  final metadata = jsonDecode(
    File('assets/model/model_version.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test('les maladies annoncées sont exactement les étiquettes du modèle', () {
    final labels = File('assets/model/labels.txt')
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final announced = (metadata['maladies_supportees'] as List<dynamic>)
        .map((item) => item.toString())
        .toList();

    expect(announced, labels);
  });

  test("l'empreinte correspond au fichier du modèle embarqué", () {
    final modelSha256 = sha256
        .convert(File('assets/model/agrimada_model.tflite').readAsBytesSync())
        .toString();

    expect(metadata['modele_sha256'], modelSha256);
  });
}
