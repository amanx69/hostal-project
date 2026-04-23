import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

final _loginPasswordObscureProvider = StateProvider<bool>((ref) => true);

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).login(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to state changes and show snackbars / navigate.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go('/home');
        return;
      }
      if (next.status == AuthStatus.error &&
          next.message != null &&
          next.message!.isNotEmpty) {
        _showError(context, next.message!);
      }
    });

    final state = ref.watch(authControllerProvider);
    final loading = state.status == AuthStatus.loading;
    final obscure = ref.watch(_loginPasswordObscureProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Gradient header ──────────────────────────────────────
                  _buildHeader(context),

                  // ── Form card ────────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),

                            // Email
                            AuthTextField(
                              controller: _emailCtrl,
                              label: 'Email address',
                              hint: 'you@example.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                size: 20,
                              ),
                              validator: Validators.email,
                              onFieldSubmitted: (_) =>
                                  _passFocus.requestFocus(),
                            )
                                .animate()
                                .fade(duration: 400.ms, delay: 100.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 16),

                            // Password
                            AuthTextField(
                              controller: _passCtrl,
                              label: 'Password',
                              hint: '••••••••',
                              obscureText: obscure,
                              textInputAction: TextInputAction.done,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                              ),
                              onToggleObscure: () => ref
                                  .read(_loginPasswordObscureProvider.notifier)
                                  .state = !obscure,
                              validator: Validators.password,
                              onFieldSubmitted: (_) => _submit(),
                            )
                                .animate()
                                .fade(duration: 400.ms, delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 8),

                            // Forgot password (placeholder)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: loading ? null : () {},
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ).animate().fade(duration: 400.ms, delay: 250.ms),

                            const SizedBox(height: 24),

                            // Login button
                            _LoginButton(loading: loading, onTap: _submit)
                                .animate()
                                .fade(duration: 400.ms, delay: 300.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'or',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ).animate().fade(duration: 400.ms, delay: 350.ms),

                            const SizedBox(height: 24),

                            // Sign-up row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account?",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        cs.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed:
                                      loading ? null : () => context.go('/signup'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Sign up'),
                                ),
                              ],
                            ).animate().fade(duration: 400.ms, delay: 400.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 36),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.accent],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.apartment_rounded,
              color: Colors.white,
              size: 28,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 20),
          const Text(
            'Welcome back',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 6),
          Text(
            'Sign in to continue to Hostal',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ).animate().fade(duration: 400.ms, delay: 200.ms).slideX(begin: -0.1, end: 0),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
  }
}

class _LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _LoginButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        key: ValueKey(loading),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: loading ? null : onTap,
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              : const Text('Sign in'),
        ),
      ),
    );
  }
}
