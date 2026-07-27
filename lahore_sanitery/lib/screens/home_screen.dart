import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import '../models/product.dart';

/// Handles speech-to-text capture and fuzzy matching of the
/// transcribed text against product name/aliases/category.
///
/// Locale is set to 'ur_PK' since the client speaks a mix of
/// Urdu/English product names — Android's Urdu speech model handles
/// this code-switching better than forcing 'en_US'.
class VoiceSearchService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;

  /// Must be called (and granted) before listen(). Returns false if
  /// the user denies mic permission — caller should show a message.
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speech.initialize(
      onError: (error) => debugPrint('Speech error: $error'),
      onStatus: (status) => debugPrint('Speech status: $status'),
    );
    return _isInitialized;
  }

  /// Starts listening and returns the transcribed text once speech
  /// recognition reports a final result, or null if nothing was
  /// recognized / permission was denied / initialization failed.
  ///
  /// [timeout] is a safety net — some devices occasionally never fire
  /// a "final result" callback, so we fall back to whatever partial
  /// text was captured once the timeout passes.
  Future<String?> listen({Duration timeout = const Duration(seconds: 6)}) async {
    final hasPermission = await requestMicPermission();
    if (!hasPermission) return null;

    final available = await init();
    if (!available) return null;

    String recognizedText = '';
    final completer = Completer<String?>();

    await _speech.listen(
      localeId: 'ur_PK',
      onResult: (result) {
        recognizedText = result.recognizedWords;
        if (result.finalResult && !completer.isCompleted) {
          completer.complete(
            recognizedText.trim().isEmpty ? null : recognizedText.trim(),
          );
        }
      },
      listenFor: timeout,
      pauseFor: const Duration(seconds: 3),
    );

    // Fallback in case finalResult never fires on this device.
    unawaited(Future.delayed(timeout + const Duration(seconds: 1), () {
      if (!completer.isCompleted) {
        _speech.stop();
        completer.complete(
          recognizedText.trim().isEmpty ? null : recognizedText.trim(),
        );
      }
    }));

    return completer.future;
  }

  void cancel() {
    _speech.cancel();
  }

  bool get isListening => _speech.isListening;

  /// Fuzzy-matches [query] against every product's name, aliases, and
  /// category. Exact substring matches score highest (1.0), otherwise
  /// falls back to string similarity. Returns matches sorted by score,
  /// filtered to a minimum relevance threshold.
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