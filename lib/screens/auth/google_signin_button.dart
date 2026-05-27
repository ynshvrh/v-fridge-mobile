import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../l10n/l10n.dart';
import '../../models/api_models.dart';
import '../../providers/providers.dart';

/// The Google OAuth Web Client ID. Same value as the API's `Google__ClientId`.
/// Override at build time: --dart-define=GOOGLE_CLIENT_ID=...
const _googleClientId = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: '941333995278-pgiki8amquhfbac7f72ca3dvjspppceo.apps.googleusercontent.com',
);

class GoogleSignInButton extends ConsumerStatefulWidget {
  const GoogleSignInButton({super.key});

  @override
  ConsumerState<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends ConsumerState<GoogleSignInButton> {
  late final GoogleSignIn _gsi = GoogleSignIn(
    // serverClientId on Android is the WEB OAuth Client ID — the audience the API verifies against.
    serverClientId: _googleClientId,
    scopes: const ['email', 'profile', 'openid'],
  );
  bool _busy = false;

  Future<void> _signIn() async {
    if (_googleClientId.isEmpty) return;
    setState(() => _busy = true);
    try {
      final account = await _gsi.signIn();
      if (account == null) { setState(() => _busy = false); return; } // user cancelled
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) throw Exception('Google did not return an ID token');
      await ref.read(authControllerProvider.notifier).loginWithGoogle(idToken);
    } on ApiError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.signinGoogleFailed(e.toString()))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_googleClientId.isEmpty) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: _busy ? null : _signIn,
      icon: _busy
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.login),
      label: Text(context.l10n.signinContinueWithGoogle),
      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    );
  }
}
