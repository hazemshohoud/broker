import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// لوجو بروكر (السهم) مرسوم vector — حاد على أي مقاس وقابل للأنيميشن.
///
/// [progress] بيرسم حدود اللوجو تدريجيًا (0 → 1)، و[fill] بيظهّر التعبئة.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 96,
    this.color = AppColors.brand,
    this.progress = 1,
    this.fill = 1,
  });

  final double size;
  final Color color;
  final double progress;
  final double fill;

  static const _viewBox = Size(1004, 1024);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * _viewBox.height / _viewBox.width,
      child: CustomPaint(
        painter: _BrandLogoPainter(
          color: color,
          progress: progress,
          fill: fill,
        ),
      ),
    );
  }
}

class _BrandLogoPainter extends CustomPainter {
  _BrandLogoPainter({
    required this.color,
    required this.progress,
    required this.fill,
  });

  final Color color;
  final double progress;
  final double fill;

  /// نفس نقاط اللوجو الأصلي، والـ stroke بزوايا round بيعمل الحواف المدوّرة.
  Path _shape(Size size) {
    final sx = size.width / BrandLogo._viewBox.width;
    final sy = size.height / BrandLogo._viewBox.height;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    final points = [
      p(497, 32),
      p(975, 1000),
      p(652, 886),
      p(500, 648),
      p(350, 886),
      p(29, 1000),
    ];
    return Path()..addPolygon(points, true);
  }

  Path _leftWing(Size size) {
    final sx = size.width / BrandLogo._viewBox.width;
    final sy = size.height / BrandLogo._viewBox.height;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    return Path()
      ..moveTo(p(497, 32).dx, p(497, 32).dy)
      ..lineTo(p(29, 1000).dx, p(29, 1000).dy)
      ..lineTo(p(350, 886).dx, p(350, 886).dy)
      ..lineTo(p(500, 648).dx, p(500, 648).dy);
  }

  Path _rightWing(Size size) {
    final sx = size.width / BrandLogo._viewBox.width;
    final sy = size.height / BrandLogo._viewBox.height;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    return Path()
      ..moveTo(p(497, 32).dx, p(497, 32).dy)
      ..lineTo(p(975, 1000).dx, p(975, 1000).dy)
      ..lineTo(p(652, 886).dx, p(652, 886).dy)
      ..lineTo(p(500, 648).dx, p(500, 648).dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rawStrokeWidth = 44 * size.width / BrandLogo._viewBox.width;
    // نضمن أن يكون سمك خط الرسم واضحاً ومميزاً للعين حتى في المقاسات الصغيرة كالـ AppBar
    final strokeWidth = size.width <= 40 ? math.max(2.8, rawStrokeWidth) : rawStrokeWidth;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round
      ..color = color;

    if (progress > 0 && progress < 1) {
      final glowStroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2.2
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.40);

      final left = _leftWing(size);
      final right = _rightWing(size);

      for (final path in [left, right]) {
        for (final metric in path.computeMetrics()) {
          final len = metric.length * progress;
          final extracted = metric.extractPath(0, len);

          // هالة نيون مشعة خلف الخط
          canvas.drawPath(extracted, glowStroke);
          // خط الرسم الحاد
          canvas.drawPath(extracted, stroke);

          // رأس القلم الضوئي المتوهج عند نقطة الرسم
          final tangent = metric.getTangentForOffset(len);
          if (tangent != null) {
            final tip = tangent.position;
            canvas.drawCircle(
              tip,
              strokeWidth * 1.8,
              Paint()..color = color.withValues(alpha: 0.55),
            );
            canvas.drawCircle(
              tip,
              strokeWidth * 1.0,
              Paint()..color = Colors.white,
            );
            canvas.drawCircle(
              tip,
              strokeWidth * 0.55,
              Paint()..color = const Color(0xFF003811),
            );
          }
        }
      }
    } else if (progress >= 1) {
      final path = _shape(size);
      canvas.drawPath(path, stroke);
    }

    if (fill > 0) {
      final path = _shape(size);
      final faded = color.withValues(alpha: color.a * fill);
      canvas
        ..drawPath(path, Paint()..color = faded)
        ..drawPath(path, stroke..color = faded);
    }
  }

  @override
  bool shouldRepaint(_BrandLogoPainter old) =>
      old.color != color || old.progress != progress || old.fill != fill;
}

/// لوجو بروكر التفاعلي: يترسم تدريجيًا (حدود ثم تعبئة) مثل شاشة الاسبلاش تمامًا،
/// ثم يلف 180 درجة، ويقف 1.5 ثانية، ثم يلف 180 درجة ثانية ليعود للوضع الأساسي، مع فاصل 1.5 ثانية بين كل لفة.
class AnimatedBrandLogo extends StatefulWidget {
  const AnimatedBrandLogo({
    super.key,
    this.size = 28,
    this.color = AppColors.brand,
    this.repeatRotations = true,
    this.repeatInterval = const Duration(minutes: 1),
  });

  final double size;
  final Color color;
  final bool repeatRotations;
  final Duration repeatInterval;

  @override
  State<AnimatedBrandLogo> createState() => _AnimatedBrandLogoState();
}

class _AnimatedBrandLogoState extends State<AnimatedBrandLogo>
    with TickerProviderStateMixin {
  late final AnimationController _drawController;
  late final AnimationController _rotationController;
  late final AnimationController _fadeController;

  late final Animation<double> _traceAnimation;
  late final Animation<double> _fillAnimation;
  late final Animation<double> _scaleAnimation;

  double _currentAngle = 0.0;
  bool _isDisposed = false;
  Timer? _delayTimer;
  Completer<void>? _delayCompleter;

  @override
  void initState() {
    super.initState();

    // رسم اللوجو بسرعة هادئة ومتقنة ليكون واضحاً وجميلاً أمام العين
    _drawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    // رسم الحدود تدريجياً مع رأس القلم المتوهج
    _traceAnimation = CurvedAnimation(
      parent: _drawController,
      curve: const Interval(0.0, 0.60, curve: Curves.easeInOutCubic),
    );

    // تعبئة اللون بسلاسة
    _fillAnimation = CurvedAnimation(
      parent: _drawController,
      curve: const Interval(0.48, 1.0, curve: Curves.easeOutCubic),
    );

    // تأثير تكبير خفيف لطيف مطابق لشاشة الاسبلاش
    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _drawController,
        curve: const Interval(0.45, 0.88, curve: Curves.easeOutBack),
      ),
    );

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _startSequence();
  }

  Future<void> _wait(int milliseconds) {
    if (!mounted || _isDisposed) return Future.value();
    _delayTimer?.cancel();
    _delayCompleter = Completer<void>();
    _delayTimer = Timer(Duration(milliseconds: milliseconds), () {
      if (!(_delayCompleter?.isCompleted ?? true)) {
        _delayCompleter?.complete();
      }
    });
    return _delayCompleter!.future;
  }

  Future<void> _startSequence() async {
    // ننتظر 400ms حتى تستقر الشاشة بعد الانتقال وتظهر بوضوح تام أمام عين المستخدم
    await _wait(400);
    if (!mounted || _isDisposed) return;

    while (mounted && !_isDisposed) {
      // 1. رسم اللوجو بهدوء كشاشة الاسبلاش (رسم الحدود ثم تعبئة اللون)
      try {
        await _drawController.forward(from: 0.0);
      } catch (_) {}
      if (!mounted || _isDisposed) return;

      // 2. فاصل زمني ثانية ونصف بالضبط بعد اكتمال الرسم قبل البدء في الدوران
      await _wait(1500);
      if (!mounted || _isDisposed) return;

      // 3. لفة 180 درجة كاملة (من 0 إلى pi)
      await _animateRotationTo(math.pi);
      if (!mounted || _isDisposed) return;

      // 4. فرق زمني ثانية ونصف
      await _wait(1500);
      if (!mounted || _isDisposed) return;

      // 5. لفة 180 درجة ثانية للعودة للوضع الأساسي (من pi إلى 2*pi)
      await _animateRotationTo(2 * math.pi);
      if (!mounted || _isDisposed) return;

      // إعادة تصفير الزاوية إلى 0.0 لأن 2*pi تعادل 0 تماماً
      if (mounted && !_isDisposed) {
        setState(() => _currentAngle = 0.0);
      }

      if (!widget.repeatRotations) break;

      // 6. يبقى اللوجو ثابتاً ومكتملاً في الآب بار لمدة دقيقة (أو repeatInterval) قبل تكرار الأنيميشن
      await _wait(widget.repeatInterval.inMilliseconds);
      if (!mounted || _isDisposed) return;

      // 7. تلاشي خفيف لإعادة رسم الأيقونة من جديد بعد كل لفة كاملة
      try {
        await _fadeController.forward();
      } catch (_) {}
      if (!mounted || _isDisposed) return;

      _drawController.reset();
      _fadeController.reset();
      await _wait(120);
    }
  }

  Future<void> _animateRotationTo(double targetAngle) async {
    final startAngle = _currentAngle;
    _rotationController.reset();

    final animation = Tween<double>(
      begin: startAngle,
      end: targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    void listener() {
      if (mounted && !_isDisposed) {
        setState(() => _currentAngle = animation.value);
      }
    }

    animation.addListener(listener);
    try {
      await _rotationController.forward();
    } catch (_) {}
    animation.removeListener(listener);

    if (mounted && !_isDisposed) {
      _currentAngle = targetAngle;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _delayTimer?.cancel();
    _delayTimer = null;
    if (!(_delayCompleter?.isCompleted ?? true)) {
      _delayCompleter?.complete();
    }
    _drawController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _drawController,
        _rotationController,
        _fadeController,
      ]),
      builder: (context, _) {
        final opacity = 1.0 - _fadeController.value;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _currentAngle,
              alignment: Alignment.center,
              child: BrandLogo(
                size: widget.size,
                color: widget.color,
                progress: _traceAnimation.value,
                fill: _fillAnimation.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

