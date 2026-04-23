import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/validators.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';
import '../widgets/auth_text_field.dart';

final _signupPasswordObscureProvider = StateProvider<bool>((ref) => true);
final _signupConfirmObscureProvider = StateProvider<bool>((ref) => true);

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authControllerProvider.notifier).signup(
            _emailCtrl.text.trim(),
            _passCtrl.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.status == AuthStatus.verificationPending) {
        context.go('/verify-pending');
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
    final passObscure = ref.watch(_signupPasswordObscureProvider);
    final confirmObscure = ref.watch(_signupConfirmObscureProvider);
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

                  // ── Form ─────────────────────────────────────────────────
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
                            )
                                .animate()
                                .fade(duration: 400.ms, delay: 100.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 16),

                            // Password
                            AuthTextField(
                              controller: _passCtrl,
                              label: 'Password',
                              hint: 'Min. 8 characters',
                              obscureText: passObscure,
                              textInputAction: TextInputAction.next,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                              ),
                              onToggleObscure: () => ref
                                  .read(_signupPasswordObscureProvider.notifier)
                                  .state = !passObscure,
                              validator: Validators.password,
                            )
                                .animate()
                                .fade(duration: 400.ms, delay: 200.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 16),

                            // Confirm password
                            AuthTextField(
                              controller: _confirmCtrl,
                              label: 'Confirm password',
                              hint: '••••••••',
                              obscureText: confirmObscure,
                              textInputAction: TextInputAction.done,
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                size: 20,
                              ),
                              onToggleObscure: () => ref
                                  .read(_signupConfirmObscureProvider.notifier)
                                  .state = !confirmObscure,
                              validator: (v) =>
                                  Validators.confirmPassword(v, _passCtrl.text),
                              onFieldSubmitted: (_) => _submit(),
                            )
                                .animate()
                                .fade(duration: 400.ms, delay: 300.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 12),

                            // Terms note
                            Text(
                              'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.5),
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fade(duration: 400.ms, delay: 350.ms),

                            const SizedBox(height: 24),

                            // Submit button
                            _SignupButton(loading: loading, onTap: _submit)
                                .animate()
                                .fade(duration: 400.ms, delay: 400.ms)
                                .slideY(begin: 0.2, end: 0),

                            const SizedBox(height: 24),

                            // Login row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account?',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        cs.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                TextButton(
                                  onPressed:
                                      loading ? null : () => context.go('/login'),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text('Sign in'),
                                ),
                              ],
                            ).animate().fade(duration: 400.ms, delay: 450.ms),
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
          colors: [AppColors.accent, AppColors.primary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.go('/login'),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ).animate().fade(duration: 400.ms),
          const SizedBox(height: 20),
          const Text(
            'Create account',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ).animate().fade(duration: 400.ms, delay: 100.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 6),
          Text(
            'Join Hostal and find your perfect stay',
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

class _SignupButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _SignupButton({required this.loading, required this.onTap});

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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                )
              : const Text('Create account'),
        ),
      ),
    );
  }
}
