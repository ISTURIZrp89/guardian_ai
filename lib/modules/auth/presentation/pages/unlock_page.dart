import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_display.dart';
import '../widgets/pin_keypad.dart';

class UnlockPage extends ConsumerStatefulWidget {
  const UnlockPage({super.key});

  @override
  ConsumerState<UnlockPage> createState() => _UnlockPageState();
}

class _UnlockPageState extends ConsumerState<UnlockPage>
    with TickerProviderStateMixin {
  final _pinController = TextEditingController();
  bool _obscurePin = true;
  Timer? _lockTimer;

  @override
  void dispose() {
    _pinController.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLocked = authState.status == AppAuthStatus.locked;

    if (isLocked) _startLockTimer();

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLockIcon(isLocked, authState.status),
              24.gapH,
              _buildTitle(),
              4.gapH,
              _buildSubtitle(),
              32.gapH,
              PinDotWidget(
                pinLength: 6,
                currentLength: _pinController.text.length,
                hasError: authState.errorMessage != null &&
                    authState.errorMessage!.contains('PIN incorrecto'),
              ),
              8.gapH,
              if (authState.errorMessage != null)
                _buildError(authState.errorMessage!),
              if (isLocked && authState.lockedUntil != null)
                _buildLockedTimer(authState.lockedUntil!),
              const Spacer(flex: 1),
              if (!isLocked) ...[
                _buildBiometricButton(),
                16.gapH,
              ],
              _buildKeypad(isLocked),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockIcon(bool isLocked, AppAuthStatus status) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isLocked ? AppColors.alertRed.withAlpha(30) : AppColors.bgCard,
        border: Border.all(
          color: isLocked
              ? AppColors.alertRed.withAlpha(80)
              : AppColors.borderDefault,
          width: 1.5,
        ),
      ),
      child: Icon(
        isLocked ? Icons.lock_rounded : Icons.shield_rounded,
        color: isLocked ? AppColors.alertRed : AppColors.clinicalBlue,
        size: 36,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Guardian AI',
      style: TextStyle(
        fontFamily: 'SFPro',
        fontSize: AppDimensions.fontSizeXl,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Desbloqueo Seguro',
      style: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: AppDimensions.fontSizeMd,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  Widget _buildError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        message,
        style: TextStyle(
          fontFamily: 'SFPro',
          fontSize: AppDimensions.fontSizeXs,
          color: AppColors.alertRed,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLockedTimer(DateTime lockedUntil) {
    final remaining = lockedUntil.difference(DateTime.now());
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Text(
            'Cuenta bloqueada temporalmente',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: AppDimensions.fontSizeSm,
              color: AppColors.alertRed,
              fontWeight: FontWeight.w500,
            ),
          ),
          4.gapH,
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: AppDimensions.fontSizeXxl,
              fontWeight: FontWeight.w700,
              color: AppColors.alertRed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricButton() {
    return FutureBuilder<bool>(
      future: ref.read(authRepositoryProvider).isBiometricAvailable(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return GestureDetector(
          onTap: _onBiometricTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.clinicalGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.clinicalBlue.withAlpha(50),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.fingerprint,
              color: Colors.white,
              size: 28,
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeypad(bool isLocked) {
    return PinKeypad(
      onKeyPressed: isLocked ? null : _onKeyPressed,
    );
  }

  void _onKeyPressed(String key) {
    if (key == 'delete') {
      if (_pinController.text.isNotEmpty) {
        _pinController.text =
            _pinController.text.substring(0, _pinController.text.length - 1);
      }
      ref.read(authProvider.notifier).clearError();
      return;
    }

    if (_pinController.text.length >= 6) return;

    _pinController.text += key;
    ref.read(authProvider.notifier).clearError();

    if (_pinController.text.length == 6) {
      _verifyPin();
    }
  }

  Future<void> _verifyPin() async {
    final pin = _pinController.text;
    final success =
        await ref.read(authProvider.notifier).authenticateWithPin(pin);
    _pinController.clear();
    if (success && mounted) {
      context.go('/ai');
    }
  }

  Future<void> _onBiometricTap() async {
    final success =
        await ref.read(authProvider.notifier).authenticateWithBiometrics();
    if (success && mounted) {
      context.go('/ai');
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }
}
