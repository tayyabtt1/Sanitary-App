import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MicButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            height: 88,
            width: 88,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 36),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Tap to Search',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}