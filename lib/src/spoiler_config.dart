import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spoiler/src/particle_config.dart';
import 'package:spoiler/src/spoiler_mask.dart';

/// Configuration for the spoiler overlay and its particle effect.
@immutable
class SpoilerConfig {
  /// Image filter applied while the spoiler is enabled.
  final ImageFilter imageFilter;
  final bool isEnabled;
  final bool enableGestureReveal;
  final SpoilerMaskConfig? maskConfig;
  final ValueChanged<bool>? onSpoilerVisibilityChanged;
  final ParticleConfig particleConfig;
  final double? fadeEdgeThickness;

  const SpoilerConfig({
    this.maskConfig,
    this.imageFilter = const ColorFilter.mode(
      Colors.black,
      BlendMode.srcATop,
    ),
    this.isEnabled = true,
    this.enableGestureReveal = false,
    this.fadeEdgeThickness = 10.0,
    this.onSpoilerVisibilityChanged,
    this.particleConfig = ParticleConfig.defaultConfig,
  });

  SpoilerConfig copyWith({
    ImageFilter? imageFilter,
    bool? isEnabled,
    bool? enableGestureReveal,
    ParticleConfig? particleConfig,
    double? fadeEdgeThickness,
    bool disableFade = false,
    SpoilerMaskConfig? maskConfig,
    ValueChanged<bool>? onSpoilerVisibilityChanged,
  }) {
    return SpoilerConfig(
      imageFilter: imageFilter ?? this.imageFilter,
      isEnabled: isEnabled ?? this.isEnabled,
      enableGestureReveal: enableGestureReveal ?? this.enableGestureReveal,
      particleConfig: particleConfig ?? this.particleConfig,
      fadeEdgeThickness: disableFade ? null : fadeEdgeThickness ?? this.fadeEdgeThickness,
      maskConfig: maskConfig ?? this.maskConfig,
      onSpoilerVisibilityChanged: onSpoilerVisibilityChanged ?? this.onSpoilerVisibilityChanged,
    );
  }

  @override
  int get hashCode => Object.hash(
        imageFilter,
        isEnabled,
        enableGestureReveal,
        maskConfig,
        onSpoilerVisibilityChanged,
        particleConfig,
        fadeEdgeThickness,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpoilerConfig &&
          imageFilter == other.imageFilter &&
          isEnabled == other.isEnabled &&
          enableGestureReveal == other.enableGestureReveal &&
          maskConfig == other.maskConfig &&
          onSpoilerVisibilityChanged == other.onSpoilerVisibilityChanged &&
          particleConfig == other.particleConfig &&
          fadeEdgeThickness == other.fadeEdgeThickness;
}
