import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/settings_provider.dart';
import '../../../ai/presentation/providers/ai_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final List<String> _aiModels = [
    'biomistral-7b-q4',
    'meditron-7b-q4',
    'clinicalcamel-7b-q4',
    'biomistral-7b-q8',
    'ii-medical-8b-q4',
    'llama3-1-8b-medical-q4',
  ];

  final List<int> _autoLockOptions = [1, 5, 15, 30];

  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Configuración'),
        actions: [
          TextButton(
            onPressed: () => _showResetDialog(notifier),
            child: const Text(
              'Restablecer',
              style: TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppDimensions.xxl),
        children: [
          _buildSecuritySection(state, notifier),
          _buildAiSection(state, notifier),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(SettingsState state, dynamic notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'SEGURIDAD', showDivider: false),
        _SettingsCard(
          children: [
            _SwitchTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometría',
              subtitle: 'Autenticación con huella o rostro',
              value: state.settings.biometricEnabled,
              onChanged: (v) {
                notifier.update(state.settings.copyWith(biometricEnabled: v));
              },
            ),
            const _Divider(),
            _DropdownTile<int>(
              icon: Icons.lock_outline_rounded,
              title: 'Bloqueo automático',
              subtitle: 'Tiempo de inactividad para bloquear',
              value: state.settings.autoLockMinutes,
              items: _autoLockOptions,
              itemLabel: (v) => v >= 60
                  ? '${v ~/ 60} hora${v ~/ 60 > 1 ? 's' : ''}'
                  : '$v min',
              onChanged: (v) {
                if (v != null) {
                  notifier.update(
                    state.settings.copyWith(autoLockMinutes: v),
                  );
                }
              },
            ),
            const _Divider(),
            _SwitchTile(
              icon: Icons.crop_square_rounded,
              title: 'Bloquear captura de pantalla',
              subtitle: 'Evita capturas en la app',
              value: state.settings.screenCaptureBlocked,
              onChanged: (v) {
                notifier.update(
                  state.settings.copyWith(screenCaptureBlocked: v),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAiSection(SettingsState state, dynamic notifier) {
    final aiState = ref.watch(aiProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
            title: 'INTELIGENCIA ARTIFICIAL', showDivider: false),
        _SettingsCard(
          children: [
            _SwitchTile(
              icon: Icons.psychology_rounded,
              title: 'IA Clínica',
              subtitle: 'Asistente con modelos locales',
              value: state.settings.aiEnabled,
              onChanged: (v) {
                notifier.update(state.settings.copyWith(aiEnabled: v));
              },
            ),
            const _Divider(),
            _DropdownTile<String>(
              icon: Icons.model_training_rounded,
              title: 'Modelo de IA',
              subtitle: state.settings.aiModel,
              value: state.settings.aiModel,
              items: _aiModels,
              itemLabel: (v) => v,
              onChanged: (v) async {
                if (v != null) {
                  final shouldDownload = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppColors.bgSecondary,
                      title: const Text('Descargar Modelo',
                          style: TextStyle(color: AppColors.textPrimary)),
                      content: Text(
                        'El modelo "$v" pesa varios Gigabytes. ¿Deseas descargarlo ahora y configurarlo como predeterminado?',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancelar',
                              style: TextStyle(color: AppColors.textDisabled)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Descargar',
                              style: TextStyle(color: AppColors.clinicalBlue)),
                        ),
                      ],
                    ),
                  );

                  if (shouldDownload == true) {
                    notifier.update(state.settings.copyWith(aiModel: v));
                    ref.read(aiProvider.notifier).downloadModel(v);
                  }
                }
              },
            ),
            if (aiState.isLoading && aiState.downloadProgress > 0.0)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.md, vertical: AppDimensions.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Descargando...',
                          style: TextStyle(
                              color: AppColors.clinicalBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                        Text(
                          '${(aiState.downloadProgress * 100).toStringAsFixed(1)}%',
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                    const Gap(8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: aiState.downloadProgress,
                        backgroundColor: AppColors.bgPrimary,
                        color: AppColors.clinicalBlue,
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            const _Divider(),
            _SliderTile(
              icon: Icons.memory_rounded,
              title: 'Contexto',
              subtitle: '${state.settings.aiContextSize} tokens',
              value: state.settings.aiContextSize.toDouble(),
              min: 512,
              max: 8192,
              divisions: 15,
              onChanged: (v) {
                notifier.update(
                  state.settings.copyWith(aiContextSize: v.round()),
                );
              },
            ),
            const _Divider(),
            _SliderTile(
              icon: Icons.thermostat_rounded,
              title: 'Temperatura',
              subtitle: state.settings.aiTemperature.toStringAsFixed(1),
              value: state.settings.aiTemperature,
              min: 0.0,
              max: 2.0,
              divisions: 20,
              onChanged: (v) {
                notifier.update(
                  state.settings.copyWith(aiTemperature: v),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    final version = _packageInfo?.version ?? '1.0.0';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ACERCA DE', showDivider: false),
        _SettingsCard(
          children: [
            _InfoTile(
              icon: Icons.info_rounded,
              title: 'Versión',
              subtitle: version,
            ),
            const _Divider(),
            _ActionTile(
              icon: Icons.description_rounded,
              title: 'Licencias',
              subtitle: 'Licencias de software de código abierto',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Guardian AI',
                applicationVersion: version,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showResetDialog(dynamic notifier) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text(
          'Restablecer configuración',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          '¿Está seguro? Se perderán todos los cambios.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              notifier.reset();
            },
            child: const Text(
              'Restablecer',
              style: TextStyle(color: AppColors.alertRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.borderDefault,
      height: 1,
      thickness: 0.5,
      indent: AppDimensions.md,
      endIndent: AppDimensions.md,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.clinicalBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.clinicalBlue, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: AppDimensions.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: AppDimensions.fontSizeXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.clinicalBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.clinicalBlue, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: AppDimensions.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: AppDimensions.fontSizeXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderDefault),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                dropdownColor: AppColors.bgSecondary,
                style: const TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: AppDimensions.fontSizeSm,
                  color: AppColors.textPrimary,
                ),
                items: items.map((v) {
                  return DropdownMenuItem(value: v, child: Text(itemLabel(v)));
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const _SliderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.clinicalBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.clinicalBlue, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'SFPro',
                          fontSize: AppDimensions.fontSizeMd,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'SFPro',
                        fontSize: AppDimensions.fontSizeXs,
                        fontWeight: FontWeight.w600,
                        color: AppColors.clinicalBlue,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: value.clamp(min, max),
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.md,
          vertical: AppDimensions.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.clinicalBlue.withAlpha(26),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.clinicalBlue, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SFPro',
                      fontSize: AppDimensions.fontSizeMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSans',
                      fontSize: AppDimensions.fontSizeXs,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.clinicalBlue.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.clinicalBlue, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'SFPro',
                    fontSize: AppDimensions.fontSizeMd,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSans',
                    fontSize: AppDimensions.fontSizeXs,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
