import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/modules/calculators/domain/entities/calculation_result.dart';

class ResultCard extends StatelessWidget {
  final CalculationResult result;

  const ResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: result.isCritical
            ? AppColors.alertGradient
            : result.isWarning
                ? const LinearGradient(
                    colors: [Color(0xFFFFB347), Color(0xFFFF8C00)],
                  )
                : AppColors.clinicalGradient,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: (result.isCritical
                    ? AppColors.alertRed
                    : result.isWarning
                        ? AppColors.statusWarning
                        : AppColors.clinicalBlue)
                .withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: AppDimensions.cardPaddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'RESULTADO',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'SFPro',
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                if (result.isCritical)
                  _buildBadge('CRÍTICO', AppColors.alertRed),
                if (result.isWarning && !result.isCritical)
                  _buildBadge('PRECAUCIÓN', AppColors.statusWarning),
              ],
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              result.label,
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: AppDimensions.fontSizeSm,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              result.result.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppDimensions.fontSizeDisplay,
                fontWeight: FontWeight.w700,
                fontFamily: 'Inter',
                height: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              result.unit,
              style: TextStyle(
                color: Colors.white.withAlpha(200),
                fontSize: AppDimensions.fontSizeLg,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w500,
              ),
            ),
            if (result.description != null) ...[
              const SizedBox(height: AppDimensions.md + 4),
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardRadiusSmall),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      result.isCritical
                          ? Icons.warning
                          : result.isWarning
                              ? Icons.info_outline
                              : Icons.info,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        result.description!,
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: AppDimensions.fontSizeXs,
                          fontFamily: 'IBMPlexSans',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (result.details != null && result.details!.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.md),
              Container(
                padding: const EdgeInsets.all(AppDimensions.md),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.cardRadiusSmall),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calculate,
                          color: Colors.white.withAlpha(180),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'DESGLOSE DEL CÁLCULO',
                          style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'SFPro',
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    ...result.details!.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                color: Colors.white.withAlpha(200),
                                fontSize: AppDimensions.fontSizeXs,
                                fontFamily: 'IBMPlexSans',
                              ),
                            ),
                            Text(
                              entry.value.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppDimensions.fontSizeXs,
                                fontFamily: 'SFPro',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  final text =
                      '${result.label}: ${result.result.toStringAsFixed(2)} ${result.unit}';
                  Clipboard.setData(ClipboardData(text: text));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Resultado copiado al portapapeles'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.copy, size: 18, color: Colors.white),
                label: const Text(
                  'Copiar resultado',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(150), width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          fontFamily: 'SFPro',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
