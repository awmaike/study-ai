import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/study_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text(
          'Os resultados dos quizzes salvos neste navegador serão apagados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<StudyProvider>().clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
      children: [
        Text(
          'Ajustes',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Personalize sua experiência de estudo.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 22),
        Material(
          color: scheme.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: theme.darkMode,
                onChanged: theme.setDarkMode,
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Tema escuro'),
                subtitle: const Text('Altere a aparência do StudyAI.'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Meta diária de questões'),
                subtitle: const Text('Quizzes concluídos no dia'),
                trailing: DropdownButton<int>(
                  value: study.dailyGoal,
                  underline: const SizedBox.shrink(),
                  items: [5, 10, 15, 20]
                      .map((value) => DropdownMenuItem(
                          value: value, child: Text('$value')))
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    try {
                      await context.read<StudyProvider>().setDailyGoal(value);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Não foi possível salvar a meta.'),
                          ),
                        );
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Histórico',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Material(
          color: scheme.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side:
                BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: const Text('Carregar histórico de exemplo'),
                subtitle: const Text(
                  'Preenche os gráficos com resultados de exemplo.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await context.read<StudyProvider>().seedDemoHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Histórico de exemplo carregado.'),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: scheme.error,
                ),
                title: Text(
                  'Limpar histórico',
                  style: TextStyle(color: scheme.error),
                ),
                subtitle: const Text('Apaga apenas os resultados locais.'),
                onTap: () => _confirmClear(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
