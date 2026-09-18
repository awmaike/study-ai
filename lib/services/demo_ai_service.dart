import '../models/study_action.dart';

class DemoAIService {
  static const sampleContent = '''
Provider é um pacote muito utilizado no Flutter para gerenciamento de estado.
Ele permite disponibilizar dados para diferentes widgets da árvore de forma organizada.
ChangeNotifier é uma classe que pode notificar seus ouvintes quando o estado muda.
ChangeNotifierProvider disponibiliza uma instância de ChangeNotifier para os widgets descendentes.
Consumer permite reconstruir apenas a parte da interface que depende daquele estado.
O uso correto do Provider ajuda a separar regra de negócio da interface e reduz chamadas desnecessárias de setState.
''';

  Map<String, dynamic> process({
    required StudyAction action,
    required String content,
    String explanationMode = 'simple',
  }) {
    final lower = content.toLowerCase();
    final providerSample =
        lower.contains('provider') && lower.contains('flutter');

    if (providerSample) {
      return _providerResponse(action, explanationMode);
    }

    switch (action) {
      case StudyAction.summary:
        return {'result': _genericSummary(content)};
      case StudyAction.explanation:
        return {
          'result': _genericExplanation(content, explanationMode),
        };
      case StudyAction.quiz:
        throw StateError(
            'Conecte a IA para gerar perguntas sobre o seu texto.');
      case StudyAction.flashcards:
        return _genericFlashcards(content);
    }
  }

  Map<String, dynamic> _providerResponse(
    StudyAction action,
    String mode,
  ) {
    switch (action) {
      case StudyAction.summary:
        return {
          'result': '• Provider é usado para gerenciamento de estado no Flutter.\n'
              '• ChangeNotifier guarda o estado e chama notifyListeners() quando algo muda.\n'
              '• ChangeNotifierProvider disponibiliza o estado para a árvore de widgets.\n'
              '• Consumer reconstrói apenas a parte da interface que depende daquele estado.\n'
              '• O padrão ajuda a separar interface e regra de negócio.'
        };

      case StudyAction.explanation:
        if (mode == 'academic') {
          return {
            'result': 'Provider é uma solução de gerenciamento e injeção de dependências no Flutter. '
                'Um ChangeNotifier encapsula dados mutáveis e notifica listeners através de '
                'notifyListeners(). O ChangeNotifierProvider expõe essa instância à subárvore, '
                'enquanto Consumer ou context.watch observam alterações e provocam reconstruções '
                'seletivas da interface. Esse fluxo melhora a separação de responsabilidades.'
          };
        }

        if (mode == 'short') {
          return {
            'result':
                'Provider compartilha e atualiza estados entre widgets sem precisar espalhar setState pela aplicação.'
          };
        }

        return {
          'result': 'Imagine que vários widgets precisam saber a mesma informação, como a pontuação de um quiz. '
              'O Provider funciona como um quadro de avisos: o estado fica em um lugar central e, quando muda, '
              'ele avisa apenas os widgets interessados para atualizarem a tela.'
        };

      case StudyAction.quiz:
        throw StateError(
            'Conecte a IA para gerar perguntas sobre o seu texto.');

      case StudyAction.flashcards:
        return {
          'cards': [
            {
              'front': 'O que é Provider?',
              'back':
                  'Pacote usado para gerenciamento e compartilhamento de estado no Flutter.'
            },
            {
              'front': 'O que faz ChangeNotifier?',
              'back':
                  'Mantém estado mutável e avisa listeners quando notifyListeners() é chamado.'
            },
            {
              'front': 'O que faz ChangeNotifierProvider?',
              'back':
                  'Disponibiliza um ChangeNotifier para widgets descendentes.'
            },
            {
              'front': 'Para que serve Consumer?',
              'back':
                  'Observa um Provider e reconstrói a parte necessária da interface.'
            },
            {
              'front': 'Por que usar Provider?',
              'back':
                  'Para organizar o estado e separar a regra de negócio da interface.'
            }
          ]
        };
    }
  }

  String _genericSummary(String content) {
    final sentences = _sentences(content);
    final selected = sentences.take(4).toList();

    if (selected.isEmpty) {
      return 'Não foi possível identificar conteúdo suficiente para resumir.';
    }

    return selected.map((item) => '• ${_shorten(item, 180)}').join('\n');
  }

  String _genericExplanation(String content, String mode) {
    final summary = _genericSummary(content).replaceAll('• ', '');

    if (mode == 'academic') {
      return 'Em termos acadêmicos, o conteúdo apresenta os seguintes conceitos centrais: $summary';
    }
    if (mode == 'short') {
      return _shorten(summary, 300);
    }
    return 'Em palavras simples: $summary';
  }

  Map<String, dynamic> _genericFlashcards(String content) {
    final sentences = _sentences(content).take(5).toList();
    final cards = <Map<String, String>>[];

    for (var i = 0; i < sentences.length; i++) {
      cards.add({
        'front': 'Conceito ${i + 1}',
        'back': _shorten(sentences[i], 220),
      });
    }

    if (cards.isEmpty) {
      cards.add({
        'front': 'Conteúdo',
        'back': 'Cole um texto maior para gerar cartões de estudo.',
      });
    }

    return {'cards': cards};
  }

  List<String> _sentences(String content) {
    return content
        .replaceAll(RegExp(r'\s+'), ' ')
        .split(RegExp(r'[.!?]+\s*'))
        .map((item) => item.trim())
        .where((item) => item.length > 20)
        .toList();
  }

  String _shorten(String value, int max) {
    final clean = value.trim();
    if (clean.length <= max) return clean;
    return '${clean.substring(0, max).trim()}...';
  }
}
