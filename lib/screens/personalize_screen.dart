import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/motion.dart';
import 'choose_lips_screen.dart';

const identityOptions = ['Female', 'Male'];

/// 04 Personalize: how do you identify?
class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  late String _choice = context.read<AppState>().user?.gender ?? identityOptions.last;
  bool _busy = false;

  Future<void> _next() async {
    setState(() => _busy = true);
    await context.read<AppState>().saveGender(_choice);
    if (!mounted) return;
    setState(() => _busy = false);
    Navigator.of(context).push(SoftRoute(builder: (_) => const ChooseLipsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      bottom: 40,
      children: [
        const ScreenHeader(
          eyebrow: 'Make it yours · 1 of 2',
          title: 'Your vibe. Your way.',
          subtitle: 'A few details for your little digital world.',
        ),
        const SizedBox(height: 37),
        Reveal(delay: Reveal.step(3), child: const SoftProgress(value: 0.5)),
        const SizedBox(height: 37),
        Reveal(delay: Reveal.step(4), child: const Text('How do you identify?', style: AppText.section)),
        const SizedBox(height: 10),
        Reveal(
          delay: Reveal.step(4),
          child: Text('Optional. Every lip style is for everyone.', style: AppText.subtitle.copyWith(fontSize: 13)),
        ),
        const SizedBox(height: 29),
        IdentityOptions(value: _choice, onChanged: (v) => setState(() => _choice = v), delayStart: 5),
        const Spacer(),
        const SizedBox(height: 32),
        Reveal(
          delay: Reveal.step(9),
          child: PrimaryButton(label: 'Next: choose your lips', loading: _busy, onPressed: _next),
        ),
        const SizedBox(height: 20),
        Reveal(
          delay: Reveal.step(10),
          child: const Center(child: Text('You can change this anytime.', style: AppText.small)),
        ),
      ],
    );
  }
}

/// The two identity rows with animated radio dots.
class IdentityOptions extends StatelessWidget {
  const IdentityOptions({super.key, required this.value, required this.onChanged, this.delayStart = 0, this.gap = 14, this.height = 56});

  final String value;
  final ValueChanged<String> onChanged;
  final int delayStart;
  final double gap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < identityOptions.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          Reveal(
            delay: Reveal.step(delayStart + i),
            child: SelectableTile(
              height: height,
              selected: value == identityOptions[i],
              onTap: () => onChanged(identityOptions[i]),
              child: Padding(
                padding: const EdgeInsets.only(left: 18, right: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(identityOptions[i], style: AppText.label.copyWith(fontSize: 15)),
                    ),
                    _RadioDot(selected: value == identityOptions[i]),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: selected ? 1 : 0),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, t, _) => Transform.scale(
        scale: 1 + 0.18 * (t * (1 - t) * 4).clamp(0, 1),
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(AppColors.track, AppColors.primary, t.clamp(0, 1)),
          ),
        ),
      ),
    );
  }
}
