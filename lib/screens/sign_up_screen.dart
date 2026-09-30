import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/lip_store.dart';
import '../state/app_state.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/motion.dart';
import 'log_in_screen.dart';
import 'personalize_screen.dart';

/// 02 Sign up.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  bool _busy = false;
  int _shake = 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final name = _name.text.trim();
    final email = _email.text.trim();
    final password = _password.text;
    setState(() {
      _nameError = name.isEmpty ? 'Tell us what to call you.' : null;
      _emailError = isValidEmail(email) ? null : 'That email does not look quite right.';
      _passwordError = password.length < 8 ? 'Use at least 8 characters.' : null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      setState(() => _shake++);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppState>().signUp(name: name, email: email, password: password);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(SoftRoute(builder: (_) => const PersonalizeScreen()), (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _emailError = e.message;
        _shake++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesignPage(
      bottom: 38,
      children: [
        const ScreenHeader(
          eyebrow: 'Your little lip-care world',
          title: 'Let’s meet your lips.',
          subtitle: 'Create an account to save your collection.',
        ),
        const SizedBox(height: 49),
        Shake(
          trigger: _shake,
          child: Column(
            children: [
              Reveal(
                delay: Reveal.step(3),
                child: AppTextField(
                  label: 'Your name',
                  hint: 'What should we call you?',
                  controller: _name,
                  error: _nameError,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
              ),
              const SizedBox(height: 20),
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
                  hint: 'Create a password',
                  controller: _password,
                  obscure: true,
                  enableToggle: true,
                  helper: 'Use at least 8 characters.',
                  error: _passwordError,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 44),
        Reveal(
          delay: Reveal.step(6),
          child: PrimaryButton(label: 'Create account', loading: _busy, onPressed: _submit),
        ),
        const SizedBox(height: 21),
        Reveal(
          delay: Reveal.step(7),
          child: const Center(
            child: Text(
              'By joining, you agree to our Terms\nand Privacy Policy.',
              textAlign: TextAlign.center,
              style: AppText.small,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 24),
        Reveal(
          delay: Reveal.step(8),
          child: Center(
            child: TextLink(
              'Already here? Log in',
              onTap: () => Navigator.of(context).pushReplacement(SoftRoute(builder: (_) => const LogInScreen())),
            ),
          ),
        ),
      ],
    );
  }
}

bool isValidEmail(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
