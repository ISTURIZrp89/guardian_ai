import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../services/firebase_auth_service.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(firebaseAuthServiceProvider);
      final user = await authService.signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        context.go('/ai');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skipLogin() {
    context.go('/ai');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            children: [
              const Spacer(flex: 3),
              _buildIcon(),
              24.gapH,
              _buildTitle(),
              8.gapH,
              _buildSubtitle(),
              const Spacer(flex: 2),
              _buildGoogleButton(),
              16.gapH,
              _buildTerms(),
              16.gapH,
              _buildSkipButton(),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 88,
      height: 88,
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
        size: 44,
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => AppColors.clinicalGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: const Text(
        'Guardian AI',
        style: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXxl,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Asistente Clínico Inteligente',
      style: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: AppDimensions.fontSizeMd,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        letterSpacing: 1,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithGoogle,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bgCard,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.bgCard.withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            side: const BorderSide(color: AppColors.borderDefault),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.clinicalBlue.withAlpha(150),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _googleIcon(),
                  12.gapW,
                  const Text(
                    'Iniciar sesión con Google',
                    style: TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _googleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Center(
        child: Text(
          'G',
          style: TextStyle(
            color: Color(0xFF4285F4),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildTerms() {
    return const Text(
      'Al iniciar sesión acepta los términos y condiciones',
      style: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: AppDimensions.fontSizeXs,
        color: AppColors.textDisabled,
        fontWeight: FontWeight.w400,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSkipButton() {
    return TextButton(
      onPressed: _isLoading ? null : _skipLogin,
      child: const Text(
        'Omitir por ahora',
        style: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeSm,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
