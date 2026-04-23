import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.surfaceDark,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Background gradient ────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A0A0D),
                    Color(0xFF2D0F16),
                    Color(0xFF0D0A0B),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // ── Glowing orbs ─────────────────────────────────────────────
            Positioned(
              top: -size.height * 0.12,
              left: -size.width * 0.2,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Opacity(
                  opacity: 0.18 + _pulseCtrl.value * 0.12,
                  child: Container(
                    width: size.width * 0.85,
                    height: size.width * 0.85,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.primary, Colors.transparent],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: -size.height * 0.15,
              right: -size.width * 0.25,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Opacity(
                  opacity: 0.12 + (1 - _pulseCtrl.value) * 0.1,
                  child: Container(
                    width: size.width * 0.9,
                    height: size.width * 0.9,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [AppColors.accent, Colors.transparent],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Diagonal geometric accent ─────────────────────────────────
            Positioned(
              top: size.height * 0.05,
              right: -40,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
              )
                  .animate(delay: 300.ms)
                  .fadeIn(duration: 800.ms)
                  .rotate(begin: 0, end: 0.05, duration: 3000.ms,
                      curve: Curves.easeInOut),
            ),

            Positioned(
              bottom: size.height * 0.1,
              left: -50,
              child: Transform.rotate(
                angle: -0.4,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              )
                  .animate(delay: 500.ms)
                  .fadeIn(duration: 800.ms),
            ),

            // ── Main content ──────────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with multiple glow rings
                  _PulsingLogo(pulseCtrl: _pulseCtrl),

                  const SizedBox(height: 32),

                  // App name
                  const Text(
                    'HOSTAL',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 10,
                    ),
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.25, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  // Tagline
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.accent],
                    ).createShader(bounds),
                    child: const Text(
                      'Your home away from home',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  )
                      .animate(delay: 500.ms)
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: 0.25, end: 0),

                  const SizedBox(height: 64),

                  // Animated dots loader
                  _DotsLoader()
                      .animate(delay: 700.ms)
                      .fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // ── Version badge bottom ───────────────────────────────────────
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.2),
                    letterSpacing: 1,
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 600.ms),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pulsing Logo ─────────────────────────────────────────────────────────────

class _PulsingLogo extends StatelessWidget {
  final AnimationController pulseCtrl;

  const _PulsingLogo({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow ring
            Container(
              width: 130 + pulseCtrl.value * 16,
              height: 130 + pulseCtrl.value * 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08 + pulseCtrl.value * 0.06),
                  width: 1,
                ),
              ),
            ),
            // Middle ring
            Container(
              width: 105 + pulseCtrl.value * 8,
              height: 105 + pulseCtrl.value * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.14 + pulseCtrl.value * 0.08),
                  width: 1.5,
                ),
              ),
            ),
            // Core icon
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: AppColors.brandGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.5 + pulseCtrl.value * 0.25),
                    blurRadius: 30 + pulseCtrl.value * 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 40,
                    offset: const Offset(6, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.apartment_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        );
      },
    )
        .animate()
        .scale(
          begin: const Offset(0.4, 0.4),
          end: const Offset(1, 1),
          duration: 700.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 500.ms);
  }
}

// ─── Animated Dots Loader ─────────────────────────────────────────────────────

class _DotsLoader extends StatefulWidget {
  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = (_ctrl.value - delay).clamp(0.0, 1.0);
            final sin = (t * 3.14159).clamp(0.0, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 6,
              height: 6 + sin * 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.accent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
