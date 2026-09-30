import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/decor.dart';
import '../widgets/lips.dart';
import '../widgets/motion.dart';

/// 07 Application complete.
class ApplicationCompleteView extends StatelessWidget {
  const ApplicationCompleteView({super.key, required this.result, required this.onBack});

  final ApplicationResult result;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user!;
    final next = state.nextUnlock;
    final apps = result.stats.applications;
    final remaining = next == null ? 0 : next.unlockAt - apps;

    final subtitle = next == null
        ? 'Your shelf is full of little joys.'
        : remaining == 1
            ? 'One more swipe toward something sweet.'
            : '$remaining more swipes toward something sweet.';

    return DesignBody(
      bottom: 19,
      children: [
        ScreenHeader(eyebrow: 'A little love, applied', title: 'Looking glossy!', subtitle: subtitle),
        const SizedBox(height: 46),
        Reveal(
          delay: Reveal.step(2),
          scale: 0.9,
          child: IllustrationPanel(
            color: AppColors.mintPanel,
            height: 277,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Positioned(left: 43, top: 71, child: Sparkle(size: 26)),
                const Positioned(right: 62, top: 50, child: Sparkle(size: 20, delay: Duration(milliseconds: 500))),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 72,
                  child: Center(
                    child: AnimatedLips(
                      shape: user.lipShape,
                      shade: user.lipShade,
                      finish: LipFinish.of(state.activeProduct),
                      width: 210,
                      float: 3,
                      stretch: 1.05,
                    ),
                  ),
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 10,
                  child: Center(child: SparkleBurst(play: 1, size: Size(320, 230), count: 22)),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 221,
                  child: Center(
                    child: Reveal(
                      delay: const Duration(milliseconds: 450),
                      scale: 0.6,
                      offset: 8,
                      child: Text(
                        '+1 application',
                        style: AppText.section.copyWith(fontSize: 17, color: AppColors.primary, letterSpacing: -0.2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        Reveal(delay: Reveal.step(4), child: _ProgressCard(next: next, applications: apps)),
        const Spacer(),
        const SizedBox(height: 24),
        Reveal(delay: Reveal.step(5), child: PrimaryButton(label: 'Back to my lips', onPressed: onBack)),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.next, required this.applications});

  final Product? next;
  final int applications;

  @override
  Widget build(BuildContext context) {
    final product = next;
    if (product == null) {
      return SoftCard(
        radius: 20,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your shelf is complete', style: AppText.cardTitle.copyWith(fontSize: 17)),
            const SizedBox(height: 17),
            const SoftProgress(value: 1),
            const SizedBox(height: 14),
            Text('$applications applications and counting', style: AppText.small),
          ],
        ),
      );
    }
    final previous = Product.catalog
        .lastWhere((p) => p.unlockAt <= applications && p.unlockAt < product.unlockAt, orElse: () => Product.vaseline)
        .unlockAt;
    final remaining = product.unlockAt - applications;
    final title = remaining <= 2 ? '${product.name} is almost yours' : '${product.name} is on its way';
    final value = applications / product.unlockAt;
    final before = (applications - 1).clamp(previous, product.unlockAt) / product.unlockAt;

    return SoftCard(
      radius: 20,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.cardTitle.copyWith(fontSize: 17)),
          const SizedBox(height: 17),
          SoftProgress(value: value, from: before),
          const SizedBox(height: 14),
          Text(
            '$applications of ${product.unlockAt} applications · $remaining to go',
            style: AppText.small,
          ),
        ],
      ),
    );
  }
}
