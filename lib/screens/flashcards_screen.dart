import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/study_provider.dart';

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  int _index = 0;
  bool _showBack = false;

  void _goTo(int next, int total) {
    if (next < 0 || next >= total) return;
    setState(() {
      _index = next;
      _showBack = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cards = context.watch<StudyProvider>().flashcards;
    final scheme = Theme.of(context).colorScheme;

    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Flashcards')),
        body: const Center(child: Text('Nenhum flashcard carregado.')),
      );
    }

    final card = cards[_index];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cartão ${_index + 1} de ${cards.length}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${(((_index + 1) / cards.length) * 100).round()}%',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (_index + 1) / cards.length,
                minHeight: 9,
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.92, end: 1).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutBack,
                        ),
                      ),
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    key: ValueKey(_showBack),
                    height: 350,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _showBack
                            ? [
                                scheme.tertiaryContainer,
                                scheme.secondaryContainer,
                              ]
                            : [
                                scheme.primary,
                                scheme.tertiary,
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Icon(
                            _showBack
                                ? Icons.visibility_rounded
                                : Icons.touch_app_rounded,
                            color: _showBack
                                ? scheme.onTertiaryContainer
                                : Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _showBack ? card.back : card.front,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    height: 1.3,
                                    color: _showBack
                                        ? scheme.onTertiaryContainer
                                        : Colors.white,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          _showBack
                              ? 'Toque para ver a pergunta'
                              : 'Toque para virar o cartão',
                          style: TextStyle(
                            color: _showBack
                                ? scheme.onTertiaryContainer.withOpacity(0.75)
                                : Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0
                          ? null
                          : () => _goTo(_index - 1, cards.length),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Anterior'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _index == cards.length - 1
                          ? () => Navigator.of(context).pop()
                          : () => _goTo(_index + 1, cards.length),
                      icon: Icon(
                        _index == cards.length - 1
                            ? Icons.check_rounded
                            : Icons.arrow_forward_rounded,
                      ),
                      label: Text(
                        _index == cards.length - 1 ? 'Concluir' : 'Próximo',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
