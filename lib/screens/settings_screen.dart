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
          'Personalize o aplicativo e prepare a demonstração.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 22),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.6),
            ),
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
                leading: Icon(
                  study.aiConfigured
                      ? Icons.cloud_done_rounded
                      : Icons.science_outlined,
                  color: study.aiConfigured ? Colors.green : scheme.primary,
                ),
                title: Text(
                  study.aiConfigured ? 'IA configurada' : 'Modo demonstração',
                ),
                subtitle: Text(
                  study.aiConfigured
                      ? 'O app tentará usar o backend e cai para o modo demo se necessário.'
                      : 'Sem endpoint configurado. Todas as telas continuam funcionando.',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'Demonstração',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded),
                title: const Text('Carregar histórico de exemplo'),
                subtitle: const Text(
                  'Preenche os gráficos com dados para testar a apresentação.',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await context.read<StudyProvider>().seedDemoHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Dados de demonstração carregados.'),
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
        const SizedBox(height: 22),
        Text(
          'Sobre o projeto',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: scheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.psychology_alt_rounded,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'StudyAI',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text('Flutter + Dart • Trabalho acadêmico'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Tecnologias demonstradas:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '• Flutter e Dart\n'
                '• Provider / ChangeNotifier\n'
                '• Navegação entre telas\n'
                '• HTTP + JSON\n'
                '• SharedPreferences\n'
                '• Tema claro e escuro\n'
                '• Integração preparada para IA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.55,
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
