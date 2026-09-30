import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fades and slides its child up into place after [delay].
class Reveal extends StatefulWidget {
  const Reveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 18,
    this.duration = const Duration(milliseconds: 520),
    this.scale = 1,
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;

  /// Starting scale, for elements that should pop in.
  final double scale;

  /// Standard gap between staggered items.
  static Duration step(int i) => Duration(milliseconds: 60 + i * 70);

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) {
        final v = _curve.value;
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * widget.offset),
            child: widget.scale == 1 ? child : Transform.scale(scale: widget.scale + (1 - widget.scale) * v, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Shrinks slightly while pressed and springs back, with a light haptic tick.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, this.onTap, this.pressedScale = 0.96, this.haptic = true});

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final bool haptic;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
              if (widget.haptic) HapticFeedback.selectionClick();
              widget.onTap!();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1,
        duration: Duration(milliseconds: _down ? 90 : 260),
        curve: _down ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// Horizontal shake used to flag a validation problem.
class Shake extends StatefulWidget {
  const Shake({super.key, required this.trigger, required this.child});

  /// Increment to shake.
  final int trigger;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(Shake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      HapticFeedback.lightImpact();
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = _c.value;
        final dx = (1 - t) * 10 * math.sin(t * math.pi * 10);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: widget.child,
    );
  }
}

/// Counts smoothly up to [value].
class CountUp extends StatelessWidget {
  const CountUp({super.key, required this.value, required this.style, this.pad = 0});

  final int value;
  final TextStyle style;
  final int pad;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(v.round().toString().padLeft(pad, '0'), style: style),
    );
  }
}

/// Page transition: the new screen fades in while rising slightly.
class SoftRoute<T> extends PageRouteBuilder<T> {
  SoftRoute({required WidgetBuilder builder, super.fullscreenDialog})
      : super(
          transitionDuration: const Duration(milliseconds: 480),
          reverseTransitionDuration: const Duration(milliseconds: 360),
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, animation, secondary, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);
            final out = CurvedAnimation(parent: secondary, curve: Curves.easeInOut);
            return FadeTransition(
              opacity: ReverseAnimation(out).drive(Tween(begin: 0.4, end: 1)),
              child: FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: curved.drive(Tween(begin: const Offset(0, 0.045), end: Offset.zero)),
                  child: ScaleTransition(
                    scale: curved.drive(Tween(begin: 0.985, end: 1)),
                    child: child,
                  ),
                ),
              ),
            );
          },
        );
}

/// Celebration transition: the new screen blooms out from the centre.
class BloomRoute<T> extends PageRouteBuilder<T> {
  BloomRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: const Duration(milliseconds: 650),
          reverseTransitionDuration: const Duration(milliseconds: 380),
          pageBuilder: (context, _, _) => builder(context),
          transitionsBuilder: (context, animation, _, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
              child: ScaleTransition(scale: curved.drive(Tween(begin: 0.88, end: 1)), child: child),
            );
          },
        );
}
