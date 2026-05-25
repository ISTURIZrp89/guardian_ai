import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../services/firebase_auth_service.dart';
import '../providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _navigateAfterDelay();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 800),
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.clinicalGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.clinicalBlue.withAlpha(60),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            24.gapH,
            ShaderMask(
              shaderCallback: (bounds) =>
                  AppColors.clinicalGradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              child: const Text(
                'GUARDIAN AI',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: AppDimensions.fontSizeXxl,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                  color: Colors.white,
                ),
              ),
            ),
            8.gapH,
            const Text(
              'Monitor Clínico Inteligente',
              style: TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: AppDimensions.fontSizeSm,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
            48.gapH,
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.clinicalBlue.withAlpha(150),
              ),
            ),
            12.gapH,
            const Text(
              'Cargando...',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: AppDimensions.fontSizeXs,
                color: AppColors.textDisabled,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateAfterDelay() {
    Timer(const Duration(seconds: 2), () async {
      if (!mounted) return;
      final firebaseAuth = ref.read(firebaseAuthServiceProvider);
      final isFirebaseSignedIn = firebaseAuth.isSignedIn();
      if (!mounted) return;
      if (!isFirebaseSignedIn) {
        context.go('/login');
        return;
      }
      final authNotifier = ref.read(authProvider.notifier);
      final status = await authNotifier.checkStatus();
      if (!mounted) return;
      if (status == AppAuthStatus.firstTime) {
        context.go('/pin-setup');
      } else {
        context.go('/ai');
      }
    });
  }
}
