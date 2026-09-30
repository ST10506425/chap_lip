import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/lip_store.dart';
import '../models/lip_style.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/lips.dart';
import '../widgets/motion.dart';
import 'home_shell.dart';
import 'personalize_screen.dart';
import 'sign_up_screen.dart';

/// 03 Log in.
class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _emailError;
  String? _passwordError;
  bool _busy = false;
  int _shake = 0;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _emailError = isValidEmail(_email.text.trim()) ? null : 'Enter the email you joined with.';
      _passwordError = _password.text.isEmpty ? 'Enter your password.' : null;
    });
    if (_emailError != null || _passwordError != null) {
      setState(() => _shake++);
      return;
    }
    setState(() => _busy = true);
    final state = context.read<AppState>();
    try {
      await state.logIn(email: _email.text, password: _password.text);
      if (!mounted) return;
      final next = state.user!.onboarded ? const HomeShell() : const PersonalizeScreen();
      Navigator.of(context).pushAndRemoveUntil(SoftRoute(builder: (_) => next), (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _passwordError = e.message;
        _shake++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      bottom: 38,
      children: [
        const ScreenHeader(eyebrow: 'Welcome back', title: 'Hey, glossy human.', subtitle: 'Your lips missed you.'),
        const SizedBox(height: 27),
        Reveal(
          delay: Reveal.step(3),
          scale: 0.8,
          child: const Center(
            child: AnimatedLips(shape: LipShape.full, shade: LipShade.rose, width: 96, float: 2, stretch: 1.04),
          ),
        ),
        const SizedBox(height: 43),
        Shake(
          trigger: _shake,
          child: Column(
            children: [
              Reveal(
                delay: Reveal.step(4),
                child: AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  error: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                ),
              ),
              const SizedBox(height: 20),
              Reveal(
                delay: Reveal.step(5),
                child: AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _password,
                  obscure: true,
                  enableToggle: true,
                  error: _passwordError,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: Reveal.step(6),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextLink(
              'Forgot password?',
              style: AppText.link.copyWith(fontSize: 13, fontWeight: FontWeight.w500),
              onTap: () => showForgotPasswordSheet(context),
            ),
          ),
        ),
        const SizedBox(height: 41),
        Reveal(
          delay: Reveal.step(7),
          child: PrimaryButton(label: 'Log in', loading: _busy, onPressed: _submit),
        ),
        const SizedBox(height: 37),
        Reveal(
          delay: Reveal.step(8),
          child: Center(
            child: TextLink(
              'New around here? Create an account',
              onTap: () => Navigator.of(context).pushReplacement(SoftRoute(builder: (_) => const SignUpScreen())),
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

/// Lets someone set a new password for an account stored on this phone,
/// after confirming the name and email it was created with.
Future<void> showForgotPasswordSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => const _ForgotPasswordSheet(),
  );
}

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _error;
  bool _busy = false;
  int _shake = 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (_password.text.length < 8) {
      setState(() {
        _error = 'Use at least 8 characters.';
        _shake++;
      });
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppState>().resetPassword(
            email: _email.text,
            name: _name.text,
            newPassword: _password.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSoftToast(context, 'All set. Log in with your new password.');
    } on AuthException catch (e) {
      setState(() {
        _busy = false;
        _error = e.message;
        _shake++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Shake(
          trigger: _shake,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('RESET ON THIS PHONE', style: AppText.eyebrow),
              const SizedBox(height: 10),
              Text('New password, same lips.', style: AppText.title.copyWith(fontSize: 22)),
              const SizedBox(height: 6),
              const Text('Your account lives only on this phone, so confirm your name and email.',
                  style: AppText.subtitle),
              const SizedBox(height: 20),
              AppTextField(label: 'Your name', hint: 'The name you joined with', controller: _name),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'New password',
                hint: 'Create a new password',
                controller: _password,
                obscure: true,
                enableToggle: true,
                error: _error,
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Save new password', loading: _busy, onPressed: _reset),
            ],
          ),
        ),
      ),
    );
  }
}
