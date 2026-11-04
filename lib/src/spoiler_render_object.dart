import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef PaintCallback = void Function(Canvas canvas, Size size);

/// Render object widget that paints a child while exposing hook points for
/// clipping and particle painting.
class SpoilerRenderObjectWidget extends SingleChildRenderObjectWidget {
  const SpoilerRenderObjectWidget({
    super.key,
    required super.child,
    this.onAfterPaint,
    this.onClipPath,
    this.imageFilter,
  });

  final PaintCallback? onAfterPaint;
  final Path Function(Size size)? onClipPath;
  final ui.ImageFilter? imageFilter;

  @override
  RenderSpoiler createRenderObject(BuildContext context) {
    return RenderSpoiler(
      onAfterPaint: onAfterPaint,
      onClipPath: onClipPath,
      imageFilter: imageFilter,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSpoiler renderObject) {
    renderObject
      ..onAfterPaint = onAfterPaint
      ..onClipPath = onClipPath
      ..imageFilter = imageFilter;
  }
}

/// RenderBox that paints its child followed by clipped, optionally filtered
/// particle effects.
class RenderSpoiler extends RenderProxyBox {
  RenderSpoiler({
    PaintCallback? onAfterPaint,
    Path Function(Size size)? onClipPath,
    ui.ImageFilter? imageFilter,
    RenderBox? child,
  })  : _onAfterPaint = onAfterPaint,
        _onClipPath = onClipPath,
        _imageFilter = imageFilter,
        super(child);

  @override
  bool get isRepaintBoundary => true;

  @override
  bool hitTestSelf(Offset position) => true;

  PaintCallback? _onAfterPaint;
  set onAfterPaint(PaintCallback? value) {
    if (_onAfterPaint != value) {
      _onAfterPaint = value;
      markNeedsPaint();
    }
  }

  Path Function(Size size)? _onClipPath;
  set onClipPath(Path Function(Size size)? value) {
    if (_onClipPath != value) {
      _onClipPath = value;
      markNeedsPaint();
    }
  }

  ui.ImageFilter? _imageFilter;
  set imageFilter(ui.ImageFilter? value) {
    if (_imageFilter != value) {
      _imageFilter = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final clipPath = _onClipPath?.call(size);

    super.paint(context, offset);
    if (clipPath == null && _onAfterPaint == null && _imageFilter == null) {
      return;
    }
    if (clipPath != null) {
      context.pushClipPath(
        needsCompositing,
        offset,
        paintBounds.shift(offset),
        clipPath,
        _paintOverlayContent,
      );
    } else {
      _paintOverlayContent(context, offset);
    }
  }

  void _paintOverlayContent(PaintingContext context, Offset offset) {
    if (_imageFilter != null) {
      context.pushLayer(
        BackdropFilterLayer(filter: _imageFilter!),
        (childContext, childOffset) {
          _drawParticles(childContext, childOffset, _onAfterPaint);
        },
        offset,
      );
    } else {
      _drawParticles(context, offset, _onAfterPaint);
    }
  }

  void _drawParticles(
      PaintingContext context, Offset offset, PaintCallback? callback) {
    if (callback == null) return;

    final canvas = context.canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    callback(canvas, size);
    canvas.restore();
  }
}
