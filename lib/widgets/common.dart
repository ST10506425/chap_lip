import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'motion.dart';

/// Standard page: lavender background, safe area, 24px gutters, and a column
/// that fills the phone yet scrolls on shorter screens.
class DesignPage extends StatelessWidget {
  const DesignPage({
    super.key,
    required this.children,
    this.top = 38,
    this.bottom = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.bottomBar,
    this.showBack = false,
  });

  final List<Widget> children;
  final double top;
  final double bottom;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget? bottomBar;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            if (showBack)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.primary,
                    tooltip: 'Back',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
            Expanded(
              child: DesignBody(
                top: showBack ? 8 : top,
                bottom: bottom,
                crossAxisAlignment: crossAxisAlignment,
                children: children,
              ),
            ),
            ?bottomBar,
          ],
        ),
      ),
    );
  }
}

/// Scrollable column that is at least as tall as the space it is given, so
/// [Spacer]s spread content like the designs on a standard phone.
class DesignBody extends StatelessWidget {
  const DesignBody({
    super.key,
    required this.children,
    this.top = 38,
    this.bottom = 16,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final double top;
  final double bottom;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
              child: Column(crossAxisAlignment: crossAxisAlignment, children: children),
            ),
          ),
        ),
      ),
    );
  }
}

/// Eyebrow, headline and supporting line used at the top of most screens.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.eyebrow, required this.title, this.subtitle, this.delayStart = 0});

  final String eyebrow;
  final String title;
  final String? subtitle;
  final int delayStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Reveal(delay: Reveal.step(delayStart), child: Text(eyebrow.toUpperCase(), style: AppText.eyebrow)),
        const SizedBox(height: 14),
        Reveal(delay: Reveal.step(delayStart + 1), child: Text(title, style: AppText.title)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Reveal(delay: Reveal.step(delayStart + 2), child: Text(subtitle!, style: AppText.subtitle)),
        ],
      ],
    );
  }
}

/// Full width purple pill button with press feedback, a loading state and an
/// optional glossy shine that sweeps across it.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed, this.loading = false, this.shine = false});

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool shine;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> with SingleTickerProviderStateMixin {
  late final AnimationController _shine =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200));

  @override
  void initState() {
    super.initState();
    _shine;
    if (widget.shine) _shine.repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return Pressable(
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: widget.onPressed == null ? 0.55 : 1,
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(27),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (widget.shine)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _shine,
                    builder: (context, _) {
                      final t = (_shine.value * 2.2 - 0.6).clamp(-0.6, 1.6);
                      return FractionalTranslation(
                        translation: Offset(t * 1.2 - 0.3, 0),
                        child: Transform.rotate(
                          angle: 0.35,
                          child: FractionallySizedBox(
                            widthFactor: 0.18,
                            alignment: Alignment.centerLeft,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white.withValues(alpha: 0.22),
                                  Colors.white.withValues(alpha: 0),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: widget.loading
                    ? const _LoadingDots(key: ValueKey('dots'))
                    : Text(widget.label, key: ValueKey(widget.label), style: AppText.button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots({super.key});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (_c.value - i * 0.15) * math.pi * 2;
          return Transform.translate(
            offset: Offset(0, -4 * math.max(0, math.sin(phase))),
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
          );
        }),
      ),
    );
  }
}

/// Purple text link with a press bounce.
class TextLink extends StatelessWidget {
  const TextLink(this.text, {super.key, this.onTap, this.style = AppText.link});

  final String text;
  final VoidCallback? onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Text(text, style: style, textAlign: TextAlign.center),
      ),
    );
  }
}

/// Labelled white input with an animated focus ring.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.helper,
    this.error,
    this.autofillHints,
    this.onSubmitted,
    this.enableToggle = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final bool enableToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? helper;
  final String? error;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final hasError = widget.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppText.label.copyWith(fontWeight: FontWeight.w400)),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: 1.5,
              color: hasError
                  ? const Color(0xFFD0527A)
                  : focused
                      ? AppColors.primary
                      : Colors.white,
            ),
            boxShadow: focused
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4))]
                : const [],
          ),
          padding: const EdgeInsets.only(left: 14.5, right: 8),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focus,
                  obscureText: _hidden,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  autofillHints: widget.autofillHints,
                  onSubmitted: widget.onSubmitted,
                  cursorColor: AppColors.primary,
                  style: AppText.input,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: AppText.hint,
                  ),
                ),
              ),
              if (widget.enableToggle)
                IconButton(
                  icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                  color: AppColors.primary,
                  tooltip: _hidden ? 'Show password' : 'Hide password',
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: widget.error != null || widget.helper != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Text(
                    widget.error ?? widget.helper!,
                    style: AppText.small.copyWith(color: hasError ? const Color(0xFFD0527A) : null),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Thin rounded progress track whose fill animates.
class SoftProgress extends StatelessWidget {
  const SoftProgress({super.key, required this.value, this.height = 6, this.from});

  final double value;
  final double? from;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: from ?? 0, end: value.clamp(0, 1)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Container(
        height: height,
        decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(height / 2)),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          child: Container(
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(height / 2)),
          ),
        ),
      ),
    );
  }
}

/// Rounded illustration panel (the big lilac, mint or pink squircle).
class IllustrationPanel extends StatelessWidget {
  const IllustrationPanel({
    super.key,
    required this.color,
    required this.height,
    required this.child,
    this.width,
    this.radius = 96,
  });

  final Color color;
  final double height;
  final double? width;
  final double radius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: child,
    );
  }
}

/// White rounded card.
class SoftCard extends StatelessWidget {
  const SoftCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 16, this.color = Colors.white, this.height});

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: child,
    );
  }
}

/// Floating three tab bar: Moist Up, Collection, You.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  static const labels = ['Moist Up', 'Collection', 'You'];
  static const icons = [Icons.water_drop_rounded, Icons.auto_awesome_rounded, Icons.person_rounded];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 2),
      child: Container(
        height: 70,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: List.generate(labels.length, (i) {
            final active = i == index;
            return Expanded(
              child: Pressable(
                onTap: () => onTap(i),
                pressedScale: 0.9,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: active ? 1 : 0),
                      duration: const Duration(milliseconds: 380),
                      curve: Curves.easeOutBack,
                      builder: (context, t, _) => Transform.scale(
                        scale: 1 + 0.25 * math.sin(t * math.pi),
                        child: Icon(
                          icons[i],
                          size: 24,
                          color: Color.lerp(AppColors.muted, AppColors.primary, t.clamp(0, 1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 260),
                      style: TextStyle(
                        fontFamily: AppText.family,
                        fontSize: 11,
                        height: 1.2,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? AppColors.primary : AppColors.muted,
                      ),
                      child: Text(labels[i]),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Selectable shape used by radio rows and lip cards.
class SelectableTile extends StatelessWidget {
  const SelectableTile({super.key, required this.selected, required this.onTap, required this.child, this.height, this.radius = 16});

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        height: height,
        decoration: BoxDecoration(
          color: selected ? AppColors.lilacSelected : Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: child,
      ),
    );
  }
}

/// Shows a friendly floating message.
void showSoftToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: AppText.label.copyWith(color: Colors.white)),
      backgroundColor: AppColors.ink,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      duration: const Duration(milliseconds: 2600),
    ));
}
