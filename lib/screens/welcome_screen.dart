import 'package:flutter/material.dart';

import '../models/lip_style.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/lips.dart';
import '../widgets/motion.dart';
import 'log_in_screen.dart';
import 'sign_up_screen.dart';

/// 01 Welcome.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      top: 40,
      bottom: 53,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Reveal(
          delay: Reveal.step(0),
          child: Text(
            'moist-me-up',
            style: AppText.title.copyWith(fontSize: 20, color: AppColors.primary, letterSpacing: -0.2, height: 1.25),
          ),
        ),
        const SizedBox(height: 26),
        Reveal(
          delay: Reveal.step(1),
          child: const Text('A little swipe.\nA lot of happy.', textAlign: TextAlign.center, style: AppText.hero),
        ),
        const SizedBox(height: 27),
        Reveal(
          delay: Reveal.step(2),
          scale: 0.92,
          offset: 10,
          duration: const Duration(milliseconds: 700),
          child: const _HeroPanel(),
        ),
        const SizedBox(height: 30),
        Reveal(
          delay: Reveal.step(4),
          child: const Text(
            'Real-life chapped? Give your digital lips\na little love. Swipe, play, unlock.',
            textAlign: TextAlign.center,
            style: AppText.subtitle,
          ),
        ),
        const Spacer(),
        const SizedBox(height: 40),
        Reveal(
          delay: Reveal.step(5),
          child: PrimaryButton(
            label: 'Let’s get glossy',
            shine: true,
            onPressed: () => Navigator.of(context).push(SoftRoute(builder: (_) => const SignUpScreen())),
          ),
        ),
        const SizedBox(height: 21),
        Reveal(
          delay: Reveal.step(6),
          child: TextLink(
            'Already a member? Log in',
            onTap: () => Navigator.of(context).push(SoftRoute(builder: (_) => const LogInScreen())),
          ),
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return IllustrationPanel(
      color: AppColors.lilac,
      height: 288,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(left: 0, top: 174, child: DriftingBlob(color: AppColors.mint, width: 130, height: 108)),
          const Positioned(
            right: 0,
            top: 193,
            child: DriftingBlob(color: AppColors.peach, width: 110, height: 90, phase: 0.5, period: Duration(seconds: 7)),
          ),
          const Positioned(
            right: 73,
            top: 26,
            child: DriftingBlob(color: AppColors.butter, width: 28, height: 28, drift: 3, period: Duration(seconds: 4)),
          ),
          const Positioned(left: 46, top: 56, child: Sparkle(size: 24)),
          const Positioned(right: 54, top: 148, child: Sparkle(size: 18, delay: Duration(milliseconds: 700))),
          Positioned.fill(
            bottom: 26,
            child: Center(
              child: AnimatedLips(shape: LipShape.full, shade: LipShade.rose, width: 210, float: 4, stretch: 1.06),
            ),
          ),
        ],
      ),
    );
  }
}
