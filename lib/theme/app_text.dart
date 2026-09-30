import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale used across every screen (Inter, bundled in assets/fonts).
class AppText {
  AppText._();

  static const family = 'Inter';

  static const eyebrow = TextStyle(
    fontFamily: family,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.3,
    height: 1.25,
  );

  static const title = TextStyle(
    fontFamily: family,
    fontSize: 29,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.6,
    height: 1.2,
  );

  static const hero = TextStyle(
    fontFamily: family,
    fontSize: 33,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.7,
    height: 1.34,
  );

  static const subtitle = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.3,
  );

  static const section = TextStyle(
    fontFamily: family,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static const label = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.ink,
    height: 1.25,
  );

  static const input = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.25,
  );

  static const hint = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.25,
  );

  static const small = TextStyle(
    fontFamily: family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.35,
  );

  static const button = TextStyle(
    fontFamily: family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.2,
  );

  static const link = TextStyle(
    fontFamily: family,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.25,
  );

  static const cardTitle = TextStyle(
    fontFamily: family,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    height: 1.25,
  );
}
