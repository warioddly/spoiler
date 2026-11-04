import 'dart:ui';

import 'package:flutter/rendering.dart';

/// An extension on the [Path] class to provide additional utility methods.
extension PathX on Path {
  /// Returns an iterable of subpaths that make up the current path.
  ///
  /// This generator function iterates over all the path metrics and extracts
  /// each subpath from the beginning to the full length of the metric.
  /// Useful for handling paths in segments.
  Iterable<Path> get subPaths sync* {
    for (final metric in computeMetrics()) {
      final subPath = metric.extractPath(0, metric.length);
      yield subPath;
    }
  }
}
