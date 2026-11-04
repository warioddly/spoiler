import 'package:flutter/material.dart';

/// Defines a path mask applied to a spoiler area.
class SpoilerMaskConfig {
  /// Path used to combine with the spoiler area.
  final Path path;

  /// Boolean path operation applied to the spoiler and mask paths.
  final PathOperation operation;

  /// Position offset applied to [path] before combining.
  final Offset offset;

  /// Creates a mask configuration.
  const SpoilerMaskConfig({
    required this.path,
    required this.operation,
    this.offset = Offset.zero,
  });
}
