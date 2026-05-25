import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';

class ClinicalInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showPasswordToggle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final FocusNode? focusNode;

  const ClinicalInput({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.showPasswordToggle = false,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.focusNode,
  });

  @override
  State<ClinicalInput> createState() => _ClinicalInputState();
}

class _ClinicalInputState extends State<ClinicalInput> {
  late bool _obscured;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ClinicalInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
    if (widget.errorText != oldWidget.errorText) {
      setState(() => _hasError = widget.errorText != null);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _toggleObscured() {
    setState(() => _obscured = !_obscured);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: AppDimensions.fontSizeSm,
                fontWeight: FontWeight.w500,
                color: _hasError
                    ? AppColors.alertRed
                    : _hasFocus
                        ? AppColors.clinicalBlue
                        : AppColors.textSecondary,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.bgInput : AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
            border: Border.all(
              color: _hasError
                  ? AppColors.borderError
                  : _hasFocus
                      ? AppColors.borderFocused
                      : AppColors.borderDefault,
              width: _hasFocus ? 2 : 1,
            ),
          ),
          child: Focus(
            focusNode: _focusNode,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: _obscured,
              enabled: widget.enabled,
              autofocus: widget.autofocus,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              style: const TextStyle(
                fontFamily: 'IBMPlexSans',
                fontSize: AppDimensions.fontSizeMd,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: widget.prefixIcon,
                      )
                    : null,
                suffixIcon: widget.showPasswordToggle
                    ? Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: IconButton(
                          onPressed: _toggleObscured,
                          icon: Icon(
                            _obscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          splashRadius: 20,
                        ),
                      )
                    : widget.suffixIcon != null
                        ? Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: widget.suffixIcon,
                          )
                        : null,
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontFamily: 'IBMPlexSans',
                  fontSize: AppDimensions.fontSizeMd,
                  color: AppColors.textDisabled,
                ),
                counterStyle: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: AppDimensions.fontSizeXs,
                  color: AppColors.textDisabled,
                ),
              ),
            ),
          ),
        ),
        if (widget.helperText != null || widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              widget.errorText ?? widget.helperText ?? '',
              style: TextStyle(
                fontFamily: 'SFPro',
                fontSize: AppDimensions.fontSizeXs,
                color: widget.errorText != null
                    ? AppColors.alertRed
                    : AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
