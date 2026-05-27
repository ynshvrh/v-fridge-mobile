import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/providers.dart';
import 'google_signin_button.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authControllerProvider.notifier).signup(
            _username.text.trim(),
            _email.text.trim(),
            _password.text,
          );
      if (mounted) setState(() => _done = true);
    } on ApiError catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _done
                  ? _DoneCard(email: _email.text)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n.signupTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 24),
                        const GoogleSignInButton(),
                        const SizedBox(height: 16),
                        Row(children: [
                          const Expanded(child: Divider()),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text(l10n.wordOr, style: Theme.of(context).textTheme.labelSmall)),
                          const Expanded(child: Divider()),
                        ]),
                        const SizedBox(height: 16),
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
                          ),
                        if (_error != null) const SizedBox(height: 16),
                        TextField(
                          controller: _username,
                          decoration: InputDecoration(
                            labelText: l10n.signupUsernameLabel,
                            hintText: l10n.signupUsernameHint,
                          ),
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(labelText: l10n.signinEmail),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          decoration: InputDecoration(labelText: l10n.signupPasswordLabel),
                          obscureText: true,
                          enabled: !_loading,
                          onSubmitted: (_) => _submit(),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : Text(l10n.signupSubmit),
                        ),
                        TextButton(
                          onPressed: _loading ? null : () => Navigator.of(context).pop(),
                          child: Text(l10n.signupHaveAccount),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 56),
            const SizedBox(height: 12),
            Text(l10n.signupDoneTitle, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              l10n.signupDoneBody(email),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.signupBackToSignIn),
            ),
          ],
        ),
      ),
    );
  }
}
