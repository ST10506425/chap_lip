import 'package:flutter/material.dart';

/// The four pout shapes offered during onboarding.
///
/// Geometry is described in a 760-unit wide design space (corner to corner)
/// with the top of the cupid's bow peaks at y = 0. The lip painter scales the
/// shape to whatever size it is drawn at.
enum LipShape {
  soft(
    label: 'Soft',
    widthScale: 0.99,
    cornerY: 168,
    peakOffset: 112,
    bowY: 28,
    bowSharpness: 0.2,
    mouthTopY: 161,
    mouthBottomY: 177,
    bottomY: 360,
    teethHalfWidth: 0,
  ),
  full(
    label: 'Full',
    widthScale: 1.0,
    cornerY: 177,
    peakOffset: 125,
    bowY: 25,
    bowSharpness: 0.25,
    mouthTopY: 147,
    mouthBottomY: 225,
    bottomY: 370,
    teethHalfWidth: 182,
  ),
  cupid(
    label: 'Cupid',
    widthScale: 0.9,
    cornerY: 186,
    peakOffset: 118,
    bowY: 48,
    bowSharpness: 0.85,
    mouthTopY: 156,
    mouthBottomY: 233,
    bottomY: 383,
    teethHalfWidth: 178,
  ),
  wide(
    label: 'Wide',
    widthScale: 1.035,
    cornerY: 150,
    peakOffset: 122,
    bowY: 20,
    bowSharpness: 0.2,
    mouthTopY: 124,
    mouthBottomY: 192,
    bottomY: 322,
    teethHalfWidth: 180,
  );

  const LipShape({
    required this.label,
    required this.widthScale,
    required this.cornerY,
    required this.peakOffset,
    required this.bowY,
    required this.bowSharpness,
    required this.mouthTopY,
    required this.mouthBottomY,
    required this.bottomY,
    required this.teethHalfWidth,
  });

  final String label;
  final double widthScale;
  final double cornerY;
  final double peakOffset;
  final double bowY;
  final double bowSharpness;
  final double mouthTopY;
  final double mouthBottomY;
  final double bottomY;
  final double teethHalfWidth;

  bool get showsTeeth => teethHalfWidth > 0;

  static LipShape fromName(String? name) =>
      LipShape.values.firstWhere((s) => s.name == name, orElse: () => LipShape.full);
}

/// A natural lip shade, with the palette used for its chapped and
/// moisturised states.
class LipShade {
  const LipShade({
    required this.id,
    required this.label,
    required this.swatch,
    required this.applied,
    required this.appliedShadow,
    required this.appliedOutline,
    required this.chapped,
    required this.chappedShadow,
    required this.chappedOutline,
  });

  final String id;
  final String label;
  final Color swatch;
  final Color applied;
  final Color appliedShadow;
  final Color appliedOutline;
  final Color chapped;
  final Color chappedShadow;
  final Color chappedOutline;

  static const petal = LipShade(
    id: 'petal',
    label: 'Petal',
    swatch: Color(0xFFF3ADAD),
    applied: Color(0xFFF69AA3),
    appliedShadow: Color(0xFFE8858F),
    appliedOutline: Color(0xFFA9505C),
    chapped: Color(0xFFD9A7A8),
    chappedShadow: Color(0xFFC69495),
    chappedOutline: Color(0xFFA06F72),
  );

  static const blush = LipShade(
    id: 'blush',
    label: 'Blush',
    swatch: Color(0xFFDB8DA0),
    applied: Color(0xFFF287A4),
    appliedShadow: Color(0xFFDF7191),
    appliedOutline: Color(0xFF923F59),
    chapped: Color(0xFFCE9AA4),
    chappedShadow: Color(0xFFBC8793),
    chappedOutline: Color(0xFF9B6878),
  );

  static const rose = LipShade(
    id: 'rose',
    label: 'Rose',
    swatch: Color(0xFFCC7897),
    applied: Color(0xFFEF7897),
    appliedShadow: Color(0xFFDB6285),
    appliedOutline: Color(0xFF85334F),
    chapped: Color(0xFFC98F99),
    chappedShadow: Color(0xFFB77D8A),
    chappedOutline: Color(0xFF956273),
  );

  static const mauve = LipShade(
    id: 'mauve',
    label: 'Mauve',
    swatch: Color(0xFFAA6677),
    applied: Color(0xFFCB5E7D),
    appliedShadow: Color(0xFFB34C6B),
    appliedOutline: Color(0xFF6E2840),
    chapped: Color(0xFFA97D87),
    chappedShadow: Color(0xFF986D78),
    chappedOutline: Color(0xFF7A5160),
  );

  static const plum = LipShade(
    id: 'plum',
    label: 'Plum',
    swatch: Color(0xFF804B57),
    applied: Color(0xFFA03D58),
    appliedShadow: Color(0xFF882E48),
    appliedOutline: Color(0xFF4F1A2C),
    chapped: Color(0xFF8B616A),
    chappedShadow: Color(0xFF7B545D),
    chappedOutline: Color(0xFF5E3E48),
  );

  static const cocoa = LipShade(
    id: 'cocoa',
    label: 'Cocoa',
    swatch: Color(0xFF593941),
    applied: Color(0xFF773343),
    appliedShadow: Color(0xFF632636),
    appliedOutline: Color(0xFF36141E),
    chapped: Color(0xFF6C4E55),
    chappedShadow: Color(0xFF5E434A),
    chappedOutline: Color(0xFF452F35),
  );

  static const all = [petal, blush, rose, mauve, plum, cocoa];

  static LipShade fromId(String? id) =>
      all.firstWhere((s) => s.id == id, orElse: () => rose);
}
