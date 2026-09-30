import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/lips.dart';
import '../widgets/motion.dart';
import 'choose_lips_screen.dart';
import 'edit_details_screen.dart';
import 'welcome_screen.dart';

/// 10 Your profile.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<AppState>().logOut();
    navigator.pushAndRemoveUntil(SoftRoute(builder: (_) => const WelcomeScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();
    final stats = state.stats;

    return DesignBody(
      bottom: 16,
      children: [
        const ScreenHeader(
          eyebrow: 'Your tiny corner',
          title: 'Made for you.',
          subtitle: 'Keep your pout, preferences and progress\ntogether.',
        ),
        const SizedBox(height: 31),
        Reveal(
          delay: Reveal.step(3),
          scale: 0.95,
          child: SoftCard(
            radius: 24,
            height: 151,
            padding: const EdgeInsets.only(left: 22, right: 12),
            child: Row(
              children: [
                AnimatedLips(
                  shape: user.lipShape,
                  shade: user.lipShade,
                  finish: LipFinish.of(state.activeProduct),
                  width: 150,
                  float: 2,
                ),
                const SizedBox(width: 23),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayName(user.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.section.copyWith(fontSize: 17, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 10),
                      Text('${user.lipShape.label} · ${user.lipShade.label}', style: AppText.subtitle.copyWith(fontSize: 13)),
                      const SizedBox(height: 1),
                      Text('Level ${stats.levelLabel}', style: AppText.subtitle.copyWith(fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Reveal(
          delay: Reveal.step(4),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: stats.applications,
                  label: 'applications',
                  color: AppColors.lilacSelected,
                  valueColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _StatCard(
                  value: stats.unlocked.length,
                  label: 'products unlocked',
                  color: AppColors.mint,
                  valueColor: AppColors.ink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Reveal(
          delay: Reveal.step(5),
          child: _MenuRow(
            label: 'Customize my lips',
            onTap: () => Navigator.of(context).push(SoftRoute(builder: (_) => const ChooseLipsScreen(editing: true))),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: Reveal.step(6),
          child: _MenuRow(
            label: 'Edit my details',
            onTap: () => Navigator.of(context).push(SoftRoute(builder: (_) => const EditDetailsScreen())),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(delay: Reveal.step(7), child: _MenuRow(label: 'Log out', onTap: () => _logOut(context))),
        const Spacer(),
      ],
    );
  }

  static String _displayName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Glossy human';
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.color, required this.valueColor});

  final int value;
  final String label;
  final Color color;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const SizedBox(height: 17),
          CountUp(
            value: value,
            style: AppText.title.copyWith(fontSize: 27, color: valueColor, height: 1.2),
          ),
          const SizedBox(height: 10),
          Text(label, style: AppText.small.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: Container(
        height: 50,
        padding: const EdgeInsets.only(left: 16, right: 26),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppText.label)),
            Text('›', style: AppText.link.copyWith(fontSize: 17, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
