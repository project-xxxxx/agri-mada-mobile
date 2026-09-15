// Service TFLite - Moteur d'intelligence artificielle hors-ligne
// Charge le modèle .tflite depuis les assets et effectue l'inférence
// directement sur le processeur du téléphone, sans connexion internet.
//
// Labels du modèle (labels.txt) :
//   0 → Bacterial leaf blight
//   1 → Brown spot
//   2 → Leaf smut

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/logger.dart';
import 'diagnosis_certainty.dart';

@visibleForTesting
bool hasValidTfliteModelHeader(Uint8List buffer) {
  if (buffer.length < 8) return false;
  return buffer[4] == 0x54 &&
      buffer[5] == 0x46 &&
      buffer[6] == 0x4C &&
      buffer[7] == 0x33;
}

class TFLiteNotInitializedException implements Exception {
  const TFLiteNotInitializedException();

  @override
  String toString() =>
      'TFLiteService non initialisé. Appelez init() avant analyzeImage().';
}

// ─── Résultat interne TFLite (type privé au service) ────────────────────────
// Renommé depuis DiagnosticResult pour éviter la collision avec l'entité domain.
// Le service ne décide ni de la gravité ni des conseils (tâches P1.1 et P1.3).
class TFLiteInferenceResult {
  final String maladieDetectee;
  final double confiance;

  /// Les classes les plus probables, de la plus à la moins probable.
  final List<ScoredLabel> classement;
  final DiagnosisCertainty certitude;

  const TFLiteInferenceResult({
    required this.maladieDetectee,
    required this.confiance,
    this.classement = const [],
    this.certitude = DiagnosisCertainty.incertain,
  });
}

// ─── Paramètres passés à l'isolate de conversion image ──────────────────────
class _ImageConvertParams {
  const _ImageConvertParams(this.imageBytes, this.inputSize);
  final Uint8List imageBytes;
  final int inputSize;
}

// ─── Fonction top-level pour compute() — doit être hors de toute classe ─────
// Retourne un Float32List [1, inputSize, inputSize, 3] aplati.
Float32List _convertImageToFloat32(Object params) {
  final p = params as _ImageConvertParams;
  final originalImage = img.decodeImage(p.imageBytes);
  if (originalImage == null) throw Exception('Image invalide ou corrompue');

  final resized = img.copyResize(
    originalImage,
    width: p.inputSize,
    height: p.inputSize,
  );

  final size = p.inputSize;
  // Float32List : 1 (batch) × size × size × 3 (RGB)
  final buffer = Float32List(size * size * 3);
  var i = 0;
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final pixel = resized.getPixel(x, y);
      buffer[i++] = pixel.rNormalized.toDouble();
      buffer[i++] = pixel.gNormalized.toDouble();
      buffer[i++] = pixel.bNormalized.toDouble();
    }
  }
  return buffer;
}

// ─── Service principal ───────────────────────────────────────────────────────
class TFLiteService {
  TFLiteService._();
  static final TFLiteService instance = TFLiteService._();

  Interpreter? _interpreter;
  List<String> _labels = [];
  int? lastInferenceTimeMs;
  Future<void>? _initFuture;
  String? _lastInitError;

  static const int _inputSize = 224;

  bool get isReady => _interpreter != null && _labels.isNotEmpty;

  String? get lastInitError => _lastInitError;

  /// À appeler une seule fois dans main() après IsarService.init()
  Future<void> init() {
    if (isReady) return Future<void>.value();
    return _initFuture ??= _doInit();
  }

  Future<void> _doInit() async {
    try {
      AppLogger.info('TFLite init: chargement du modele...');
      final modelData =
          await rootBundle.load('assets/model/agrimada_model.tflite');

      if (modelData.lengthInBytes == 0) {
        throw Exception('Fichier modele IA vide');
      }

      final buffer = modelData.buffer.asUint8List();
      if (!hasValidTfliteModelHeader(buffer)) {
        throw Exception(
          'Fichier modele IA invalide: signature TFLite absente',
        );
      }

      AppLogger.debug('TFLite model bytes: ${buffer.length}');
      _interpreter = await _createInterpreterWithFallback(buffer);

      AppLogger.info('TFLite init: chargement des labels...');
      final labelsData = await rootBundle.loadString('assets/model/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (_labels.isEmpty) {
        throw Exception('Fichier labels vide ou invalide');
      }

      _lastInitError = null;
      AppLogger.info('TFLite init: ok (${_labels.length} labels)');
    } catch (e, st) {
      _interpreter?.close();
      _interpreter = null;
      _labels = [];
      _lastInitError = e.toString();
      AppLogger.error(
        'Initialisation TFLite echouee',
        error: e,
        stackTrace: st,
      );
      rethrow;
    } finally {
      _initFuture = null;
    }
  }

  Future<Interpreter> _createInterpreterWithFallback(Uint8List buffer) async {
    // Essai 1 : configuration performante (threads multiples).
    try {
      final options = InterpreterOptions()..threads = 4;
      return Interpreter.fromBuffer(buffer, options: options);
    } catch (firstError, firstStack) {
      AppLogger.error(
        'Creation Interpreter avec options echouee, tentative sans options',
        error: firstError,
        stackTrace: firstStack,
      );
    }

    // Essai 2 : configuration par défaut.
    try {
      return Interpreter.fromBuffer(buffer);
    } catch (secondError, secondStack) {
      AppLogger.error(
        'Creation Interpreter depuis buffer echouee, tentative depuis asset',
        error: secondError,
        stackTrace: secondStack,
      );
    }

    // Essai 3 : chargement direct asset (path Flutter).
    return Interpreter.fromAsset('assets/model/agrimada_model.tflite');
  }

  /// Analyse une image et retourne le résultat d'inférence.
  /// La conversion pixel → Float32 est déportée sur un isolate via compute()
  /// pour éviter de geler le thread UI (fix #6).
  Future<TFLiteInferenceResult> analyzeImage(File imageFile) async {
    if (!isReady) throw const TFLiteNotInitializedException();

    final stopwatch = Stopwatch()..start();

    // 1. Lire les bytes de l'image
    final bytes = await imageFile.readAsBytes();

    // 2. Convertir en Float32List dans un isolate séparé (pas de freeze UI)
    final inputData = await compute(
      _convertImageToFloat32,
      _ImageConvertParams(bytes, _inputSize),
    );

    // 3. Préparer le tenseur de sortie
    final output = List.filled(_labels.length, 0.0);
    final outputList = [output];

    // 4. Inférence (TFLite gère son propre threading interne)
    _interpreter!.run(
      inputData.reshape<double>([1, _inputSize, _inputSize, 3]),
      outputList,
    );

    // 5. Classer les scores et en déduire la certitude (tâche P1.2).
    //    La gravité n'est plus calculée ici : elle est déclarée par l'agriculteur.
    final ranked = rankScores(outputList[0], _labels);
    final best = ranked.isNotEmpty ? ranked.first : const ScoredLabel('Inconnu', 0);

    stopwatch.stop();
    lastInferenceTimeMs = stopwatch.elapsedMilliseconds;

    return TFLiteInferenceResult(
      maladieDetectee: best.label,
      confiance: best.score,
      classement: ranked,
      certitude: certaintyOf(ranked),
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = [];
    _lastInitError = null;
  }
}
