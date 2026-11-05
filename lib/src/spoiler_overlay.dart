import 'package:flutter/material.dart';
import 'package:spoiler/src/spoiler_controller.dart';
import 'package:spoiler/src/spoiler_config.dart';
import 'package:spoiler/src/spoiler_render_object.dart';

/// Applies a spoiler overlay to any child widget using blur and particles.
class SpoilerOverlay extends StatefulWidget {
  const SpoilerOverlay({
    super.key,
    required this.child,
    required this.config,
    this.errorPlaceholder,
  });

  /// The widget to obscure while the spoiler is enabled.
  final Widget child;

  /// Configuration for blur, particles, and gesture behavior.
  final SpoilerConfig config;

  /// Widget displayed in place of [child] if the spoiler shader cannot load.
  ///
  /// When omitted, [child] remains visible and the particle effect is skipped.
  final Widget? errorPlaceholder;

  @override
  State<SpoilerOverlay> createState() => _SpoilerOverlayState();
}

class _SpoilerOverlayState extends State<SpoilerOverlay> with TickerProviderStateMixin {
  late SpoilerController _spoilerController;
  Rect _spoilerBounds = Rect.zero;

  @override
  void initState() {
    super.initState();
    _spoilerController = SpoilerController(vsync: this);
  }

  void _initializeSpoilerBounds(Size size) {
    _spoilerBounds = Rect.fromLTWH(0, 0, size.width, size.height);
    _spoilerController.initializeParticles(Path()..addRect(_spoilerBounds), widget.config);
  }

  @override
  void didUpdateWidget(covariant SpoilerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _initializeSpoilerBounds(_spoilerBounds.size);
    }
  }

  @override
  void dispose() {
    _spoilerController.dispose();
    super.dispose();
  }

  void _onPaint(Canvas canvas, Size size) {
    final currentBounds = Rect.fromLTWH(0, 0, size.width, size.height);
    if (_spoilerBounds != currentBounds) {
      _initializeSpoilerBounds(size);
    }
    _spoilerController.drawParticles(canvas);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) {
        if (widget.config.enableGestureReveal) {
          // Toggle the spoiler's visibility state through the controller.
          _spoilerController.toggle(details.localPosition);
        }
      },
      child: ListenableBuilder(
        listenable: _spoilerController,
        child: widget.child,
        builder: (context, child) {
          if (_spoilerController.hasError && widget.errorPlaceholder != null) {
            return widget.errorPlaceholder!;
          }

          return SpoilerRenderObjectWidget(
            onAfterPaint: (canvas, size) => _onPaint(canvas, size),
            onClipPath: (size) {
              if (_spoilerController.isEnabled && !_spoilerController.isFading) {
                return Path()..addRect(Offset.zero & size);
              }

              return _spoilerController.createClipPath();
            },
            imageFilter: _spoilerController.isEnabled ? widget.config.imageFilter : null,
            child: child!,
          );
        },
      ),
    );
  }
}
