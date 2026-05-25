import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';
import '../widgets/pin_display.dart';
import '../widgets/pin_keypad.dart';

class PinSetupPage extends ConsumerStatefulWidget {
  const PinSetupPage({super.key});

  @override
  ConsumerState<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends ConsumerState<PinSetupPage> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isConfirming = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      body: SafeArea(
        child: Padding(
          padding: AppDimensions.screenPadding,
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildHeader(),
              24.gapH,
              _buildDescription(),
              32.gapH,
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.3, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: _buildStepIndicator(),
              ),
              24.gapH,
              PinDotWidget(
                key: ValueKey(_isConfirming),
                pinLength: 6,
                currentLength: _isConfirming
                    ? _confirmController.text.length
                    : _pinController.text.length,
                hasError: _errorMessage != null,
              ),
              16.gapH,
              if (_errorMessage != null) _buildError(_errorMessage!),
              const Spacer(flex: 1),
              if (authState.isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.clinicalBlue,
                    ),
                  ),
                ),
              PinKeypad(
                onKeyPressed: authState.isLoading ? null : _onKeyPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.clinicalGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.clinicalBlue.withAlpha(50),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_outline_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
        16.gapH,
        const Text(
          'Configurar PIN de Seguridad',
          style: TextStyle(
            fontFamily: 'SFPro',
            fontSize: AppDimensions.fontSizeXl,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Text(
      'Establezca un PIN de 6 dígitos para proteger el acceso a la información clínica de los pacientes.',
      style: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: AppDimensions.fontSizeSm,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepDot(0),
        8.gapW,
        Container(
          width: 32,
          height: 1,
          color:
              _isConfirming ? AppColors.clinicalBlue : AppColors.borderDefault,
        ),
        8.gapW,
        _stepDot(1),
      ],
    );
  }

  Widget _stepDot(int index) {
    final isActive =
        (index == 0 && !_isConfirming) || (index == 1 && _isConfirming);
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.clinicalBlue : AppColors.bgCardHover,
        border: Border.all(
          color: isActive ? AppColors.clinicalBlue : AppColors.borderDefault,
          width: 1,
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Text(
      message,
      style: const TextStyle(
        fontFamily: 'SFPro',
        fontSize: AppDimensions.fontSizeXs,
        color: AppColors.alertRed,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  void _onKeyPressed(String key) {
    setState(() => _errorMessage = null);

    if (_isConfirming) {
      _handleConfirmInput(key);
    } else {
      _handlePinInput(key);
    }
  }

  void _handlePinInput(String key) {
    if (key == 'delete') {
      if (_pinController.text.isNotEmpty) {
        _pinController.text =
            _pinController.text.substring(0, _pinController.text.length - 1);
      }
      return;
    }

    if (_pinController.text.length >= 6) return;
    _pinController.text += key;

    if (_pinController.text.length == 6) {
      setState(() => _isConfirming = true);
    }
  }

  void _handleConfirmInput(String key) {
    if (key == 'delete') {
      if (_confirmController.text.isNotEmpty) {
        _confirmController.text = _confirmController.text
            .substring(0, _confirmController.text.length - 1);
      } else {
        setState(() {
          _isConfirming = false;
          _pinController.clear();
        });
      }
      return;
    }

    if (_confirmController.text.length >= 6) return;
    _confirmController.text += key;

    if (_confirmController.text.length == 6) {
      _submitPin();
    }
  }

  Future<void> _submitPin() async {
    if (_pinController.text != _confirmController.text) {
      setState(() {
        _errorMessage = 'Los PIN no coinciden. Intente nuevamente.';
        _isConfirming = false;
        _confirmController.clear();
        _pinController.clear();
      });
      return;
    }

    final success =
        await ref.read(authProvider.notifier).setupPin(_pinController.text);

    if (success && mounted) {
      context.go('/ai');
    } else if (!success && mounted) {
      setState(() {
        _errorMessage = ref.read(authProvider).errorMessage;
        _isConfirming = false;
        _confirmController.clear();
        _pinController.clear();
      });
    }
  }
}
