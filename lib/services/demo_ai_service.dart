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
        return _genericQuiz(content);
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
          'result':
              '• Provider é usado para gerenciamento de estado no Flutter.\n'
              '• ChangeNotifier guarda o estado e chama notifyListeners() quando algo muda.\n'
              '• ChangeNotifierProvider disponibiliza o estado para a árvore de widgets.\n'
              '• Consumer reconstrói apenas a parte da interface que depende daquele estado.\n'
              '• O padrão ajuda a separar interface e regra de negócio.'
        };

      case StudyAction.explanation:
        if (mode == 'academic') {
          return {
            'result':
                'Provider é uma solução de gerenciamento e injeção de dependências no Flutter. '
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
          'result':
              'Imagine que vários widgets precisam saber a mesma informação, como a pontuação de um quiz. '
              'O Provider funciona como um quadro de avisos: o estado fica em um lugar central e, quando muda, '
              'ele avisa apenas os widgets interessados para atualizarem a tela.'
        };

      case StudyAction.quiz:
        return {
          'title': 'Quiz: Provider no Flutter',
          'questions': [
            {
              'question': 'Qual é a principal função do Provider?',
              'options': [
                'Gerenciar estado',
                'Criar banco de dados',
                'Compilar o aplicativo',
                'Substituir o Navigator'
              ],
              'correctIndex': 0,
              'explanation':
                  'Provider é usado principalmente para compartilhar e gerenciar estado.'
            },
            {
              'question': 'Qual classe pode chamar notifyListeners()?',
              'options': [
                'Scaffold',
                'ChangeNotifier',
                'MaterialApp',
                'Navigator'
              ],
              'correctIndex': 1,
              'explanation':
                  'ChangeNotifier possui notifyListeners(), usado para avisar seus ouvintes.'
            },
            {
              'question': 'Para que serve ChangeNotifierProvider?',
              'options': [
                'Salvar arquivos',
                'Gerar rotas automaticamente',
                'Disponibilizar um ChangeNotifier na árvore',
                'Criar animações'
              ],
              'correctIndex': 2,
              'explanation':
                  'Ele disponibiliza a instância para os widgets descendentes.'
            },
            {
              'question': 'Qual widget pode ouvir mudanças de um Provider?',
              'options': [
                'Consumer',
                'Image',
                'Divider',
                'SafeArea'
              ],
              'correctIndex': 0,
              'explanation':
                  'Consumer reconstrói sua parte da interface quando o estado observado muda.'
            },
            {
              'question': 'Qual benefício do Provider aparece no conteúdo?',
              'options': [
                'Aumenta o tamanho do APK',
                'Elimina todo uso de classes',
                'Separa regra de negócio da interface',
                'Impede navegação entre telas'
              ],
              'correctIndex': 2,
              'explanation':
                  'A separação entre estado/regra de negócio e UI é um benefício importante.'
            }
          ]
        };

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

  Map<String, dynamic> _genericQuiz(String content) {
    final words = _keywords(content);
    final topic = words.isNotEmpty ? words.first : 'conteúdo';

    return {
      'title': 'Quiz sobre $topic',
      'questions': [
        {
          'question': 'Qual termo aparece como um dos principais no conteúdo?',
          'options': [
            topic,
            'Fotossíntese',
            'Astronomia',
            'Geografia física'
          ],
          'correctIndex': 0,
          'explanation':
              'O termo "$topic" foi identificado diretamente no conteúdo fornecido.'
        },
        {
          'question': 'O quiz foi criado a partir de qual fonte?',
          'options': [
            'Do texto informado pelo usuário',
            'De uma tabela fixa',
            'De um arquivo de imagem',
            'De um mapa'
          ],
          'correctIndex': 0,
          'explanation':
              'O StudyAI usa o conteúdo digitado como contexto para gerar o material.'
        },
        {
          'question': 'Qual ação ajuda a revisar conceitos rapidamente?',
          'options': [
            'Ignorar o conteúdo',
            'Usar perguntas e respostas',
            'Fechar o aplicativo',
            'Excluir o texto'
          ],
          'correctIndex': 1,
          'explanation':
              'Perguntas e respostas são uma forma prática de revisão ativa.'
        }
      ]
    };
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

  List<String> _keywords(String content) {
    const blocked = {
      'para',
      'como',
      'uma',
      'com',
      'dos',
      'das',
      'que',
      'por',
      'mais',
      'quando',
      'onde',
      'este',
      'essa',
      'isso',
      'seus',
      'suas',
      'entre',
      'sobre',
    };

    final words = content
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-záàâãéèêíïóôõöúçñ\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 5 && !blocked.contains(w));

    final counts = <String, int>{};
    for (final word in words) {
      counts[word] = (counts[word] ?? 0) + 1;
    }

    final ordered = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ordered.take(6).map((entry) => entry.key).toList();
  }

  String _shorten(String value, int max) {
    final clean = value.trim();
    if (clean.length <= max) return clean;
    return '${clean.substring(0, max).trim()}...';
  }
}
