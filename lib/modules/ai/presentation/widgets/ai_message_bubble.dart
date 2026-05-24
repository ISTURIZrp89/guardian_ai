import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_response.dart';

class AiMessageBubble extends StatefulWidget {
  final String content;
  final bool isUser;
  final AiResponseCategory? category;
  final bool isTyping;

  const AiMessageBubble({
    super.key,
    required this.content,
    this.isUser = false,
    this.category,
    this.isTyping = false,
  });

  @override
  State<AiMessageBubble> createState() => _AiMessageBubbleState();
}

class _AiMessageBubbleState extends State<AiMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _typingController;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isTyping) {
      _typingController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant AiMessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping && !_typingController.isAnimating) {
      _typingController.repeat();
    } else if (!widget.isTyping && _typingController.isAnimating) {
      _typingController.stop();
    }
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.isUser ? AppDimensions.xl : AppDimensions.sm,
        right: widget.isUser ? AppDimensions.sm : AppDimensions.xl,
        bottom: AppDimensions.sm,
      ),
      child: Column(
        crossAxisAlignment:
            widget.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!widget.isUser && widget.category != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.sm,
                bottom: AppDimensions.xs,
              ),
              child: Text(
                widget.category!.displayName,
                style: TextStyle(
                  color: AppColors.textClinical,
                  fontSize: AppDimensions.fontSizeXs,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          GestureDetector(
            onLongPress: _copyToClipboard,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: widget.isUser
                    ? AppColors.statusInfo.withOpacity(0.15)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(
                  widget.isUser
                      ? AppDimensions.cardRadiusSmall
                      : AppDimensions.cardRadius,
                ),
                border: widget.isUser
                    ? Border.all(
                        color: AppColors.statusInfo.withOpacity(0.3),
                        width: 0.5,
                      )
                    : Border.all(
                        color: AppColors.borderDefault,
                        width: 0.5,
                      ),
              ),
              child: widget.isTyping
                  ? _buildTypingIndicator()
                  : _buildContent(),
            ),
          ),
          if (!widget.isUser && _isCopied)
            Padding(
              padding: const EdgeInsets.only(
                left: AppDimensions.sm,
                top: 2,
              ),
              child: Text(
                'Copiado',
                style: TextStyle(
                  color: AppColors.monitorGreen,
                  fontSize: AppDimensions.fontSizeXs,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.content,
          style: TextStyle(
            color: widget.isUser
                ? AppColors.textPrimary
                : AppColors.textSecondary,
            fontSize: AppDimensions.fontSizeSm,
            height: 1.5,
          ),
        ),
        if (!widget.isUser) ...[
          const SizedBox(height: AppDimensions.sm),
          GestureDetector(
            onTap: _copyToClipboard,
            child: Icon(
              Icons.copy_rounded,
              size: 14,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _typingController,
          builder: (context, child) {
            final delay = index * 0.2;
            final value = ((_typingController.value - delay) % 1.0);
            final scale = 0.4 + (0.6 * (1.0 - (value * 4 - 1).abs()).clamp(0.0, 1.0));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.textClinical,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.content));
    setState(() => _isCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }
}
