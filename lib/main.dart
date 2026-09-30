import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'data/lip_store.dart';
import 'screens/home_shell.dart';
import 'screens/personalize_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';
import 'theme/app_text.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final store = await SqliteLipStore.open();
  final state = AppState(store);
  await state.bootstrap();

  runApp(ChangeNotifierProvider.value(value: state, child: const MoistMeUpApp()));
}

class MoistMeUpApp extends StatelessWidget {
  const MoistMeUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moist Me Up',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Keep the hand tuned layouts intact while still honouring larger text.
      builder: (context, child) => MediaQuery.withClampedTextScaling(maxScaleFactor: 1.2, child: child!),
      home: const StartScreen(),
    );
  }
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      fontFamily: AppText.family,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.background,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primary.withValues(alpha: 0.25),
        selectionHandleColor: AppColors.primary,
      ),
    );

/// Picks the first screen from the saved session.
class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppState>().user;
    if (user == null) return const WelcomeScreen();
    if (!user.onboarded) return const PersonalizeScreen();
    return const HomeShell();
  }
}
