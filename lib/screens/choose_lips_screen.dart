import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lip_style.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/lips.dart';
import '../widgets/motion.dart';
import 'home_shell.dart';

/// 05 Choose lips: pick a pout and a shade. Also used from the profile to
/// customise the lips later ([editing]).
class ChooseLipsScreen extends StatefulWidget {
  const ChooseLipsScreen({super.key, this.editing = false});

  final bool editing;

  @override
  State<ChooseLipsScreen> createState() => _ChooseLipsScreenState();
}

class _ChooseLipsScreenState extends State<ChooseLipsScreen> {
  late LipShape _shape = context.read<AppState>().user?.lipShape ?? LipShape.full;
  late LipShade _shade = context.read<AppState>().user?.lipShade ?? LipShade.rose;
  bool _busy = false;

  Future<void> _save() async {
    setState(() => _busy = true);
    await context.read<AppState>().saveLips(_shape, _shade);
    if (!mounted) return;
    if (widget.editing) {
      Navigator.of(context).pop();
      showSoftToast(context, 'Fresh pout saved.');
    } else {
      Navigator.of(context).pushAndRemoveUntil(SoftRoute(builder: (_) => const HomeShell()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      bottom: 56,
      showBack: widget.editing,
      children: [
        ScreenHeader(
          eyebrow: widget.editing ? 'Your pout' : 'Make it yours · 2 of 2',
          title: 'Pick your pout.',
          subtitle: 'Choose a shape and shade that feels like you.',
        ),
        const SizedBox(height: 37),
        Reveal(delay: Reveal.step(3), child: SoftProgress(value: 1, from: widget.editing ? 1 : 0.5)),
        const SizedBox(height: 30),
        _ShapeGrid(
          shape: _shape,
          shade: _shade,
          onChanged: (s) => setState(() => _shape = s),
        ),
        const SizedBox(height: 40),
        Reveal(
          delay: Reveal.step(8),
          child: Text('Your shade', style: AppText.label.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 18),
        Reveal(
          delay: Reveal.step(9),
          child: _ShadePicker(value: _shade, onChanged: (s) => setState(() => _shade = s)),
        ),
        const SizedBox(height: 21),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SlideTransition(position: a.drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero)), child: child),
            ),
            child: Text(
              '${_shape.label} lips · ${_shade.label}',
              key: ValueKey('${_shape.name}${_shade.id}'),
              style: AppText.subtitle.copyWith(fontSize: 13),
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 32),
        Reveal(
          delay: Reveal.step(10),
          child: PrimaryButton(
            label: widget.editing ? 'Save my lips' : 'Meet my digital lips',
            loading: _busy,
            onPressed: _save,
          ),
        ),
      ],
    );
  }
}

class _ShapeGrid extends StatelessWidget {
  const _ShapeGrid({required this.shape, required this.shade, required this.onChanged});

  final LipShape shape;
  final LipShade shade;
  final ValueChanged<LipShape> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget card(LipShape s, int i) => Expanded(
          child: Reveal(
            delay: Reveal.step(4 + i),
            scale: 0.94,
            child: SelectableTile(
              height: 126,
              radius: 20,
              selected: s == shape,
              onTap: () => onChanged(s),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  AnimatedScale(
                    scale: s == shape ? 1.08 : 1,
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.elasticOut,
                    child: AnimatedLips(
                      shape: s,
                      shade: shade,
                      width: 94,
                      breathe: s == shape,
                      glint: s == shape,
                    ),
                  ),
                  const Spacer(),
                  Text(s.label, style: AppText.label.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );

    return Column(
      children: [
        Row(children: [card(LipShape.soft, 0), const SizedBox(width: 14), card(LipShape.full, 1)]),
        const SizedBox(height: 16),
        Row(children: [card(LipShape.cupid, 2), const SizedBox(width: 14), card(LipShape.wide, 3)]),
      ],
    );
  }
}

class _ShadePicker extends StatelessWidget {
  const _ShadePicker({required this.value, required this.onChanged});

  final LipShade value;
  final ValueChanged<LipShade> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (final shade in LipShade.all)
          Pressable(
            onTap: () => onChanged(shade),
            pressedScale: 0.85,
            child: AnimatedScale(
              scale: shade.id == value.id ? 1.1 : 1,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: shade.swatch,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: shade.id == value.id ? Colors.white : Colors.white.withValues(alpha: 0),
                    width: 2.5,
                  ),
                  boxShadow: shade.id == value.id
                      ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.18), blurRadius: 10, offset: const Offset(0, 3))]
                      : const [],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
