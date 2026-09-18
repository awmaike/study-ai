import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:study_ai/models/study_action.dart';
import 'package:study_ai/models/study_input.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/demo_ai_service.dart';

void main() {
  const content =
      'O calor do Sol provoca a evaporação da água de rios e oceanos.';
  AIService service(MockClient client) => AIService(
        client: client,
        apiEndpoint: 'https://example.test/quiz',
        apiKey: 'test',
      );

  test('envia o texto e preserva perguntas e gabarito da IA', () async {
    final quiz = {
      'title': 'Quiz: ciclo da água',
      'questions': [
        {
          'question': 'Qual processo é provocado pelo calor do Sol?',
          'options': [
            'Condensação',
            'Evaporação',
            'Precipitação',
            'Infiltração'
          ],
          'correctIndex': 1,
          'explanation': content,
        },
      ],
    };
    final ai = service(MockClient((request) async {
      expect(jsonDecode(request.body)['content'], content);
      expect(jsonDecode(request.body)['action'], 'quiz');
      expect(jsonDecode(request.body)['inputMode'], 'text');
      return http.Response(jsonEncode(quiz), 200,
          headers: {'content-type': 'application/json; charset=utf-8'});
    }));
    final result = await ai.process(action: StudyAction.quiz, content: content);
    expect(result.usedDemo, isFalse);
    expect(result.data, quiz);
  });

  test('envia token de sessão na chamada da IA', () async {
    final ai = AIService(
      apiEndpoint: 'https://example.test/quiz',
      apiKey: 'public-key',
      accessToken: () => 'session-token',
      client: MockClient((request) async {
        expect(request.headers['apikey'], 'public-key');
        expect(request.headers['authorization'], 'Bearer session-token');
        return http.Response(jsonEncode({'result': 'Resumo pronto.'}), 200);
      }),
    );
    final result = await ai.process(
      action: StudyAction.summary,
      content: content,
    );
    expect(result.data['result'], 'Resumo pronto.');
  });

  test('sem configuração não gera quiz genérico, nem sobre Provider', () async {
    final ai = AIService(apiEndpoint: '', apiKey: '');
    for (final text in [content, DemoAIService.sampleContent]) {
      await expectLater(
          ai.process(action: StudyAction.quiz, content: text), throwsException);
      expect(
          () =>
              DemoAIService().process(action: StudyAction.quiz, content: text),
          throwsStateError);
    }
  });

  test('falha, timeout ou resposta inválida não viram quiz de demonstração',
      () async {
    for (final client in [
      MockClient((_) async => http.Response('{}', 502)),
      MockClient((_) async => throw TimeoutException('timeout')),
      MockClient((_) async => throw http.ClientException('offline')),
      MockClient((_) async => http.Response('invalid json', 200)),
      MockClient((_) async => http.Response('{"questions":[]}', 200)),
      MockClient((_) async => http.Response(
          jsonEncode({
            'questions': [
              {
                'question': 'Pergunta',
                'options': ['A', 'A', 'B', 'C'],
                'correctIndex': 9,
                'explanation': 'Texto'
              },
            ]
          }),
          200)),
    ]) {
      await expectLater(
          service(client).process(action: StudyAction.quiz, content: content),
          throwsException);
    }
  });

  test('resumo continua disponível sem conexão', () async {
    final ai = service(MockClient((_) async => http.Response('{}', 502)));
    final result =
        await ai.process(action: StudyAction.summary, content: content);
    expect(result.usedDemo, isTrue);
    expect(result.data['result'], contains('evaporação'));
  });

  test('reconhece temas de uma palavra, siglas e títulos', () {
    for (final topic in ['Valorant', 'IA', 'Revolução Industrial', '  C++  ']) {
      expect(isStudyTopic(topic), isTrue);
    }
    for (final text in ['', '  ', content, 'Um título\nUm parágrafo']) {
      expect(isStudyTopic(text), isFalse);
    }
  });

  test('tema aceita dez perguntas e rejeita quiz incompleto', () async {
    for (final count in [10, 2, 11]) {
      final ai = service(MockClient((request) async {
        expect(jsonDecode(request.body)['inputMode'], 'topic');
        return http.Response(
            jsonEncode({
              'title': 'Quiz: Valorant',
              'questions': List.generate(
                  count,
                  (i) => {
                        'question': 'Questão $i',
                        'options': ['A', 'B', 'C', 'D'],
                        'correctIndex': i % 4,
                        'explanation': 'Justificativa $i',
                      }),
            }),
            200);
      }));
      final result = ai.process(action: StudyAction.quiz, content: 'Valorant');
      if (count == 10) {
        expect((await result).data['questions'], hasLength(10));
      } else {
        await expectLater(result, throwsException);
      }
    }
  });

  test('tema sem IA não recebe resumo local vazio', () async {
    for (final ai in [
      AIService(apiEndpoint: '', apiKey: ''),
      service(MockClient((_) async => http.Response('{}', 502))),
    ]) {
      await expectLater(
          ai.process(action: StudyAction.summary, content: 'Valorant'),
          throwsException);
    }
  });

  test('envia quantidade e dificuldade e aceita quinze perguntas', () async {
    final ai = service(MockClient((request) async {
      final body = jsonDecode(request.body);
      expect(body['questionCount'], 15);
      expect(body['difficulty'], 'hard');
      return http.Response(
          jsonEncode({
            'questions': List.generate(
                15,
                (i) => {
                      'question': 'Questão $i',
                      'options': ['A', 'B', 'C', 'D'],
                      'correctIndex': i % 4,
                      'explanation': 'Justificativa $i',
                    })
          }),
          200);
    }));
    final response = await ai.process(
        action: StudyAction.quiz,
        content: 'Flutter',
        questionCount: 15,
        difficulty: 'hard');
    expect(response.data['questions'], hasLength(15));
    await expectLater(
        ai.process(
            action: StudyAction.quiz, content: 'Flutter', questionCount: 100),
        throwsArgumentError);
  });
}
