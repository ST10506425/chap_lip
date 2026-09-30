import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/lip_style.dart';
import '../models/product.dart';
import '../theme/app_colors.dart';

/// Cached vector geometry for one [LipShape], in design units.
class LipGeometry {
  LipGeometry._(this.shape) {
    _build();
  }

  static final _cache = <LipShape, LipGeometry>{};
  factory LipGeometry.of(LipShape shape) => _cache.putIfAbsent(shape, () => LipGeometry._(shape));

  final LipShape shape;
  late final Path outer;
  late final Path mouth;
  late final Path teeth;
  late final Path shadowBand;
  late final List<Path> highlights;
  late final List<Path> extraHighlights;
  late final List<Path> cracks;
  late final List<Offset> flakes;
  late final List<Offset> shimmerDots;

  static const designWidth = 760.0;
  static const center = 380.0;

  double get width => designWidth * shape.widthScale;
  double get left => center - width / 2;
  double get height => shape.bottomY;

  double _x(double dx) => center + dx * shape.widthScale;

  void _build() {
    final s = shape;
    final c = s.cornerY;
    final b = s.bottomY;
    final po = s.peakOffset;
    final bs = s.bowSharpness;
    final run = 380 - po;

    // Outer silhouette: left corner, over both peaks, right corner, round the
    // lower lip and back.
    final o = Path()..moveTo(_x(-380), c);
    o.cubicTo(_x(-380 + 0.38 * run), c * 0.5, _x(-380 + 0.62 * run), 0, _x(-po), 0);
    final c1 = -po + (1 - bs) * 0.45 * po;
    final c2 = -(0.35 * (1 - bs) + 0.02) * po;
    o.cubicTo(_x(c1), 0, _x(c2), s.bowY, _x(0), s.bowY);
    o.cubicTo(_x(-c2), s.bowY, _x(-c1), 0, _x(po), 0);
    o.cubicTo(_x(380 - 0.62 * run), 0, _x(380 - 0.38 * run), c * 0.5, _x(380), c);
    o.cubicTo(_x(300), c + 0.75 * (b - c), _x(200), b, _x(0), b);
    o.cubicTo(_x(-200), b, _x(-300), c + 0.75 * (b - c), _x(-380), c);
    o.close();
    outer = o;

    // Mouth opening between the lips.
    final kt = (4 * s.mouthTopY - c) / 3;
    final kb = (4 * s.mouthBottomY - c) / 3;
    mouth = Path()
      ..moveTo(_x(-380), c)
      ..cubicTo(_x(-190), kt, _x(190), kt, _x(380), c)
      ..cubicTo(_x(190), kb, _x(-190), kb, _x(-380), c)
      ..close();

    // Top teeth, clipped to the mouth when painted.
    final teethBottom = s.mouthTopY + (s.mouthBottomY - s.mouthTopY) * 0.42;
    teeth = Path()
      ..addRRect(RRect.fromLTRBR(
        _x(-s.teethHalfWidth),
        s.mouthTopY - 30,
        _x(s.teethHalfWidth),
        teethBottom,
        const Radius.circular(26),
      ));

    // Deeper tone across the bottom of the lower lip.
    final y0 = c + 0.45 * (b - c);
    final k = (4 * (b - 0.095 * b) - y0) / 3;
    shadowBand = Path()
      ..moveTo(_x(-420), y0)
      ..lineTo(_x(-330), y0)
      ..cubicTo(_x(-150), k, _x(150), k, _x(330), y0)
      ..lineTo(_x(420), y0)
      ..lineTo(_x(420), b + 30)
      ..lineTo(_x(-420), b + 30)
      ..close();

    double upper(double f) => f * c;
    double lower(double f) => c + f * (b - c);
    final pk = po / 125;

    Path arc(Offset a, Offset ctrl, Offset z) => Path()
      ..moveTo(a.dx, a.dy)
      ..quadraticBezierTo(ctrl.dx, ctrl.dy, z.dx, z.dy);
    Path dot(double dx, double y) => Path()
      ..moveTo(_x(dx), y - 6)
      ..lineTo(_x(dx), y + 6);

    highlights = [
      arc(Offset(_x(-188 * pk), upper(0.45)), Offset(_x(-172 * pk), upper(0.24)), Offset(_x(-92 * pk), upper(0.24))),
      arc(Offset(_x(92 * pk), upper(0.24)), Offset(_x(172 * pk), upper(0.24)), Offset(_x(188 * pk), upper(0.45))),
      dot(-166, lower(0.52)),
      arc(Offset(_x(-120), lower(0.60)), Offset(_x(-72), lower(0.74)), Offset(_x(-22), lower(0.70))),
      arc(Offset(_x(55), lower(0.70)), Offset(_x(108), lower(0.74)), Offset(_x(150), lower(0.58))),
      dot(190, lower(0.47)),
    ];

    extraHighlights = [
      arc(Offset(_x(-60), upper(0.62)), Offset(_x(-20), upper(0.55)), Offset(_x(20), upper(0.6))),
      arc(Offset(_x(-250), lower(0.30)), Offset(_x(-225), lower(0.42)), Offset(_x(-205), lower(0.46))),
      arc(Offset(_x(215), lower(0.44)), Offset(_x(240), lower(0.38)), Offset(_x(258), lower(0.28))),
    ];

    Path crack(double dx, double y, bool flip) {
      final x = _x(dx);
      final bend = flip ? 9.0 : -9.0;
      return Path()
        ..moveTo(x - bend * 0.3, y - 19)
        ..quadraticBezierTo(x + bend, y - 4, x, y + 4)
        ..quadraticBezierTo(x - bend * 0.6, y + 12, x + bend * 0.2, y + 19);
    }

    cracks = [
      crack(-187, upper(0.63), false),
      crack(-117, upper(0.38), true),
      crack(-37, upper(0.56), false),
      crack(103, upper(0.40), true),
      crack(183, upper(0.66), false),
      crack(-192, lower(0.50), true),
      crack(-102, lower(0.58), false),
      crack(3, lower(0.60), true),
      crack(103, lower(0.57), false),
      crack(203, lower(0.46), true),
    ];

    flakes = [
      Offset(_x(-157), upper(0.56)),
      Offset(_x(88), upper(0.47)),
      Offset(_x(-142), lower(0.66)),
      Offset(_x(63), lower(0.74)),
      Offset(_x(158), lower(0.52)),
    ];

    final rnd = math.Random(shape.index + 7);
    shimmerDots = List.generate(26, (i) {
      final top = i.isEven;
      final dx = (rnd.nextDouble() * 2 - 1) * 250;
      final f = 0.3 + rnd.nextDouble() * 0.45;
      return Offset(_x(dx), top ? upper(f + 0.15) : lower(f));
    });
  }
}

/// Interpolates the palette of two lip shades, used when the shade changes.
LipShade lerpShade(LipShade a, LipShade b, double t) {
  if (t <= 0) return a;
  if (t >= 1) return b;
  Color l(Color x, Color y) => Color.lerp(x, y, t)!;
  return LipShade(
    id: b.id,
    label: b.label,
    swatch: l(a.swatch, b.swatch),
    applied: l(a.applied, b.applied),
    appliedShadow: l(a.appliedShadow, b.appliedShadow),
    appliedOutline: l(a.appliedOutline, b.appliedOutline),
    chapped: l(a.chapped, b.chapped),
    chappedShadow: l(a.chappedShadow, b.chappedShadow),
    chappedOutline: l(a.chappedOutline, b.chappedOutline),
  );
}

/// Visual finish a product leaves on the lips.
class LipFinish {
  const LipFinish({this.tint, this.tintStrength = 0, this.shimmer = false, this.extraGloss = false});

  factory LipFinish.of(Product product) => LipFinish(
        tint: product.tint,
        tintStrength: product.tintStrength,
        shimmer: product.shimmer,
        extraGloss: product.extraGloss,
      );

  static const natural = LipFinish();

  final Color? tint;
  final double tintStrength;
  final bool shimmer;
  final bool extraGloss;
}

/// Paints a pair of lips.
///
/// [wetness] fades the whole mouth from chapped (0) to glossy (1). When
/// [reveal] is given instead, each entry is the glossy opacity of one
/// vertical strip, which is how swiping paints the lips bit by bit.
class LipsPainter extends CustomPainter {
  LipsPainter({
    required this.shape,
    required this.shade,
    this.finish = LipFinish.natural,
    this.wetness = 1,
    this.reveal,
    this.highlightProgress = 1,
    this.sheen,
    this.shimmerPhase = 0,
    this.stretch = 1,
  });

  final LipShape shape;
  final LipShade shade;
  final LipFinish finish;
  final double wetness;
  final List<double>? reveal;
  final double highlightProgress;
  final double? sheen;
  final double shimmerPhase;

  /// Vertical stretch; hero lips in the designs are drawn a touch plumper.
  final double stretch;

  LipGeometry get _g => LipGeometry.of(shape);

  /// Scale and offset that fit the design space into [size].
  static (double, double, Offset) fit(LipShape shape, Size size, [double stretch = 1]) {
    final g = LipGeometry.of(shape);
    const fullWidth = LipGeometry.designWidth * 1.04;
    final scale = math.min(size.width / fullWidth, size.height / ((LipShape.full.bottomY + 12) * stretch));
    final scaleY = scale * stretch;
    final dx = size.width / 2 - LipGeometry.center * scale;
    final dy = size.height / 2 - (g.height / 2) * scaleY;
    return (scale, scaleY, Offset(dx, dy));
  }

  /// Converts a local x position into a strip index for [reveal].
  static int stripAt(LipShape shape, Size size, double localX, int strips, [double stretch = 1]) {
    final (scale, _, offset) = fit(shape, size, stretch);
    final g = LipGeometry.of(shape);
    final designX = (localX - offset.dx) / scale;
    final t = (designX - g.left) / g.width;
    return (t * strips).floor();
  }

  /// Whether a local point is close enough to the lips to count as a swipe.
  static bool isOverLips(LipShape shape, Size size, Offset local, {double slack = 34, double stretch = 1}) {
    final (scale, scaleY, offset) = fit(shape, size, stretch);
    final g = LipGeometry.of(shape);
    final y = (local.dy - offset.dy) / scaleY;
    final x = (local.dx - offset.dx) / scale;
    return y > -slack / scaleY && y < g.height + slack / scaleY && x > g.left - slack / scale && x < g.left + g.width + slack / scale;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final (scale, scaleY, offset) = fit(shape, size, stretch);
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale, scaleY);

    final strips = reveal;
    final fullyWet = strips == null ? wetness >= 1 : strips.every((a) => a >= 1);
    if (!fullyWet) _paintLayer(canvas, applied: false);

    if (strips == null) {
      if (wetness > 0) {
        if (wetness < 1) {
          canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: wetness));
        }
        _paintLayer(canvas, applied: true);
        if (wetness < 1) canvas.restore();
      }
    } else {
      final g = _g;
      final w = g.width / strips.length;
      final solid = Path();
      for (var i = 0; i < strips.length; i++) {
        final a = strips[i];
        if (a <= 0) continue;
        final rect = Rect.fromLTWH(g.left + i * w - 0.5, -40, w + 1, g.height + 80);
        if (a >= 1) {
          solid.addRect(rect);
        } else {
          canvas.save();
          canvas.clipRect(rect);
          canvas.saveLayer(null, Paint()..color = Colors.white.withValues(alpha: a));
          _paintLayer(canvas, applied: true);
          canvas.restore();
          canvas.restore();
        }
      }
      if (!solid.getBounds().isEmpty) {
        canvas.save();
        canvas.clipPath(solid);
        _paintLayer(canvas, applied: true);
        canvas.restore();
      }
    }

    final sheenAt = sheen;
    if (sheenAt != null && sheenAt > 0 && sheenAt < 1) _paintSheen(canvas, sheenAt);

    canvas.restore();
  }

  Color _tinted(Color base) {
    final tint = finish.tint;
    if (tint == null || finish.tintStrength <= 0) return base;
    return Color.lerp(base, tint, finish.tintStrength)!;
  }

  void _paintLayer(Canvas canvas, {required bool applied}) {
    final g = _g;
    final body = applied ? _tinted(shade.applied) : shade.chapped;
    final shadow = applied ? _tinted(shade.appliedShadow) : shade.chappedShadow;
    final outline = applied ? _tinted(shade.appliedOutline) : shade.chappedOutline;

    canvas.drawPath(g.outer, Paint()..color = body);

    canvas.save();
    canvas.clipPath(g.outer);
    canvas.drawPath(g.shadowBand, Paint()..color = shadow);
    canvas.restore();

    canvas.drawPath(g.mouth, Paint()..color = AppColors.mouth);
    if (shape.showsTeeth) {
      canvas.save();
      canvas.clipPath(g.mouth);
      canvas.drawPath(g.teeth, Paint()..color = AppColors.teeth);
      final line = Paint()
        ..color = AppColors.teethLine
        ..strokeWidth = 3;
      canvas.drawLine(Offset(LipGeometry.center, shape.mouthTopY - 30),
          Offset(LipGeometry.center, shape.mouthBottomY), line);
      canvas.restore();
    }

    canvas.drawPath(
      g.outer,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeJoin = StrokeJoin.round
        ..color = outline,
    );

    if (applied) {
      _paintHighlights(canvas, g);
      if (finish.shimmer) _paintShimmer(canvas, g);
    } else {
      _paintDryness(canvas, g);
    }
  }

  void _paintDryness(Canvas canvas, LipGeometry g) {
    final crackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round
      ..color = shade.chappedOutline.withValues(alpha: 0.8);
    for (final crack in g.cracks) {
      canvas.drawPath(crack, crackPaint);
    }
    final flakePaint = Paint()..color = AppColors.flake.withValues(alpha: 0.95);
    for (final f in g.flakes) {
      canvas.save();
      canvas.translate(f.dx, f.dy);
      canvas.rotate(-0.35);
      canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-9, -4.5, 18, 9), const Radius.circular(3)),
        flakePaint,
      );
      canvas.restore();
    }
  }

  void _paintHighlights(Canvas canvas, LipGeometry g) {
    if (highlightProgress <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 13
      ..strokeCap = StrokeCap.round
      ..color = AppColors.highlight.withValues(alpha: 0.95);

    void draw(Path path) {
      if (highlightProgress >= 1) {
        canvas.drawPath(path, paint);
        return;
      }
      for (final metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * highlightProgress), paint);
      }
    }

    g.highlights.forEach(draw);
    if (finish.extraGloss) {
      paint.color = AppColors.highlight.withValues(alpha: 0.7);
      paint.strokeWidth = 10;
      g.extraHighlights.forEach(draw);
      canvas.save();
      canvas.clipPath(g.outer);
      final glow = Paint()
        ..shader = ui.Gradient.radial(
          Offset(LipGeometry.center, shape.bottomY * 0.8),
          180,
          [Colors.white.withValues(alpha: 0.28 * highlightProgress), Colors.white.withValues(alpha: 0)],
        );
      canvas.drawCircle(Offset(LipGeometry.center, shape.bottomY * 0.8), 180, glow);
      canvas.restore();
    }
  }

  void _paintShimmer(Canvas canvas, LipGeometry g) {
    canvas.save();
    canvas.clipPath(g.outer);
    for (var i = 0; i < g.shimmerDots.length; i++) {
      final twinkle = 0.5 + 0.5 * math.sin(shimmerPhase * math.pi * 2 + i * 1.7);
      final paint = Paint()
        ..color = Color.lerp(const Color(0xFFFFE9A8), const Color(0xFFE2B04A), i % 3 / 2)!
            .withValues(alpha: 0.35 + 0.6 * twinkle);
      canvas.drawCircle(g.shimmerDots[i], 3.5 + 3.5 * twinkle, paint);
    }
    canvas.restore();
  }

  void _paintSheen(Canvas canvas, double t) {
    final g = _g;
    canvas.save();
    canvas.clipPath(g.outer);
    final x = g.left - 200 + (g.width + 400) * t;
    final band = Paint()
      ..shader = ui.Gradient.linear(
        Offset(x - 70, 0),
        Offset(x + 70, g.height * 0.6),
        [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0),
        ],
        const [0, 0.5, 1],
      );
    canvas.drawRect(Rect.fromLTWH(g.left - 40, -20, g.width + 80, g.height + 40), band);
    canvas.restore();
  }

  @override
  bool shouldRepaint(LipsPainter old) =>
      old.shape != shape ||
      old.shade.applied != shade.applied ||
      old.shade.chapped != shade.chapped ||
      old.finish != finish ||
      old.wetness != wetness ||
      old.reveal != reveal ||
      old.highlightProgress != highlightProgress ||
      old.sheen != sheen ||
      old.stretch != stretch ||
      old.shimmerPhase != shimmerPhase;
}

/// Lips that gently breathe, glint every few seconds and smoothly recolour
/// when the shade changes.
class AnimatedLips extends StatefulWidget {
  const AnimatedLips({
    super.key,
    required this.shape,
    required this.shade,
    this.finish = LipFinish.natural,
    this.wet = true,
    this.width = 202,
    this.breathe = true,
    this.glint = true,
    this.float = 0,
    this.stretch = 1,
  });

  final LipShape shape;
  final LipShade shade;
  final LipFinish finish;
  final double stretch;
  final bool wet;
  final double width;
  final bool breathe;
  final bool glint;

  /// Vertical bobbing distance in logical pixels.
  final double float;

  @override
  State<AnimatedLips> createState() => _AnimatedLipsState();
}

class _AnimatedLipsState extends State<AnimatedLips> with TickerProviderStateMixin {
  late final AnimationController _idle =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();
  late LipShade _from = widget.shade;

  @override
  void didUpdateWidget(AnimatedLips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shade.id != widget.shade.id) _from = oldWidget.shade;
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = widget.width * 0.52 * widget.stretch;
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.shade.id),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, colorT, _) {
        final shade = lerpShade(_from, widget.shade, colorT);
        return TweenAnimationBuilder<double>(
          tween: Tween(end: widget.wet ? 1 : 0),
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOut,
          builder: (context, wet, _) => AnimatedBuilder(
            animation: _idle,
            builder: (context, _) {
              final t = _idle.value;
              final breath = widget.breathe ? 1 + 0.018 * math.sin(t * math.pi * 2) : 1.0;
              final bob = widget.float * math.sin(t * math.pi * 2);
              final glintT = widget.glint && wet > 0.5 ? (t * 1.6 - 0.6).clamp(0.0, 1.0) : 0.0;
              return Transform.translate(
                offset: Offset(0, bob),
                child: Transform.scale(
                  scale: breath,
                  child: CustomPaint(
                    size: Size(widget.width, height),
                    painter: LipsPainter(
                      shape: widget.shape,
                      shade: shade,
                      finish: widget.finish,
                      wetness: wet,
                      sheen: glintT > 0 && glintT < 1 ? glintT : null,
                      shimmerPhase: t,
                      stretch: widget.stretch,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
