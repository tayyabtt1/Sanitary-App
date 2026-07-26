import 'package:flutter/material.dart';

/// Static fullscreen "Listening..." UI for Phase 2.
/// Phase 4 wires this to real speech_to_text state (start/stop,
/// live partial results, auto-close on speech end).
class VoiceSearchSheet extends StatefulWidget {
  const VoiceSearchSheet({super.key});

  @override
  State<VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<VoiceSearchSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final scale = 1.0 + (_pulseController.value * 0.15);
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic,
                          color: Colors.white, size: 42),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Listening...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}