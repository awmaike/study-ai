import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_action.dart';
import '../providers/study_provider.dart';
import '../widgets/action_tile.dart';
import 'flashcards_screen.dart';
import 'quiz_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _contentFocus = FocusNode();
  String _explanationMode = 'simple';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  IconData _iconFor(StudyAction action) {
    switch (action) {
      case StudyAction.summary:
        return Icons.summarize_rounded;
      case StudyAction.explanation:
        return Icons.chat_bubble_outline_rounded;
      case StudyAction.quiz:
        return Icons.quiz_outlined;
      case StudyAction.flashcards:
        return Icons.style_outlined;
    }
  }

  String _subtitleFor(StudyAction action) {
    switch (action) {
      case StudyAction.summary:
        return 'Pontos principais';
      case StudyAction.explanation:
        return 'Entenda melhor';
      case StudyAction.quiz:
        return 'Teste seu conhecimento';
      case StudyAction.flashcards:
        return 'Revisão rápida';
    }
  }

  Future<void> _generate() async {
    if (_controller.text.trim().length < 30) {
      _contentFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cole um texto com pelo menos 30 caracteres para continuar.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final provider = context.read<StudyProvider>();
    final action = provider.selectedAction;

    final ok = await provider.runAction(
      content: _controller.text,
      explanationMode: _explanationMode,
    );

    if (!mounted || !ok) return;

    if (action == StudyAction.quiz) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const QuizScreen(),
        ),
      );
    } else if (action == StudyAction.flashcards) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FlashcardsScreen(),
        ),
      );
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (mounted && _scrollController.hasClients) {
        await _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      key: const PageStorageKey('study-scroll'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laboratório IA', style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    'Transforme seu conteúdo em aprendizado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: study.aiConfigured
                ? Colors.green.withOpacity(0.10)
                : scheme.secondaryContainer.withOpacity(0.55),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(
                study.aiConfigured
                    ? Icons.cloud_done_rounded
                    : Icons.offline_bolt_rounded,
                size: 20,
                color: study.aiConfigured ? Colors.green : scheme.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  study.aiConfigured
                      ? 'IA configurada — fallback offline ativo'
                      : 'Demonstração offline pronta para testar',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text('1. Adicione seu conteúdo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Text(
              'mín. 30 caracteres',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('study-content-field'),
          controller: _controller,
          focusNode: _contentFocus,
          minLines: 8,
          maxLines: 12,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText:
                'Cole aqui sua matéria, resumo da aula ou qualquer texto que queira estudar...',
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                key: const Key('load-sample-button'),
                onPressed: () {
                  setState(() => _controller.text = study.sampleContent);
                  _controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: _controller.text.length),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exemplo carregado. Agora escolha uma ação.')),
                  );
                },
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('Usar exemplo de Provider'),
              ),
            ),
            IconButton(
              tooltip: 'Limpar texto',
              onPressed: () => setState(_controller.clear),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '2. Escolha como estudar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: StudyAction.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.18,
          ),
          itemBuilder: (context, index) {
            final action = StudyAction.values[index];
            return ActionTile(
              icon: _iconFor(action),
              title: action.label,
              subtitle: _subtitleFor(action),
              selected: study.selectedAction == action,
              onTap: () => study.selectAction(action),
            );
          },
        ),
        if (study.selectedAction == StudyAction.explanation) ...[
          const SizedBox(height: 18),
          Text(
            'Nível da explicação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('🧒 Simples'),
                selected: _explanationMode == 'simple',
                onSelected: (_) =>
                    setState(() => _explanationMode = 'simple'),
              ),
              ChoiceChip(
                label: const Text('🎓 Acadêmica'),
                selected: _explanationMode == 'academic',
                onSelected: (_) =>
                    setState(() => _explanationMode = 'academic'),
              ),
              ChoiceChip(
                label: const Text('⚡ Resumida'),
                selected: _explanationMode == 'short',
                onSelected: (_) =>
                    setState(() => _explanationMode = 'short'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            key: const Key('generate-button'),
            onPressed: study.isLoading ? null : _generate,
            icon: study.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              study.isLoading
                  ? 'Analisando conteúdo...'
                  : '${study.selectedAction.label} com IA',
            ),
          ),
        ),
        if (study.errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    study.errorMessage!,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (study.lastTextResult.isNotEmpty &&
            (study.selectedAction == StudyAction.summary ||
                study.selectedAction == StudyAction.explanation)) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (study.usedDemoLastRequest)
                Chip(
                  avatar: const Icon(Icons.offline_bolt_rounded, size: 18),
                  label: const Text('Demo'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: SelectableText(
              study.lastTextResult,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
