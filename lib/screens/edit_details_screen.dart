import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/lip_store.dart';
import '../state/app_state.dart';
import '../theme/app_text.dart';
import '../widgets/common.dart';
import '../widgets/motion.dart';
import 'personalize_screen.dart';
import 'sign_up_screen.dart';

/// Edit name, email, identity and (optionally) password.
class EditDetailsScreen extends StatefulWidget {
  const EditDetailsScreen({super.key});

  @override
  State<EditDetailsScreen> createState() => _EditDetailsScreenState();
}

class _EditDetailsScreenState extends State<EditDetailsScreen> {
  late final _user = context.read<AppState>().user!;
  late final _name = TextEditingController(text: _user.name);
  late final _email = TextEditingController(text: _user.email);
  final _password = TextEditingController();
  late String _gender = _user.gender ?? identityOptions.last;
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

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'Tell us what to call you.' : null;
      _emailError = isValidEmail(_email.text.trim()) ? null : 'That email does not look quite right.';
      _passwordError =
          _password.text.isNotEmpty && _password.text.length < 8 ? 'Use at least 8 characters.' : null;
    });
    if (_nameError != null || _emailError != null || _passwordError != null) {
      setState(() => _shake++);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AppState>().saveDetails(
            name: _name.text,
            email: _email.text,
            gender: _gender,
            newPassword: _password.text,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      showSoftToast(context, 'Your details are saved.');
    } on AuthException catch (e) {
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
          eyebrow: 'Your details',
          title: 'Just a little tweak.',
          subtitle: 'Everything stays safely on this phone.',
        ),
        const SizedBox(height: 36),
        Shake(
          trigger: _shake,
          child: Column(
            children: [
              Reveal(
                delay: Reveal.step(3),
                child: AppTextField(label: 'Your name', hint: 'What should we call you?', controller: _name, error: _nameError),
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
                ),
              ),
              const SizedBox(height: 20),
              Reveal(
                delay: Reveal.step(5),
                child: AppTextField(
                  label: 'New password',
                  hint: 'Leave empty to keep your current one',
                  controller: _password,
                  obscure: true,
                  enableToggle: true,
                  error: _passwordError,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Reveal(delay: Reveal.step(6), child: const Text('How do you identify?', style: AppText.section)),
        const SizedBox(height: 16),
        IdentityOptions(value: _gender, onChanged: (v) => setState(() => _gender = v), delayStart: 7, gap: 10, height: 50),
        const Spacer(),
        const SizedBox(height: 32),
        Reveal(delay: Reveal.step(11), child: PrimaryButton(label: 'Save my details', loading: _busy, onPressed: _save)),
        const SizedBox(height: 14),
        Center(child: TextLink('Never mind', onTap: () => Navigator.of(context).pop())),
      ],
    );
  }
}
