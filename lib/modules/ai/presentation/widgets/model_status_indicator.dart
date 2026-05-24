import 'package:flutter/material.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/modules/ai/domain/entities/ai_model_info.dart';

class ModelStatusIndicator extends StatelessWidget {
  final AiModelInfo? model;
  final bool isLoaded;
  final double memoryUsage;
  final double downloadProgress;
  final bool isDownloading;

  const ModelStatusIndicator({
    super.key,
    this.model,
    this.isLoaded = false,
    this.memoryUsage = 0.0,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
        border: Border.all(
          color: isLoaded
              ? AppColors.monitorGreen.withOpacity(0.3)
              : AppColors.borderDefault,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isLoaded
                      ? AppColors.monitorGreen
                      : AppColors.alertRed,
                  boxShadow: isLoaded
                      ? [
                          BoxShadow(
                            color: AppColors.monitorGreen.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: AppDimensions.sm),
              Expanded(
                child: Text(
                  isLoaded
                      ? 'Modelo cargado'
                      : 'Sin modelo activo',
                  style: TextStyle(
                    color: isLoaded
                        ? AppColors.monitorGreen
                        : AppColors.textSecondary,
                    fontSize: AppDimensions.fontSizeSm,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (model != null) ...[
            const SizedBox(height: AppDimensions.sm),
            Text(
              model!.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppDimensions.fontSizeXs,
              ),
            ),
            Text(
              model!.formattedSize,
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppDimensions.fontSizeXs,
              ),
            ),
          ],
          if (isLoaded) ...[
            const SizedBox(height: AppDimensions.sm),
            _buildMemoryBar(),
          ],
          if (isDownloading) ...[
            const SizedBox(height: AppDimensions.sm),
            _buildDownloadProgress(),
          ],
        ],
      ),
    );
  }

  Widget _buildMemoryBar() {
    final maxMemory = 4096.0;
    final percentage = (memoryUsage / maxMemory).clamp(0.0, 1.0);
    final isHigh = percentage > 0.8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Memoria',
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppDimensions.fontSizeXs,
              ),
            ),
            Text(
              '${memoryUsage.toStringAsFixed(0)} MB / ${maxMemory.toStringAsFixed(0)} MB',
              style: TextStyle(
                color: isHigh ? AppColors.statusWarning : AppColors.textSecondary,
                fontSize: AppDimensions.fontSizeXs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.bgInput,
            valueColor: AlwaysStoppedAnimation<Color>(
              isHigh
                  ? AppColors.statusWarning
                  : AppColors.monitorGreen,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Descargando...',
              style: TextStyle(
                color: AppColors.textClinical,
                fontSize: AppDimensions.fontSizeXs,
              ),
            ),
            Text(
              '${(downloadProgress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppDimensions.fontSizeXs,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: downloadProgress,
            backgroundColor: AppColors.bgInput,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.textClinical,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
