import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:guardian_ai/core/constants/app_colors.dart';
import 'package:guardian_ai/core/constants/app_dimensions.dart';
import 'package:guardian_ai/modules/ai/domain/entities/clinical_context.dart';
import 'package:guardian_ai/modules/ai/domain/usecases/generate_clinical_summary.dart';
import 'package:guardian_ai/modules/ai/presentation/providers/ai_provider.dart';
import 'package:guardian_ai/modules/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:guardian_ai/modules/ai/presentation/widgets/model_status_indicator.dart';
import 'package:guardian_ai/modules/ai/presentation/widgets/quick_action_chip.dart';

class AiPage extends ConsumerStatefulWidget {
  const AiPage({super.key});

  @override
  ConsumerState<AiPage> createState() => _AiPageState();
}

class _AiPageState extends ConsumerState<AiPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ref.read(aiProvider.notifier).sendMessage(text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _showMedicationDialog() {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        title: const Text(
          'Analizar Medicamento',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nombre del medicamento...',
            hintStyle: TextStyle(color: AppColors.textDisabled),
          ),
          style: const TextStyle(color: AppColors.textPrimary),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(aiProvider.notifier)
                    .analyzeMedication(controller.text.trim());
                _scrollToBottom();
              }
            },
            child: const Text(
              'Analizar',
              style: TextStyle(color: AppColors.textClinical),
            ),
          ),
        ],
      ),
    );
  }

  void _showVitalSignsDialog() {
    final fcController = TextEditingController();
    final paController = TextEditingController();
    final frController = TextEditingController();
    final tempController = TextEditingController();
    final satController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        title: const Text(
          'Interpretar Signos Vitales',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _vitalField('FC (lpm)', fcController),
              _vitalField('PA (mmHg)', paController),
              _vitalField('FR (rpm)', frController),
              _vitalField('Temperatura (°C)', tempController),
              _vitalField('SatO₂ (%)', satController),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final vitals = <String, dynamic>{};
              if (fcController.text.trim().isNotEmpty) {
                vitals['FC'] = '${fcController.text.trim()} lpm';
              }
              if (paController.text.trim().isNotEmpty) {
                vitals['PA'] = '${paController.text.trim()} mmHg';
              }
              if (frController.text.trim().isNotEmpty) {
                vitals['FR'] = '${frController.text.trim()} rpm';
              }
              if (tempController.text.trim().isNotEmpty) {
                vitals['Temperatura'] = '${tempController.text.trim()} °C';
              }
              if (satController.text.trim().isNotEmpty) {
                vitals['SatO₂'] = '${satController.text.trim()}%';
              }
              if (vitals.isNotEmpty) {
                ref.read(aiProvider.notifier).analyzeVitals(vitals);
                _scrollToBottom();
              }
            },
            child: const Text(
              'Interpretar',
              style: TextStyle(color: AppColors.textClinical),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vitalField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.sm),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          hintStyle: const TextStyle(color: AppColors.textDisabled),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderDefault),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.borderFocused),
          ),
        ),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiState = ref.watch(aiProvider);
    final notifier = ref.read(aiProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.deepBlack,
      appBar: AppBar(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
        title: const Text(
          'Asistente Clínico',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_rounded,
                color: AppColors.clinicalBlue),
            onPressed: () => context.push('/calculators'),
            tooltip: 'Calculadoras clínicas',
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded,
                color: AppColors.textSecondary),
            onPressed: () => context.push('/settings'),
            tooltip: 'Configuración',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary),
            onPressed: () => notifier.clearConversation(),
            tooltip: 'Limpiar conversación',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildModelIndicator(aiState),
          if (aiState.clinicalContext != null)
            _buildClinicalContextBanner(aiState),
          _buildQuickActions(aiState),
          Expanded(
            child: _buildConversationList(aiState),
          ),
          if (aiState.isLoading) _buildLoadingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildModelIndicator(AiState aiState) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        0,
      ),
      child: ModelStatusIndicator(
        model: aiState.selectedModel,
        isLoaded: aiState.isLoaded,
        memoryUsage: aiState.memoryUsage,
        downloadProgress: aiState.downloadProgress,
        isDownloading: aiState.isLoading && aiState.downloadProgress > 0,
      ),
    );
  }

  Widget _buildClinicalContextBanner(AiState aiState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.statusInfo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadiusSmall),
        border: Border.all(
          color: AppColors.statusInfo.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.medical_information_rounded,
            size: AppDimensions.iconSizeSmall,
            color: AppColors.statusInfo,
          ),
          const SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              aiState.clinicalContext!.summary,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppDimensions.fontSizeXs,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.textDisabled,
            ),
            onPressed: () => ref.read(aiProvider.notifier).clearResponse(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(AiState aiState) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        AppDimensions.sm,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            QuickActionChip(
              icon: Icons.medication_rounded,
              label: 'Analizar Medicamento',
              onPressed: _showMedicationDialog,
              isEnabled: !aiState.isLoading,
            ),
            const SizedBox(width: AppDimensions.sm),
            QuickActionChip(
              icon: Icons.summarize_rounded,
              label: 'Resumen Clínico',
              onPressed: () {
                ref.read(aiProvider.notifier).generateSummary(
                      context:
                          aiState.clinicalContext ?? const ClinicalContext(),
                      format: SummaryFormat.soap,
                    );
                _scrollToBottom();
              },
              isEnabled: !aiState.isLoading,
            ),
            const SizedBox(width: AppDimensions.sm),
            QuickActionChip(
              icon: Icons.monitor_heart_rounded,
              label: 'Interpretar Signos',
              onPressed: _showVitalSignsDialog,
              isEnabled: !aiState.isLoading,
            ),
            const SizedBox(width: AppDimensions.sm),
            QuickActionChip(
              icon: Icons.local_hospital_rounded,
              label: 'Recomendación NANDA',
              onPressed: () {
                ref.read(aiProvider.notifier).generateSummary(
                      context:
                          aiState.clinicalContext ?? const ClinicalContext(),
                      format: SummaryFormat.nanda,
                    );
                _scrollToBottom();
              },
              isEnabled: !aiState.isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationList(AiState aiState) {
    if (aiState.conversationHistory.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      itemCount: aiState.conversationHistory.length,
      itemBuilder: (context, index) {
        final response = aiState.conversationHistory[index];
        return AiMessageBubble(
          content: response.content,
          isUser: index.isOdd && response.content.length < 100,
          category: response.category,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.clinicalGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textClinical.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_rounded,
                size: 40,
                color: AppColors.deepBlack,
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text(
              'Asistente Clínico IA',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppDimensions.fontSizeXl,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Realice una consulta clínica o use los\naccesos rápidos para análisis específicos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textDisabled,
                fontSize: AppDimensions.fontSizeSm,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppDimensions.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pulsingDot(),
          const SizedBox(width: 6),
          _pulsingDot(),
          const SizedBox(width: 6),
          _pulsingDot(),
        ],
      ),
    );
  }

  Widget _pulsingDot() {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.textClinical.withValues(alpha: 0.7),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        AppDimensions.sm,
        AppDimensions.md,
        AppDimensions.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius:
                    BorderRadius.circular(AppDimensions.cardRadiusSmall),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Escriba su consulta clínica...',
                  hintStyle: TextStyle(color: AppColors.textDisabled),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.md,
                    vertical: AppDimensions.md,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: AppDimensions.fontSizeSm,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.sm),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.clinicalGradient,
              borderRadius:
                  BorderRadius.circular(AppDimensions.cardRadiusSmall),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.deepBlack),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
