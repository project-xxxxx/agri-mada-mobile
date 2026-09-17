import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ai/tflite_service.dart';

final isTFLiteReadyProvider = Provider<bool>((_) => false);

/// Accès au service TFLite
final tfliteServiceProvider = Provider<TFLiteService>(
  (_) => TFLiteService.instance,
);
