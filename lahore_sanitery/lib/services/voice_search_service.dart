import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import '../models/product.dart';

/// Handles speech-to-text capture and fuzzy matching of the
/// transcribed text against product name/aliases/category.
///
/// IMPORTANT: locale is hardcoded to 'en_US'. We previously tried
/// auto-detecting the best available English locale via
/// _speech.locales(), but on some devices (especially with system
/// language set to Urdu) that detection unreliably fell back to the
/// device default, which silently re-introduced the Urdu-transcription
/// bug. Hardcoding en_US directly is more robust — Google's speech
/// recognizer supports en_US regardless of the phone's system
/// language, as long as there's an internet connection.
class VoiceSearchService {
  final SpeechToText _speech = SpeechToText();
  bool _isInitialized = false;
  static const String _localeId = 'en_US';

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

  /// Starts listening. [onPartialResult] fires repeatedly with
  /// interim text while the user is still speaking, so the UI can
  /// show live feedback instead of a static "Listening..." with no
  /// indication anything is being picked up.
  ///
  /// Returns the final transcribed text, or null if nothing was
  /// recognized / permission denied / initialization failed.
  Future<String?> listen({
    Duration timeout = const Duration(seconds: 6),
    void Function(String partialText)? onPartialResult,
  }) async {
    final hasPermission = await requestMicPermission();
    if (!hasPermission) return null;

    final available = await init();
    if (!available) return null;

    String recognizedText = '';
    final completer = Completer<String?>();

    await _speech.listen(
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