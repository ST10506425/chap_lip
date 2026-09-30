import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_text.dart';

/// Draws a product's packaging inside an 84 x 71 design box (the size of the
/// Vaseline tub on the Play screen), scaled to [width].
class ProductArt extends StatelessWidget {
  const ProductArt({
    super.key,
    required this.product,
    this.width = 84,
    this.colors,
    this.label,
  });

  final Product product;
  final double width;

  /// Overrides the product's own colours (owned and locked shelf states).
  final PackageColors? colors;

  /// Overrides the label text ("?" for locked items).
  final String? label;

  static const designWidth = 84.0;
  static const designHeight = 71.0;

  @override
  Widget build(BuildContext context) {
    final scale = width / designWidth;
    return SizedBox(
      width: width,
      height: designHeight * scale,
      child: CustomPaint(
        painter: _PackagePainter(
          kind: product.kind,
          colors: colors ?? product.colors,
          label: label ?? product.labelText,
          scale: scale,
        ),
      ),
    );
  }
}

class _PackagePainter extends CustomPainter {
  _PackagePainter({
    required this.kind,
    required this.colors,
    required this.label,
    required this.scale,
  });

  final PackageKind kind;
  final PackageColors colors;
  final String label;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(scale);
    switch (kind) {
      case PackageKind.jar:
        _jar(canvas);
      case PackageKind.balmStick:
        _balmStick(canvas);
      case PackageKind.lipstick:
        _lipstick(canvas);
      case PackageKind.tube:
        _tube(canvas);
    }
    canvas.restore();
  }

  void _label(Canvas canvas, Rect rect, {double radius = 8, double fontSize = 10, double angle = 0}) {
    canvas.save();
    if (angle != 0) {
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(angle);
      canvas.translate(-rect.center.dx, -rect.center.dy);
    }
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)), Paint()..color = colors.label);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: AppText.family,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: colors.labelText,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: rect.width - 4);
    tp.paint(canvas, rect.center - Offset(tp.width / 2, tp.height / 2));
    canvas.restore();
  }

  /// Squat tub with a wide screw lid.
  void _jar(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(8, 18, 76, 71,
          bottomLeft: const Radius.circular(14), bottomRight: const Radius.circular(14)),
      Paint()..color = colors.body,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, 84, 20), const Radius.circular(6)),
      Paint()..color = colors.cap,
    );
    _label(canvas, const Rect.fromLTWH(13, 27, 58, 27));
  }

  /// Twist up balm stick, lying at a jaunty angle with its cap on.
  void _balmStick(Canvas canvas) {
    canvas.save();
    canvas.translate(42, 37);
    canvas.rotate(-math.pi / 5.2);
    const w = 25.0;
    const len = 84.0;
    // Body (cream barrel).
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(-len / 2 + 32, -w / 2, len / 2, w / 2,
          topRight: const Radius.circular(6), bottomRight: const Radius.circular(6)),
      Paint()..color = colors.body,
    );
    // Twist ring at the base.
    canvas.drawRRect(
      RRect.fromLTRBR(len / 2 - 8, -w / 2 - 1, len / 2, w / 2 + 1, const Radius.circular(4)),
      Paint()..color = colors.cap.withValues(alpha: 0.55),
    );
    // Cap.
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(-len / 2, -w / 2 - 1.5, -len / 2 + 33, w / 2 + 1.5,
          topLeft: const Radius.circular(9),
          bottomLeft: const Radius.circular(9),
          topRight: const Radius.circular(3),
          bottomRight: const Radius.circular(3)),
      Paint()..color = colors.cap,
    );
    canvas.drawRect(
      Rect.fromLTRB(-len / 2 + 31, -w / 2 - 1.5, -len / 2 + 34, w / 2 + 1.5),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    // Shine along the cap.
    canvas.drawRRect(
      RRect.fromLTRBR(-len / 2 + 6, -w / 2 + 3, -len / 2 + 26, -w / 2 + 6, const Radius.circular(2)),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    canvas.restore();
    // Label wraps the barrel.
    canvas.save();
    canvas.translate(42, 37);
    canvas.rotate(-math.pi / 5.2);
    _label(canvas, const Rect.fromLTWH(-4, -9, 34, 18), radius: 5, fontSize: 7.5);
    canvas.restore();
  }

  /// Lipstick bullet in its case, with the cap standing beside it.
  void _lipstick(Canvas canvas) {
    final bullet = Paint()..color = colors.bullet;
    // Bullet with its slanted tip.
    final tip = Path()
      ..moveTo(15, 30)
      ..lineTo(15, 14)
      ..quadraticBezierTo(15, 6, 22, 3)
      ..lineTo(35, 0)
      ..quadraticBezierTo(37, 0, 37, 3)
      ..lineTo(37, 30)
      ..close();
    canvas.drawPath(tip, bullet);
    canvas.drawRect(
      const Rect.fromLTWH(18, 9, 3, 18),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
    // Inner sleeve.
    canvas.drawRect(const Rect.fromLTWH(12, 29, 28, 9), Paint()..color = colors.cap.withValues(alpha: 0.55));
    // Case.
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(9, 37, 43, 71,
          bottomLeft: const Radius.circular(6),
          bottomRight: const Radius.circular(6),
          topLeft: const Radius.circular(2),
          topRight: const Radius.circular(2)),
      Paint()..color = colors.cap,
    );
    canvas.drawRect(const Rect.fromLTWH(9, 42, 34, 3), Paint()..color = Colors.white.withValues(alpha: 0.35));
    // Cap standing to the right.
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(50, 22, 80, 71,
          topLeft: const Radius.circular(7),
          topRight: const Radius.circular(7),
          bottomLeft: const Radius.circular(4),
          bottomRight: const Radius.circular(4)),
      Paint()..color = colors.cap,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(50, 62, 80, 71, const Radius.circular(4)),
      Paint()..color = colors.body,
    );
    _label(canvas, const Rect.fromLTWH(53, 36, 24, 16), radius: 4, fontSize: 5.8);
  }

  /// Soft squeeze tube with a crimped end and flip cap.
  void _tube(Canvas canvas) {
    canvas.save();
    canvas.translate(42, 36);
    canvas.rotate(-0.28);
    final body = Path()
      ..moveTo(-19, -34)
      ..lineTo(19, -34)
      ..quadraticBezierTo(22, 5, 15, 22)
      ..lineTo(-15, 22)
      ..quadraticBezierTo(-22, 5, -19, -34)
      ..close();
    canvas.drawPath(body, Paint()..color = colors.body);
    // Crimped end.
    canvas.drawRRect(
      RRect.fromLTRBR(-21, -38, 21, -31, const Radius.circular(2)),
      Paint()..color = colors.cap.withValues(alpha: 0.6),
    );
    for (var i = -3; i <= 3; i++) {
      canvas.drawLine(
        Offset(i * 5.5, -37),
        Offset(i * 5.5, -32),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.55)
          ..strokeWidth = 1.2,
      );
    }
    // Flip cap.
    canvas.drawRRect(
      RRect.fromLTRBAndCorners(-15, 20, 15, 36,
          bottomLeft: const Radius.circular(6), bottomRight: const Radius.circular(6)),
      Paint()..color = colors.cap,
    );
    canvas.drawRect(const Rect.fromLTRB(-15, 24, 15, 25.5), Paint()..color = Colors.white.withValues(alpha: 0.45));
    canvas.restore();
    canvas.save();
    canvas.translate(42, 36);
    canvas.rotate(-0.28);
    _label(canvas, const Rect.fromLTWH(-15, -18, 30, 17), radius: 5, fontSize: 6.8);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PackagePainter old) =>
      old.kind != kind || old.colors != colors || old.label != label || old.scale != scale;
}
