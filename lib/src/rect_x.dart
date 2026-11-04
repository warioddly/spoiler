import 'package:flutter/rendering.dart';

/// Geometry helpers for [Rect].
extension RectX on Rect {
  /// Get the farthest corner from {offset}
  Offset getFarthestPoint(Offset offset) {
    final corners = [
      topLeft,
      topRight,
      bottomLeft,
      bottomRight,
    ];

    var farthest = corners.first;
    var maxDistance = (farthest - offset).distanceSquared;

    for (final corner in corners.skip(1)) {
      final distance = (corner - offset).distanceSquared;
      if (distance > maxDistance) {
        maxDistance = distance;
        farthest = corner;
      }
    }

    return farthest;
  }

  /// Get the nearest corner from {offset}
  Offset getNearestPoint(Offset offset) {
    // Clamp the x-coordinate of the offset within the rect's horizontal boundaries
    final nearestX = offset.dx.clamp(left, right);

    // Clamp the y-coordinate of the offset within the rect's vertical boundaries
    final nearestY = offset.dy.clamp(top, bottom);

    // Return the nearest corner
    return Offset(nearestX, nearestY);
  }
}
