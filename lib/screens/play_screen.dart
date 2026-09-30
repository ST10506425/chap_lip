import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/user_profile.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/lips.dart';
import '../widgets/motion.dart';
import '../widgets/product_art.dart';

/// 06 Play: chapped lips waiting for a little love.
///
/// Swipe a finger across the lips, drag the product onto them, or tap the
/// button to watch it glide across. Each strip of the lips turns glossy as it
/// is covered; once most of the mouth is done the rest fills in, the gloss
/// highlights draw on and the application is saved.
class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.onApplied});

  final ValueChanged<ApplicationResult> onApplied;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> with TickerProviderStateMixin {
  static const _strips = 28;
  static const _lipsSize = Size(210, 116);
  static const _stretch = 1.05;

  final _lipsKey = GlobalKey();
  final List<double> _reveal = List.filled(_strips, 0);
  final List<bool> _covered = List.filled(_strips, false);

  late final Ticker _fadeTicker = createTicker(_onFadeTick);
  Duration _lastTick = Duration.zero;

  late final AnimationController _auto =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1700))
        ..addListener(_onAutoTick)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) _completeCoverage();
        });
  late final AnimationController _finish =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final AnimationController _hint =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 4200))..repeat();

  Offset? _applicator;
  bool _touched = false;
  bool _finishing = false;
  bool _saving = false;
  int _burst = 0;

  double get _coverage => _covered.where((c) => c).length / _strips;

  @override
  void initState() {
    super.initState();
    // Create every ticker now, never lazily during dispose.
    _fadeTicker;
    _auto;
    _finish;
    _hint;
  }

  @override
  void dispose() {
    _fadeTicker.dispose();
    _auto.dispose();
    _finish.dispose();
    _hint.dispose();
    super.dispose();
  }

  // Strip fading

  void _onFadeTick(Duration elapsed) {
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    var moving = false;
    for (var i = 0; i < _strips; i++) {
      if (_covered[i] && _reveal[i] < 1) {
        _reveal[i] = math.min(1, _reveal[i] + dt * 5.5);
        moving = true;
      }
    }
    setState(() {});
    if (!moving) {
      _fadeTicker.stop();
      _lastTick = Duration.zero;
    }
  }

  void _cover(int index) {
    var changed = false;
    for (var i = index - 1; i <= index + 1; i++) {
      if (i >= 0 && i < _strips && !_covered[i]) {
        _covered[i] = true;
        changed = true;
      }
    }
    if (!changed) return;
    if (!_fadeTicker.isActive) {
      _lastTick = Duration.zero;
      _fadeTicker.start();
    }
    if (_covered.where((c) => c).length % 4 == 0) HapticFeedback.selectionClick();
    if (_coverage >= 0.82) _completeCoverage();
  }

  /// Applies at a point given in global coordinates.
  void _applyAtGlobal(Offset global) {
    if (_finishing) return;
    final box = _lipsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(global);
    final shape = context.read<AppState>().user!.lipShape;
    setState(() {
      _touched = true;
      _applicator = local;
    });
    if (!LipsPainter.isOverLips(shape, box.size, local, stretch: _stretch)) return;
    _cover(LipsPainter.stripAt(shape, box.size, local.dx, _strips, _stretch));
  }

  // Auto glide

  void _startAuto() {
    if (_finishing || _auto.isAnimating) return;
    HapticFeedback.lightImpact();
    setState(() => _touched = true);
    _auto.forward(from: 0);
  }

  void _onAutoTick() {
    final box = _lipsKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final t = Curves.easeInOutSine.transform(_auto.value);
    final local = Offset(
      box.size.width * (0.06 + 0.88 * t),
      box.size.height * (0.5 + 0.18 * math.sin(t * math.pi * 3)),
    );
    _applyAtGlobal(box.localToGlobal(local));
  }

  // Finishing

  Future<void> _completeCoverage() async {
    if (_finishing) return;
    _finishing = true;
    _auto.stop();
    for (var i = 0; i < _strips; i++) {
      _covered[i] = true;
    }
    if (!_fadeTicker.isActive) {
      _lastTick = Duration.zero;
      _fadeTicker.start();
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _applicator = null;
      _burst++;
    });
    await _finish.forward(from: 0);
    if (!mounted) return;
    setState(() => _saving = true);
    final result = await context.read<AppState>().recordApplication();
    if (!mounted) return;
    widget.onApplied(result);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user!;
    final product = state.activeProduct;
    final next = state.nextUnlock;
    final stats = state.stats;

    return DesignBody(
      top: 33,
      bottom: 9,
      children: [
        Reveal(
          delay: Reveal.step(0),
          child: Row(
            children: [
              Expanded(child: Text('Hey, glossy human', style: AppText.title.copyWith(fontSize: 26, letterSpacing: -0.5))),
              _LevelChip(level: stats.levelLabel),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Reveal(delay: Reveal.step(1), child: const Text('A tiny moment of lip love.', style: AppText.subtitle)),
        const SizedBox(height: 28),
        Reveal(
          delay: Reveal.step(2),
          child: _NextUnlockCard(next: next, applications: stats.applications),
        ),
        const SizedBox(height: 21),
        Reveal(
          delay: Reveal.step(3),
          scale: 0.95,
          child: DragTarget<Product>(
            onMove: (details) => _applyAtGlobal(details.offset + const Offset(38, 30)),
            onAcceptWithDetails: (_) {
              if (!_finishing && _coverage > 0.35) _completeCoverage();
              setState(() => _applicator = null);
            },
            onLeave: (_) => setState(() => _applicator = null),
            builder: (context, candidates, _) => GestureDetector(
              onPanStart: (d) => _applyAtGlobal(d.globalPosition),
              onPanUpdate: (d) => _applyAtGlobal(d.globalPosition),
              onPanEnd: (_) => setState(() => _applicator = null),
              child: AnimatedScale(
                scale: candidates.isNotEmpty ? 1.02 : 1,
                duration: const Duration(milliseconds: 220),
                child: IllustrationPanel(
                  color: AppColors.lilac,
                  height: 290,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned(left: 0, top: 184, child: DriftingBlob(color: AppColors.mint, width: 88, height: 98)),
                      const Positioned(
                        right: 0,
                        top: 197,
                        child: DriftingBlob(color: AppColors.peach, width: 70, height: 85, phase: 0.4),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 79,
                        child: Center(child: _buildLips(user, product)),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 30,
                        child: Center(child: SparkleBurst(play: _burst, size: const Size(300, 200))),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 240,
                        child: Center(child: _PromptText(coverage: _coverage, finishing: _finishing)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 34),
        Reveal(
          delay: Reveal.step(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
              _DraggableProduct(product: product, hint: _hint, idle: !_touched),
              const SizedBox(width: 27),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(product.name, key: ValueKey(product.id), style: AppText.section),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${product.blurb}\nDrag it onto your digital lips.',
                        style: AppText.subtitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(height: 24),
        Reveal(
          delay: Reveal.step(5),
          child: PrimaryButton(
            label: 'Apply a little love',
            loading: _saving,
            onPressed: _finishing ? null : _startAuto,
          ),
        ),
      ],
    );
  }

  Widget _buildLips(UserProfile user, Product product) {
    return AnimatedBuilder(
      animation: Listenable.merge([_finish, _hint]),
      builder: (context, _) {
        final f = _finish.value;
        final highlight = Curves.easeOutCubic.transform((f / 0.55).clamp(0, 1));
        final sheen = f > 0.25 && f < 0.95 ? (f - 0.25) / 0.7 : null;
        final pop = 1 + 0.07 * math.sin(math.pi * (f / 0.45).clamp(0, 1));
        final hintT = _hint.value;
        final showHint = !_touched && hintT > 0.1 && hintT < 0.6;
        final hintX = ((hintT - 0.1) / 0.5).clamp(0.0, 1.0);

        return Transform.scale(
          scale: pop,
          child: SizedBox(
            key: _lipsKey,
            width: _lipsSize.width,
            height: _lipsSize.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: _lipsSize,
                  painter: LipsPainter(
                    shape: user.lipShape,
                    shade: user.lipShade,
                    finish: LipFinish.of(product),
                    reveal: List.of(_reveal),
                    highlightProgress: _finishing ? highlight : 0,
                    sheen: sheen,
                    shimmerPhase: hintT,
                    stretch: _stretch,
                  ),
                ),
                if (showHint)
                  Positioned(
                    left: _lipsSize.width * (0.08 + 0.84 * Curves.easeInOut.transform(hintX)) - 14,
                    top: _lipsSize.height * 0.5 - 14,
                    child: Opacity(
                      opacity: math.sin(hintX * math.pi) * 0.75,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.7),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                        ),
                      ),
                    ),
                  ),
                if (_applicator != null)
                  Positioned(
                    left: _applicator!.dx - 22,
                    top: _applicator!.dy - 30,
                    child: IgnorePointer(
                      child: Transform.rotate(
                        angle: -0.35,
                        child: Opacity(opacity: 0.92, child: ProductArt(product: product, width: 46)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, a) => ScaleTransition(scale: a.drive(CurveTween(curve: Curves.elasticOut)), child: child),
      child: Container(
        key: ValueKey(level),
        width: 81,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: AppColors.chip, borderRadius: BorderRadius.circular(16)),
        child: Text('LVL $level', style: AppText.eyebrow.copyWith(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0)),
      ),
    );
  }
}

class _NextUnlockCard extends StatelessWidget {
  const _NextUnlockCard({required this.next, required this.applications});

  final Product? next;
  final int applications;

  @override
  Widget build(BuildContext context) {
    final product = next;
    return SoftCard(
      height: 57,
      padding: const EdgeInsets.fromLTRB(16, 11, 16, 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(product == null ? 'YOUR SHELF' : 'YOUR NEXT UNLOCK',
                    style: AppText.eyebrow.copyWith(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w600)),
                Text(product?.name ?? 'Every treat collected',
                    style: AppText.label.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 1, right: 16),
            child: Text(
              product == null ? '6 / 6' : '$applications / ${product.unlockAt}',
              style: AppText.label.copyWith(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptText extends StatelessWidget {
  const _PromptText({required this.coverage, required this.finishing});

  final double coverage;
  final bool finishing;

  @override
  Widget build(BuildContext context) {
    final text = finishing
        ? 'Ooh, so glossy!'
        : coverage > 0
            ? 'Keep swiping, almost there'
            : 'Swipe across your lips';
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(position: a.drive(Tween(begin: const Offset(0, 0.5), end: Offset.zero)), child: child),
      ),
      child: Text(text, key: ValueKey(text), style: AppText.label.copyWith(fontSize: 13)),
    );
  }
}

/// The active product, which can be picked up and dragged onto the lips. It
/// gives a little wiggle every few seconds until the first swipe.
class _DraggableProduct extends StatelessWidget {
  const _DraggableProduct({required this.product, required this.hint, required this.idle});

  final Product product;
  final Animation<double> hint;
  final bool idle;

  @override
  Widget build(BuildContext context) {
    final art = ProductArt(product: product, width: 84);
    return Draggable<Product>(
      data: product,
      onDragStarted: HapticFeedback.lightImpact,
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.rotate(
          angle: -0.3,
          child: Transform.scale(
            scale: 0.9,
            child: DecoratedBox(
              decoration: BoxDecoration(
                boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.15), blurRadius: 18, offset: const Offset(0, 10))],
              ),
              child: art,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: art),
      child: AnimatedBuilder(
        animation: hint,
        builder: (context, child) {
          final t = hint.value;
          final wiggle = idle && t > 0.66 && t < 0.86 ? math.sin((t - 0.66) / 0.2 * math.pi * 4) * 0.07 : 0.0;
          return Transform.rotate(angle: wiggle, child: child);
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, a) => ScaleTransition(scale: a.drive(CurveTween(curve: Curves.easeOutBack)), child: child),
          child: KeyedSubtree(key: ValueKey(product.id), child: art),
        ),
      ),
    );
  }
}
