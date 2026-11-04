import 'package:flutter/material.dart';
import 'package:spoiler/spoiler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      showPerformanceOverlay: false,
      home: SpoilerOverlayPage(),
    );
  }
}

class SpoilerOverlayPage extends StatelessWidget {
  const SpoilerOverlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpoilerOverlay'),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: SpoilerOverlay(
          config: const SpoilerConfig().copyWith(
            enableGestureReveal: true,
            particleConfig: const ParticleConfig(
              density: .1,
              speed: 0.25,
              // color: Color(0xFF0D884D),
              color: Colors.white,
              maxParticleSize: 1.0,
              enableWaves: true,
              maxWaveRadius: 100.0,
              maxWaveCount: 5,
            ),
          ),
          child: const Text(
            'Hello World!',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
