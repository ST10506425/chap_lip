import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Four point sparkle that twinkles forever.
class Sparkle extends StatefulWidget {
  const Sparkle({super.key, this.size = 24, this.color = AppColors.primary, this.delay = Duration.zero});

  final double size;
  final Color color;
  final Duration delay;

  @override
  State<Sparkle> createState() => _SparkleState();
}

class _SparkleState extends State<Sparkle> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.repeat();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final wave = math.sin(_c.value * math.pi * 2);
        return Opacity(
          opacity: (0.8 + 0.2 * wave).clamp(0.0, 1.0),
          child: Transform.rotate(
            angle: 0.18 * wave,
            child: Transform.scale(scale: 1 + 0.14 * wave, child: child),
          ),
        );
      },
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: SparklePainter(widget.color),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  const SparklePainter(this.color);
  final Color color;

  static Path pathFor(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;
    const k = 0.14;
    return Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx + w * k, cy - h * k, w, cy)
      ..quadraticBezierTo(cx + w * k, cy + h * k, cx, h)
      ..quadraticBezierTo(cx - w * k, cy + h * k, 0, cy)
      ..quadraticBezierTo(cx - w * k, cy - h * k, cx, 0)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(pathFor(size), Paint()..color = color);
  }

  @override
  bool shouldRepaint(SparklePainter old) => old.color != color;
}

/// Soft coloured ellipse that drifts slowly.
class DriftingBlob extends StatefulWidget {
  const DriftingBlob({
    super.key,
    required this.color,
    required this.width,
    required this.height,
    this.drift = 5,
    this.period = const Duration(seconds: 6),
    this.phase = 0,
  });

  final Color color;
  final double width;
  final double height;
  final double drift;
  final Duration period;
  final double phase;

  @override
  State<DriftingBlob> createState() => _DriftingBlobState();
}

class _DriftingBlobState extends State<DriftingBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = (_c.value + widget.phase) * math.pi * 2;
        return Transform.translate(
          offset: Offset(math.cos(t) * widget.drift, math.sin(t) * widget.drift * 0.7),
          child: Transform.scale(scale: 1 + 0.025 * math.sin(t * 2), child: child),
        );
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.all(Radius.elliptical(widget.width / 2, widget.height / 2)),
        ),
      ),
    );
  }
}

/// A burst of sparkles and dots flying out from the centre, played once.
class SparkleBurst extends StatefulWidget {
  const SparkleBurst({super.key, required this.play, this.size = const Size(300, 220), this.count = 18});

  /// Increment to replay the burst.
  final int play;
  final Size size;
  final int count;

  @override
  State<SparkleBurst> createState() => _SparkleBurstState();
}

class _SparkleBurstState extends State<SparkleBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  final _rnd = math.Random(4);
  late List<_Particle> _particles = _make();

  List<_Particle> _make() => List.generate(widget.count, (i) {
        final angle = (i / widget.count) * math.pi * 2 + _rnd.nextDouble() * 0.4;
        return _Particle(
          angle: angle,
          distance: 0.55 + _rnd.nextDouble() * 0.45,
          size: 6 + _rnd.nextDouble() * 10,
          color: [AppColors.primary, AppColors.peach, AppColors.mint, const Color(0xFFEF7897), AppColors.butter][i % 5],
          star: i.isEven,
          spin: (_rnd.nextDouble() - 0.5) * 4,
        );
      });

  @override
  void didUpdateWidget(SparkleBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play != oldWidget.play && widget.play > 0) {
      _particles = _make();
      _c.forward(from: 0);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.play > 0) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          size: widget.size,
          painter: _BurstPainter(_particles, _c.value),
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.color,
    required this.star,
    required this.spin,
  });
  final double angle;
  final double distance;
  final double size;
  final Color color;
  final bool star;
  final double spin;
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.particles, this.t);
  final List<_Particle> particles;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(t);
    final fade = t < 0.6 ? 1.0 : 1 - (t - 0.6) / 0.4;
    for (final p in particles) {
      final r = Offset(math.cos(p.angle) * size.width / 2, math.sin(p.angle) * size.height / 2) * p.distance * eased;
      final pos = center + r + Offset(0, 30 * t * t);
      final paint = Paint()..color = p.color.withValues(alpha: fade.clamp(0.0, 1.0));
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(p.spin * t);
      final s = p.size * (0.6 + 0.4 * (1 - t));
      if (p.star) {
        canvas.translate(-s / 2, -s / 2);
        canvas.drawPath(SparklePainter.pathFor(Size.square(s)), paint);
      } else {
        canvas.drawCircle(Offset.zero, s / 3.2, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => true;
}

/// Floating confetti that rains gently over the unlock celebration.
class ConfettiRain extends StatefulWidget {
  const ConfettiRain({super.key, this.count = 26});
  final int count;

  @override
  State<ConfettiRain> createState() => _ConfettiRainState();
}

class _ConfettiRainState extends State<ConfettiRain> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat();
  final _rnd = math.Random(11);
  late final _bits = List.generate(
    widget.count,
    (i) => (
      x: _rnd.nextDouble(),
      offset: _rnd.nextDouble(),
      speed: 0.6 + _rnd.nextDouble() * 0.7,
      size: 5 + _rnd.nextDouble() * 6,
      sway: _rnd.nextDouble() * math.pi * 2,
      color: [AppColors.primary, const Color(0xFFEF7897), AppColors.peach, AppColors.mint, const Color(0xFFC87395)][i % 5],
      star: i % 3 == 0,
    ),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _ConfettiPainter(_bits, _c.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.bits, this.t);
  final List<({double x, double offset, double speed, double size, double sway, Color color, bool star})> bits;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (final b in bits) {
      final progress = (t * b.speed + b.offset) % 1.0;
      final y = -20 + progress * (size.height + 40);
      final x = b.x * size.width + math.sin(progress * math.pi * 4 + b.sway) * 14;
      final fade = progress < 0.1 ? progress / 0.1 : (progress > 0.85 ? (1 - progress) / 0.15 : 1.0);
      final paint = Paint()..color = b.color.withValues(alpha: 0.55 * fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * math.pi * 3 + b.sway);
      if (b.star) {
        canvas.translate(-b.size / 2, -b.size / 2);
        canvas.drawPath(SparklePainter.pathFor(Size.square(b.size * 1.4)), paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: b.size, height: b.size * 0.55),
              const Radius.circular(2)),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => true;
}
