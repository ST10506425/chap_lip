import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/motion.dart';
import '../widgets/product_art.dart';

enum UnlockChoice { tryIt, viewCollection }

/// 08 Product unlocked: the celebration when a milestone is reached.
class ProductUnlockedScreen extends StatefulWidget {
  const ProductUnlockedScreen({super.key, required this.product, required this.applications});

  final Product product;
  final int applications;

  @override
  State<ProductUnlockedScreen> createState() => _ProductUnlockedScreenState();
}

class _ProductUnlockedScreenState extends State<ProductUnlockedScreen> with TickerProviderStateMixin {
  late final AnimationController _drop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
  late final AnimationController _float =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat();
  int _burst = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      _drop.forward();
      Future.delayed(const Duration(milliseconds: 520), () {
        if (mounted) setState(() => _burst++);
      });
    });
  }

  @override
  void dispose() {
    _drop.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(child: ConfettiRain()),
          SafeArea(
            child: DesignBody(
              top: 52,
              bottom: 31,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Reveal(
                  delay: Reveal.step(0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Sparkle(size: 11),
                      const SizedBox(width: 9),
                      Text('A NEW LITTLE TREAT', style: AppText.eyebrow.copyWith(fontSize: 12, letterSpacing: 0.4)),
                      const SizedBox(width: 9),
                      const Sparkle(size: 11, delay: Duration(milliseconds: 400)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Reveal(
                  delay: Reveal.step(1),
                  child: Text(
                    'Meet your\n${p.upgradeWord} upgrade.',
                    textAlign: TextAlign.center,
                    style: AppText.hero.copyWith(fontSize: 34, height: 1.3),
                  ),
                ),
                const SizedBox(height: 41),
                Reveal(
                  delay: Reveal.step(2),
                  scale: 0.85,
                  duration: const Duration(milliseconds: 650),
                  child: IllustrationPanel(
                    color: p.panel,
                    width: 282,
                    height: 244,
                    radius: 88,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _float,
                          builder: (context, _) => Transform.scale(
                            scale: 1 + 0.06 * math.sin(_float.value * math.pi * 2),
                            child: Container(
                              width: 190,
                              height: 190,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  Colors.white.withValues(alpha: 0.55),
                                  Colors.white.withValues(alpha: 0),
                                ]),
                              ),
                            ),
                          ),
                        ),
                        SparkleBurst(play: _burst, size: const Size(260, 220), count: 20),
                        AnimatedBuilder(
                          animation: Listenable.merge([_drop, _float]),
                          builder: (context, child) {
                            final d = _drop.value;
                            final drop = Curves.elasticOut.transform(d);
                            final bob = math.sin(_float.value * math.pi * 2) * 4 * d;
                            return Opacity(
                              opacity: (d * 4).clamp(0, 1),
                              child: Transform.translate(
                                offset: Offset(0, (1 - drop) * -120 + bob),
                                child: Transform.rotate(
                                  angle: (1 - drop) * 0.4 + math.sin(_float.value * math.pi * 2) * 0.03,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          child: ProductArt(product: p, width: p.kind == PackageKind.jar ? 130 : 150),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                Reveal(delay: Reveal.step(4), child: Text('${p.name} unlocked', style: AppText.section)),
                const SizedBox(height: 13),
                Reveal(
                  delay: Reveal.step(5),
                  child: Text(
                    '${widget.applications} applications. A fresh new favourite.\nYour collection is growing!',
                    textAlign: TextAlign.center,
                    style: AppText.subtitle,
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 32),
                Reveal(
                  delay: Reveal.step(6),
                  child: PrimaryButton(
                    label: 'Try my ${p.name.toLowerCase()}',
                    shine: true,
                    onPressed: () => Navigator.of(context).pop(UnlockChoice.tryIt),
                  ),
                ),
                const SizedBox(height: 14),
                Reveal(
                  delay: Reveal.step(7),
                  child: TextLink(
                    'View my collection',
                    onTap: () => Navigator.of(context).pop(UnlockChoice.viewCollection),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
