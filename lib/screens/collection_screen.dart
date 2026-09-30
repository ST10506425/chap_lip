import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/motion.dart';
import '../widgets/product_art.dart';

/// 09 Collection: the shelf of owned and locked products.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key, required this.onUseProduct});

  /// Called after an owned product is picked, to jump back to Play.
  final VoidCallback onUseProduct;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final stats = state.stats;
    final owned = Product.catalog.where((p) => stats.unlocked.contains(p.id)).length;

    Widget tile(int i) {
      final product = Product.catalog[i];
      return Expanded(
        child: Reveal(
          delay: Reveal.step(3 + i),
          scale: 0.92,
          child: _ProductTile(
            product: product,
            owned: stats.unlocked.contains(product.id),
            active: state.activeProduct.id == product.id,
            used: stats.usedProducts.contains(product.id),
            applications: stats.applications,
            onUse: () async {
              await state.useProduct(product);
              if (!context.mounted) return;
              showSoftToast(context, '${product.name} is ready to swipe.');
              onUseProduct();
            },
          ),
        ),
      );
    }

    return DesignBody(
      bottom: 16,
      children: [
        ScreenHeader(
          eyebrow: 'Your shelf of little joys',
          title: 'The gloss club.',
          subtitle: '$owned of ${Product.catalog.length} products collected. Keep the love going.',
        ),
        const SizedBox(height: 49),
        for (var row = 0; row < 3; row++) ...[
          if (row > 0) const SizedBox(height: 16),
          Row(children: [tile(row * 2), const SizedBox(width: 14), tile(row * 2 + 1)]),
        ],
        const Spacer(),
      ],
    );
  }
}

class _ProductTile extends StatefulWidget {
  const _ProductTile({
    required this.product,
    required this.owned,
    required this.active,
    required this.used,
    required this.applications,
    required this.onUse,
  });

  final Product product;
  final bool owned;
  final bool active;
  final bool used;
  final int applications;
  final VoidCallback onUse;

  @override
  State<_ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<_ProductTile> with SingleTickerProviderStateMixin {
  late final AnimationController _bob =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();
  int _shake = 0;

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  String get _subtitle {
    final p = widget.product;
    if (!widget.owned) return '${p.unlockAt} applications';
    if (p.isStarter) return 'Starter · owned';
    if (widget.active) return 'In use · owned';
    if (!widget.used) return 'New · owned';
    return 'Loved · owned';
  }

  void _tap() {
    if (widget.owned) {
      widget.onUse();
    } else {
      setState(() => _shake++);
      final left = widget.product.unlockAt - widget.applications;
      showSoftToast(context, '$left more applications to unlock this ${widget.product.kindLabel.toLowerCase()}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final art = ProductArt(
      product: p,
      width: 63,
      colors: widget.owned ? PackageColors.owned : PackageColors.locked,
      label: widget.owned ? null : '?',
    );
    return Shake(
      trigger: _shake,
      child: Pressable(
        onTap: _tap,
        child: Container(
          height: 142,
          decoration: BoxDecoration(
            color: widget.owned ? Colors.white : AppColors.lockedCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _bob,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, widget.active ? -3 * math.sin(_bob.value * math.pi * 2) : 0),
                  child: child,
                ),
                child: art,
              ),
              const SizedBox(height: 13),
              _OneLine(Text(p.name, maxLines: 1, style: AppText.cardTitle.copyWith(fontWeight: FontWeight.w700))),
              const SizedBox(height: 8),
              _OneLine(Text(_subtitle, maxLines: 1, style: AppText.small)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps a label on one line, shrinking it on narrow phones or large text.
class _OneLine extends StatelessWidget {
  const _OneLine(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: FittedBox(fit: BoxFit.scaleDown, child: child),
      );
}
