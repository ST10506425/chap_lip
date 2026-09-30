import 'lip_style.dart';
import 'product.dart';

/// A locally stored account.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    required this.lipShape,
    required this.lipShade,
    required this.activeProductId,
    required this.onboarded,
  });

  final int id;
  final String name;
  final String email;
  final String? gender;
  final LipShape lipShape;
  final LipShade lipShade;
  final String activeProductId;
  final bool onboarded;

  /// "Glossy Sarah" from the first word of the name, or "Glossy human".
  String get glossyName {
    final first = name.trim().split(RegExp(r'\s+')).first;
    return first.isEmpty ? 'Glossy human' : 'Glossy ${first[0].toUpperCase()}${first.substring(1)}';
  }

  factory UserProfile.fromRow(Map<String, Object?> row) => UserProfile(
        id: row['id'] as int,
        name: row['name'] as String,
        email: row['email'] as String,
        gender: row['gender'] as String?,
        lipShape: LipShape.fromName(row['lip_shape'] as String?),
        lipShade: LipShade.fromId(row['lip_shade'] as String?),
        activeProductId: (row['active_product'] as String?) ?? 'vaseline',
        onboarded: (row['onboarded'] as int? ?? 0) == 1,
      );

  UserProfile copyWith({
    String? name,
    String? email,
    String? gender,
    LipShape? lipShape,
    LipShade? lipShade,
    String? activeProductId,
    bool? onboarded,
  }) =>
      UserProfile(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        gender: gender ?? this.gender,
        lipShape: lipShape ?? this.lipShape,
        lipShade: lipShade ?? this.lipShade,
        activeProductId: activeProductId ?? this.activeProductId,
        onboarded: onboarded ?? this.onboarded,
      );
}

/// Progress numbers shown on the Play, Collection and Profile screens.
class LipStats {
  const LipStats({
    required this.applications,
    required this.unlocked,
    required this.usedProducts,
    required this.streakDays,
    this.lastAppliedAt,
    this.lastProductId,
  });

  static const empty = LipStats(
    applications: 0,
    unlocked: {'vaseline'},
    usedProducts: {},
    streakDays: 0,
  );

  final int applications;
  final Set<String> unlocked;

  /// Products that have been applied at least once.
  final Set<String> usedProducts;
  final int streakDays;
  final DateTime? lastAppliedAt;
  final String? lastProductId;

  /// When the last application wears off, based on the product used.
  DateTime? get moistUntil => lastAppliedAt?.add(Product.byId(lastProductId).lastsFor);

  int get level => (1 + applications ~/ 10).clamp(1, 99);
  String get levelLabel => level.toString().padLeft(2, '0');
}
