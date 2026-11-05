import 'package:flutter/material.dart';
import 'package:spoiler/src/path_x.dart';
import 'package:spoiler/src/spoiler_config.dart';
import 'package:spoiler/src/spoiler_drawing_strategy.dart';
import 'package:spoiler/src/rect_x.dart';

/// Controls the shader-rendered spoiler, reveal fade, and gesture behavior.
class SpoilerController extends ChangeNotifier {
  SpoilerController({required TickerProvider vsync}) : _tickerProvider = vsync {
    _particleCtrl = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: _tickerProvider,
    )..addListener(_onParticleFrameTick);
  }

  final TickerProvider _tickerProvider;
  late final AnimationController _particleCtrl;
  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  ShaderSpoilerDrawer? _drawer;
  int _shaderLoadGeneration = 0;
  bool _shaderInitAttempted = false;
  bool _hasError = false;
  bool _isEnabled = false;
  bool _isDisposed = false;

  Rect _spoilerBounds = Rect.zero;
  final Path _spoilerPath = Path();
  List<Rect> _spoilerRects = [];
  Offset _fadeCenter = Offset.zero;
  double _fadeRadius = 0;
  SpoilerConfig _config = const SpoilerConfig();

  bool get isEnabled => _isEnabled;
  bool get hasError => _hasError;
  bool get isFading =>
      _config.fadeEdgeThickness != null && _fadeCtrl != null && _fadeCtrl!.isAnimating;
  Rect get _splashRect => Rect.fromCircle(center: _fadeCenter, radius: _fadeRadius);

  Path createClipPath() {
    if (_config.fadeEdgeThickness == null) {
      return _spoilerPath;
    }
    if (_fadeRadius <= 0) return Path();
    return Path.combine(
      PathOperation.intersect,
      _spoilerPath,
      Path()..addOval(_splashRect),
    );
  }

  /// Initializes shader rendering and bounds for [path].
  void initializeParticles(Path path, SpoilerConfig config) {
    assert(config.particleConfig.maxParticleSize >= 1, 'maxParticleSize must be >= 1');
    _config = config;
    _spoilerRects = [];

    if (_spoilerPath != path) {
      _spoilerPath.reset();
      if (config.maskConfig != null) {
        final maskedPath = Path.combine(
          config.maskConfig!.operation,
          path,
          config.maskConfig!.path.shift(config.maskConfig!.offset),
        );
        _spoilerPath.addPath(maskedPath, Offset.zero);
      } else {
        _spoilerPath.addPath(path, Offset.zero);
      }
      _spoilerBounds = _spoilerPath.getBounds();
    }

    _spoilerRects = _spoilerPath.subPaths.map((subPath) => subPath.getBounds()).toList();
    _initFadeIfNeeded();
    _isEnabled = config.isEnabled;
    _startParticleAnimationIfNeeded();

    _initShaderIfNeeded();
  }

  void _initFadeIfNeeded() {
    if (_config.fadeEdgeThickness == null || _fadeCtrl != null) return;

    _fadeCtrl = AnimationController(
      value: _config.isEnabled ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      vsync: _tickerProvider,
    );
    _fadeCtrl!.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) _stopAll();
    });
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_fadeCtrl!)..addListener(_updateFadeRadius);
  }

  void enable() {
    _isEnabled = true;
    _startParticleAnimationIfNeeded();
    if (_config.fadeEdgeThickness != null) _fadeCtrl?.forward();
    notifyListeners();
  }

  void disable() {
    if (_config.fadeEdgeThickness == null) {
      _stopAll();
      return;
    }
    final fadeCtrl = _fadeCtrl;
    if (fadeCtrl == null || fadeCtrl.status == AnimationStatus.dismissed) {
      _stopAll();
    } else {
      fadeCtrl.reverse();
    }
  }

  bool toggle(Offset fadeOffset) {
    if ((_config.fadeEdgeThickness != null && isFading) || !_spoilerPath.contains(fadeOffset)) {
      return false;
    }
    setFadeCenter(fadeOffset);
    _onEnabledChanged(!_isEnabled);
    return true;
  }

  void setFadeCenter(Offset fadeCenter) {
    _fadeCenter =
        _spoilerBounds == Rect.zero ? fadeCenter : _spoilerBounds.getNearestPoint(fadeCenter);
    if (_fadeAnim != null) _updateFadeRadius();
  }

  void _onEnabledChanged(bool value) {
    if (value) {
      enable();
    } else {
      disable();
    }
    _config.onSpoilerVisibilityChanged?.call(value);
  }

  void _startParticleAnimationIfNeeded() {
    if (_isEnabled) _particleCtrl.repeat();
  }

  void _onParticleFrameTick() {
    _drawer?.update(0.016);
    notifyListeners();
  }

  void _updateFadeRadius() {
    if (_spoilerBounds == Rect.zero || _fadeAnim == null) return;
    final farthestPoint = _spoilerBounds.getFarthestPoint(_fadeCenter);
    _fadeRadius = (farthestPoint - _fadeCenter).distance * _fadeAnim!.value;
    notifyListeners();
  }

  void _stopAll() {
    if (_isDisposed || (!_isEnabled && _fadeRadius == 0 && _particleCtrl.status.isDismissed)) {
      return;
    }
    _isEnabled = false;
    _fadeRadius = 0;
    _particleCtrl.reset();
    notifyListeners();
  }

  void drawParticles(Canvas canvas) {
    if (_particleCtrl.status.isDismissed) return;
    final drawer = _drawer;
    if (drawer == null) return;

    drawer.draw(
      canvas,
      SpoilerContext(
        isFading: isFading,
        fadeRadius: _fadeRadius,
        fadeCenter: _fadeCenter,
        spoilerBounds: _spoilerBounds,
        spoilerRects: _spoilerRects,
        config: _config,
      ),
    );
  }

  Future<void> _initShaderIfNeeded() async {
    if (_shaderInitAttempted) return;
    _shaderInitAttempted = true;
    final generation = ++_shaderLoadGeneration;
    try {
      final drawer = await ShaderSpoilerDrawer.create();
      if (_isDisposed || generation != _shaderLoadGeneration) {
        drawer.dispose();
        return;
      }
      _drawer?.dispose();
      _drawer = drawer;
      notifyListeners();
    } catch (error) {
      if (!_isDisposed && generation == _shaderLoadGeneration) {
        _hasError = true;
        debugPrint('SpoilerController: Failed to load shader: $error');
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _shaderLoadGeneration++;
    _particleCtrl.dispose();
    _fadeCtrl?.dispose();
    _drawer?.dispose();
    super.dispose();
  }
}
