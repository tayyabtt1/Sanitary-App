import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import '../models/product.dart';

/// Handles speech-to-text capture and fuzzy matching of the
/// transcribed text against product name/aliases/category.
///
/// FIX: a completely fresh SpeechToText() instance + initialize()
/// call is created on every single search, instead of reusing one
/// cached instance for the app's whole lifetime. Reusing one instance
/// across multiple searches left the Android recognizer session in a
/// stale state, causing the first attempt to only capture a fragment
/// of what was said (needing 2-3 retries to work properly).
///
/// FIX 2: [onStatusChange] reports the recognizer's REAL status
/// ('listening', 'notListening', etc.). The UI should only tell the
/// user to start speaking once status == 'listening' — there's a
/// short startup delay before the mic is actually capturing audio
/// after listen() is called, and speaking during that gap is what
/// was clipping the first word.
class VoiceSearchService {
  static const String _localeId = 'en_US';
  SpeechToText? _activeSession;

  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<String?> listen({
    Duration timeout = const Duration(seconds: 8),
    void Function(String partialText)? onPartialResult,
    void Function(String status)? onStatusChange,
  }) async {
    final hasPermission = await requestMicPermission();
    if (!hasPermission) return null;

    // Fresh instance every time — this is the key reliability fix.
    final speech = SpeechToText();
    _activeSession = speech;

    final available = await speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) {
        debugPrint('Speech status: $status');
        onStatusChange?.call(status);
      },
    );
    if (!available) return null;

    String recognizedText = '';
    final completer = Completer<String?>();

    await speech.listen(
      localeId: _localeId,
      onResult: (result) {
        recognizedText = result.recognizedWords;
        onPartialResult?.call(recognizedText);
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(
            recognizedText.trim().isEmpty ? null : recognizedText.trim(),
          );
        }
      },
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
    );

    unawaited(Future.delayed(timeout + const Duration(seconds: 1), () {
      if (!completer.isCompleted) {
        speech.stop();
        completer.complete(
          recognizedText.trim().isEmpty ? null : recognizedText.trim(),
        );
      }
    }));

    final result = await completer.future;
    speech.cancel();
    if (identical(_activeSession, speech)) _activeSession = null;
    return result;
  }

  void cancel() {
    _activeSession?.cancel();
    _activeSession = null;
  }

  List<Product> matchProducts(String query, List<Product> allProducts) {
    final normalizedQuery = query.toLowerCase().trim();
    if (normalizedQuery.isEmpty) return [];

    const threshold = 0.35;
    final scored = <MapEntry<Product, double>>[];

    for (final product in allProducts) {
      double bestScore = _scoreAgainst(normalizedQuery, product.name);

      for (final alias in product.aliases) {
        final aliasScore = _scoreAgainst(normalizedQuery, alias);
        if (aliasScore > bestScore) bestScore = aliasScore;
      }

      final categoryScore = _scoreAgainst(normalizedQuery, product.category);
      if (categoryScore > bestScore) bestScore = categoryScore;

      scored.add(MapEntry(product, bestScore));
    }

    scored.sort((a, b) => b.value.compareTo(a.value));

    return scored
        .where((entry) => entry.value >= threshold)
        .map((entry) => entry.key)
        .toList();
  }

  double _scoreAgainst(String query, String target) {
    final normalizedTarget = target.toLowerCase();
    if (normalizedTarget.contains(query) || query.contains(normalizedTarget)) {
      return 1.0;
    }
    return StringSimilarity.compareTwoStrings(query, normalizedTarget);
  }
}