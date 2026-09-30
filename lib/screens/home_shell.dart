import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/common.dart';
import '../widgets/motion.dart';
import 'application_complete_view.dart';
import 'collection_screen.dart';
import 'play_screen.dart';
import 'product_unlocked_screen.dart';
import 'profile_screen.dart';

/// Hosts the Play, Collection and You tabs above the floating nav bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _tab = widget.initialTab;
  ApplicationResult? _completed;
  int _playRound = 0;

  void _goTo(int tab) {
    if (tab == _tab) return;
    setState(() {
      _tab = tab;
      _completed = null;
      _playRound++;
    });
  }

  Future<void> _onApplied(ApplicationResult result) async {
    if (result.unlocked.isEmpty) {
      setState(() => _completed = result);
      return;
    }
    HapticFeedback.heavyImpact();
    final choice = await Navigator.of(context).push<UnlockChoice>(
      BloomRoute(
        builder: (_) => ProductUnlockedScreen(
          product: result.unlocked.last,
          applications: result.stats.applications,
        ),
      ),
    );
    if (!mounted) return;
    final state = context.read<AppState>();
    if (choice == UnlockChoice.viewCollection) {
      _goTo(1);
    } else {
      await state.useProduct(result.unlocked.last);
      setState(() {
        _completed = null;
        _playRound++;
      });
    }
  }

  Widget _body() {
    switch (_tab) {
      case 1:
        return CollectionScreen(
          key: const ValueKey('collection'),
          onUseProduct: () => _goTo(0),
        );
      case 2:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        final done = _completed;
        if (done != null) {
          return ApplicationCompleteView(
            key: ValueKey('complete$_playRound'),
            result: done,
            onBack: () => setState(() {
              _completed = null;
              _playRound++;
            }),
          );
        }
        return PlayScreen(key: ValueKey('play$_playRound'), onApplied: _onApplied);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 420),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation.drive(Tween(begin: 0.98, end: 1)), child: child),
                ),
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                child: _body(),
              ),
            ),
            AppBottomNav(index: _tab, onTap: _goTo),
          ],
        ),
      ),
    );
  }
}
