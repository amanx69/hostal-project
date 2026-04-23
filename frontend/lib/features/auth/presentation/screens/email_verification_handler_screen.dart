import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class EmailVerificationHandlerScreen extends ConsumerStatefulWidget {
  final String uid;
  final String token;

  const EmailVerificationHandlerScreen({
    super.key,
    required this.uid,
    required this.token,
  });

  @override
  ConsumerState<EmailVerificationHandlerScreen> createState() =>
      _EmailVerificationHandlerScreenState();
}

class _EmailVerificationHandlerScreenState
    extends ConsumerState<EmailVerificationHandlerScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback so context/router is ready before we navigate.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final ok = await ref
          .read(authControllerProvider.notifier)
          .verifyEmailToken(uid: widget.uid, token: widget.token);
      if (!mounted) return;
      context.go(ok ? '/verify-success' : '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'Verifying your email…',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
