import 'package:flutter/material.dart';
import 'package:spoiler/src/spoiler_config.dart';
import 'package:spoiler/src/spoiler_shader_renderer.dart';

/// Context object containing all state required for drawing the spoiler.
class SpoilerContext {
  const SpoilerContext({
    required this.isFading,
    required this.fadeRadius,
    required this.fadeCenter,
    required this.spoilerBounds,
    required this.spoilerRects,
    required this.config,
  });

  final bool isFading;
  final double fadeRadius;
  final Offset fadeCenter;
  final Rect spoilerBounds;
  final List<Rect> spoilerRects;
  final SpoilerConfig config;
}

/// Renders the spoiler particles with the bundled fragment shader.
class ShaderSpoilerDrawer {
  ShaderSpoilerDrawer._(this._renderer);

  final SpoilerShaderRenderer _renderer;
  double _shaderTime = 0.0;

  static Future<ShaderSpoilerDrawer> create() async {
    final renderer = await SpoilerShaderRenderer.create();
    if (renderer == null) {
      throw StateError('Failed to load the bundled particle shader.');
    }
    return ShaderSpoilerDrawer._(renderer);
  }

  void update(double dt) {
    _shaderTime += dt;
  }

  void draw(Canvas canvas, SpoilerContext context) {
    final rects = context.spoilerRects.isEmpty ? [context.spoilerBounds] : context.spoilerRects;

    for (var index = 0; index < rects.length; index++) {
      final rect = rects[index];
      final seed = index * 123.45 + rect.left + rect.top;
      final params = _particleUniforms(
        rect: rect,
        time: _shaderTime,
        seed: seed,
        fadeCenter: context.fadeCenter,
        isFading: context.isFading,
        fadeRadius: context.fadeRadius,
        config: context.config,
      );

      canvas
        ..save()
        ..clipRect(rect);
      _renderer.render(canvas, rect, params: params);
      canvas.restore();
    }
  }

  void dispose() => _renderer.dispose();
}

List<double> _particleUniforms({
  required Rect rect,
  required double time,
  required double seed,
  required Offset fadeCenter,
  required bool isFading,
  required double fadeRadius,
  required SpoilerConfig config,
}) {
  final particles = config.particleConfig;
  return [
    rect.width,
    rect.height,
    time,
    rect.left,
    rect.top,
    rect.width,
    rect.height,
    seed,
    particles.color.r,
    particles.color.g,
    particles.color.b,
    particles.density.clamp(0.0, 1.0),
    particles.maxParticleSize,
    particles.speed,
    fadeCenter.dx,
    fadeCenter.dy,
    fadeRadius,
    isFading ? 1.0 : 0.0,
    config.fadeEdgeThickness ?? 1.0,
    particles.enableWaves ? 1.0 : 0.0,
    particles.maxWaveRadius,
    particles.maxWaveCount.toDouble(),
  ];
}
