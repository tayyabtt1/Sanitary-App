import 'package:flutter/material.dart';
import '../services/voice_search_service.dart';

/// Fullscreen listening modal. Now shows "Preparing microphone..."
/// until the recognizer confirms it's actually capturing audio, then
/// switches to "Listening... speak now" — this pacing fix stops
/// words from getting clipped by speaking too early.
class VoiceSearchSheet extends StatefulWidget {
  const VoiceSearchSheet({super.key});

  @override
  State<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<VoiceSearchSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final VoiceSearchService _voiceService = VoiceSearchService();

  String _liveText = '';
  String _statusText = 'Preparing microphone...';
  bool _isReadyToListen = false;
  bool _errorState = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _startListening());
  }

  Future<void> _startListening() async {
    final result = await _voiceService.listen(
      onStatusChange: (status) {
        if (!mounted) return;
        if (status == 'listening') {
          setState(() {
            _isReadyToListen = true;
            _statusText = 'Listening... speak now';
          });
        }
      },
      onPartialResult: (partial) {
        if (mounted) setState(() => _liveText = partial);
      },
    );

    if (!mounted) return;

    if (result == null) {
      setState(() {
        _statusText = "Didn't catch that — check mic permission and try again";
        _errorState = true;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, null);
      return;
    }

    if (mounted) Navigator.pop(context, result);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _voiceService.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.92),
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () {
                  _voiceService.cancel();
                  Navigator.pop(context, null);
                },
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = (_errorState || !_isReadyToListen)
                          ? 1.0
                          : 1.0 + (_pulseController.value * 0.15);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: _errorState
                            ? Colors.red
                            : (_isReadyToListen ? Colors.blue : Colors.grey),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _errorState ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _statusText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_liveText.isNotEmpty && !_errorState) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        '"$_liveText"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontSize: 17,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}