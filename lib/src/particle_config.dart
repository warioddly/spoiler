import 'package:flutter/material.dart';

class ParticleConfig {
  /// Fraction of area covered by particles (0..1 => 0%..100%).
  final double density;
  final double speed;
  final Color color;
  final double maxParticleSize;
  final bool enableWaves;
  final double maxWaveRadius;
  final int maxWaveCount;

  const ParticleConfig({
    required this.density,
    required this.speed,
    required this.color,
    required this.maxParticleSize,
    this.enableWaves = false,
    this.maxWaveRadius = 0.0,
    this.maxWaveCount = 3,
  });

  static const defaultConfig = ParticleConfig(
    density: 0.1,
    speed: 0.2,
    color: Colors.white,
    maxParticleSize: 1.0,
  );

  @override
  int get hashCode => Object.hash(
        density,
        speed,
        color,
        maxParticleSize,
        enableWaves,
        maxWaveRadius,
        maxWaveCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticleConfig &&
          density == other.density &&
          speed == other.speed &&
          color == other.color &&
          maxParticleSize == other.maxParticleSize &&
          enableWaves == other.enableWaves &&
          maxWaveRadius == other.maxWaveRadius &&
          maxWaveCount == other.maxWaveCount;
}
