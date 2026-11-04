import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Renders the bundled particle shader for the spoiler.
///
/// This class handles loading a user-provided fragment shader and applying it
/// to the canvas. It provides standard uniforms to the shader:
/// - uResolution (vec2)
/// - uTime (float)
/// - uRect (vec4)
/// - uSeed (float)
class SpoilerShaderRenderer {
  static const _assetPath = 'packages/spoiler/shaders/particles.frag';

  SpoilerShaderRenderer._({
    required ui.FragmentShader shader,
  }) : _shader = shader;

  final ui.FragmentShader _shader;

  /// Creates a renderer for the bundled particle shader.
  ///
  /// Returns `null` if the shader asset cannot be found or loaded.
  static Future<SpoilerShaderRenderer?> create() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(_assetPath);
      final shader = program.fragmentShader();
      return SpoilerShaderRenderer._(shader: shader);
    } catch (e) {
      debugPrint('SpoilerShaderRenderer: Failed to load the bundled particle shader. Error: $e');
      return null;
    }
  }

  /// Renders the shader effect for a specific [rect].
  void render(
    Canvas canvas,
    Rect rect, {
    required List<double> params,
  }) {
    // Write the particle shader uniforms in order.
    for (int i = 0; i < params.length; i++) {
      _shader.setFloat(i, params[i]);
    }
    final paint = Paint()..shader = _shader;
    canvas.drawRect(rect, paint);
  }

  void dispose() {
    _shader.dispose();
  }
}
