import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_action.dart';
import '../providers/study_provider.dart';
import '../widgets/action_tile.dart';
import '../widgets/mini_line_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenStudy});

  final void Function([StudyAction? action]) onOpenStudy;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;
    final chartValues = study.recentPercentages.isEmpty
        ? <double>[42, 56, 51, 69, 76, 84]
        : study.recentPercentages;

    return ListView(
      key: const PageStorageKey('home-scroll'),
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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withOpacity(.22),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_alt_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, Maike 👋',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 1),
                  Text('StudyAI', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Notificações',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Você está em dia com os estudos!')),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF211D58), Color(0xFF5B52F2), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -42,
                  top: -48,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(.09),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: -58,
                  child: Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF70E8DD).withOpacity(.16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(23),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.13),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(.14)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFFBDF9F2), size: 16),
                            SizedBox(width: 6),
                            Text(
                              'ESTUDE COM INTELIGÊNCIA ARTIFICIAL',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .55,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Sua matéria fica mais simples aqui.',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              height: 1.06,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Crie resumos, explicações, quizzes e flashcards em poucos segundos.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(.78),
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        key: const Key('home-start-button'),
                        onPressed: () => onOpenStudy(),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4B43D5),
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Começar agora'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _SectionTitle(
          title: 'Ações rápidas',
          subtitle: 'Escolha como você quer estudar',
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.02,
          children: [
            ActionTile(
              icon: Icons.subject_rounded,
              title: 'Resumir',
              subtitle: 'Veja apenas o essencial',
              onTap: () => onOpenStudy(StudyAction.summary),
            ),
            ActionTile(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Explicar',
              subtitle: 'Entenda do seu jeito',
              onTap: () => onOpenStudy(StudyAction.explanation),
            ),
            ActionTile(
              icon: Icons.quiz_outlined,
              title: 'Criar quiz',
              subtitle: 'Teste seu conhecimento',
              onTap: () => onOpenStudy(StudyAction.quiz),
            ),
            ActionTile(
              icon: Icons.style_outlined,
              title: 'Flashcards',
              subtitle: 'Revise mais rápido',
              onTap: () => onOpenStudy(StudyAction.flashcards),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const _SectionTitle(
          title: 'Seu progresso',
          subtitle: 'Continue construindo sua evolução',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _Metric(value: '${study.averagePercentage.round()}%', label: 'Média geral', color: scheme.primary),
                  Container(width: 1, height: 42, color: scheme.outlineVariant),
                  _Metric(value: '${study.quizzesCompleted}', label: 'Quizzes feitos', color: scheme.secondary),
                  Container(width: 1, height: 42, color: scheme.outlineVariant),
                  _Metric(value: '${study.totalCorrect}', label: 'Acertos', color: scheme.tertiary),
                ],
              ),
              const SizedBox(height: 20),
              MiniLineChart(values: chartValues, height: 118),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  study.history.isEmpty ? 'Prévia de desempenho' : 'Últimos resultados',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
