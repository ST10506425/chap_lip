import 'package:flutter/material.dart';

/// How a product's packaging is drawn.
enum PackageKind {
  /// A squat tub with a screw lid (petroleum jelly, lip masks).
  jar,

  /// A twist up lip balm stick.
  balmStick,

  /// A lipstick bullet in its case, with the cap standing beside it.
  lipstick,

  /// A soft squeeze tube with a flip cap.
  tube,
}

/// Colours used to paint a product's packaging.
class PackageColors {
  const PackageColors({
    required this.cap,
    required this.label,
    this.body = const Color(0xFFFFF9E9),
    this.bullet = const Color(0xFFC4A8CF),
    this.labelText = Colors.white,
  });

  final Color cap;
  final Color label;
  final Color body;
  final Color bullet;
  final Color labelText;

  static const owned = PackageColors(
    cap: Color(0xFFA275B3),
    label: Color(0xFFA275B3),
    bullet: Color(0xFFC4A8CF),
  );

  static const locked = PackageColors(
    cap: Color(0xFFA79CAF),
    label: Color(0xFFA79CAF),
    bullet: Color(0xFFCEC8D2),
  );
}

/// A collectable lip care product.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.kind,
    required this.labelText,
    required this.unlockAt,
    required this.colors,
    required this.panel,
    required this.blurb,
    required this.upgradeWord,
    this.tint,
    this.tintStrength = 0,
    this.shimmer = false,
    this.extraGloss = false,
  });

  final String id;
  final String name;
  final PackageKind kind;
  final String labelText;

  /// Total applications needed to unlock this product.
  final int unlockAt;
  final PackageColors colors;

  /// Background of the celebration panel when the product unlocks.
  final Color panel;
  final String blurb;

  /// "Meet your {upgradeWord} upgrade."
  final String upgradeWord;

  /// Colour the product leaves on the lips (null keeps the natural shade).
  final Color? tint;
  final double tintStrength;

  /// Golden flecks over the lips once applied.
  final bool shimmer;

  /// Adds extra wet look highlights.
  final bool extraGloss;

  bool get isStarter => unlockAt == 0;

  String get kindLabel => switch (kind) {
        PackageKind.jar => 'Balm tub',
        PackageKind.balmStick => 'Lip balm',
        PackageKind.lipstick => 'Lipstick',
        PackageKind.tube => 'Lip mask',
      };

  static const vaseline = Product(
    id: 'vaseline',
    name: 'Vaseline',
    kind: PackageKind.jar,
    labelText: 'Vaseline',
    unlockAt: 0,
    colors: PackageColors(cap: Color(0xFF586FA2), label: Color(0xFF586FA2)),
    panel: Color(0xFFE1E7F4),
    blurb: 'Your first little classic.',
    upgradeWord: 'classic',
  );

  static const roseBalm = Product(
    id: 'rose_balm',
    name: 'Rose balm',
    kind: PackageKind.balmStick,
    labelText: 'ROSE',
    unlockAt: 5,
    colors: PackageColors(cap: Color(0xFFC87395), label: Color(0xFFC87395)),
    panel: Color(0xFFF7DDE8),
    blurb: 'A rosy little balm stick.',
    upgradeWord: 'rosy',
    tint: Color(0xFFEF7897),
    tintStrength: 0.35,
  );

  static const berryGloss = Product(
    id: 'berry_gloss',
    name: 'Berry gloss',
    kind: PackageKind.lipstick,
    labelText: 'BERRY',
    unlockAt: 15,
    colors: PackageColors(
      cap: Color(0xFF8C3A5C),
      label: Color(0xFF8C3A5C),
      bullet: Color(0xFFB8325E),
    ),
    panel: Color(0xFFF3DCE6),
    blurb: 'A juicy berry lipstick.',
    upgradeWord: 'juicy',
    tint: Color(0xFFB8325E),
    tintStrength: 0.75,
    extraGloss: true,
  );

  static const peachButter = Product(
    id: 'peach_butter',
    name: 'Peach butter',
    kind: PackageKind.balmStick,
    labelText: 'PEACH',
    unlockAt: 30,
    colors: PackageColors(cap: Color(0xFFEE9A78), label: Color(0xFFEE9A78)),
    panel: Color(0xFFFCE6D9),
    blurb: 'A buttery peach balm stick.',
    upgradeWord: 'peachy',
    tint: Color(0xFFF4A08A),
    tintStrength: 0.4,
  );

  static const cloudMask = Product(
    id: 'cloud_mask',
    name: 'Cloud mask',
    kind: PackageKind.tube,
    labelText: 'CLOUD',
    unlockAt: 50,
    colors: PackageColors(cap: Color(0xFF8FA5D8), label: Color(0xFF8FA5D8)),
    panel: Color(0xFFE3E9F8),
    blurb: 'An overnight cloud of moisture.',
    upgradeWord: 'dreamy',
    extraGloss: true,
  );

  static const goldenGlow = Product(
    id: 'golden_glow',
    name: 'Golden glow',
    kind: PackageKind.lipstick,
    labelText: 'GLOW',
    unlockAt: 100,
    colors: PackageColors(
      cap: Color(0xFFD4A03E),
      label: Color(0xFFD4A03E),
      bullet: Color(0xFFE0766A),
    ),
    panel: Color(0xFFF8EACB),
    blurb: 'A shimmering golden lipstick.',
    upgradeWord: 'golden',
    tint: Color(0xFFE0766A),
    tintStrength: 0.55,
    shimmer: true,
  );

  static const catalog = [
    vaseline,
    roseBalm,
    berryGloss,
    peachButter,
    cloudMask,
    goldenGlow,
  ];

  static Product byId(String? id) =>
      catalog.firstWhere((p) => p.id == id, orElse: () => vaseline);
}
