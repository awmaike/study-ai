# Roteiro de apresentação — StudyAI

## Demonstração sugerida

1. Abra a Home.
2. Explique que o app foi feito com Flutter e Dart.
3. Entre em **Estudar**.
4. Clique em **Carregar exemplo sobre Provider**.
5. Gere um resumo.
6. Troque para **Explicar** e mostre a diferença entre Simples e Acadêmica.
7. Gere o Quiz.
8. Responda pelo menos duas perguntas.
9. Mostre a explicação da alternativa.
10. Finalize o Quiz.
11. Abra **Desempenho** e mostre que os dados atualizaram.
12. Gere Flashcards.
13. Mostre tema escuro em Ajustes.

## Explicação técnica curta

> O StudyAI foi desenvolvido em Flutter utilizando Dart. O estado global é gerenciado com Provider e ChangeNotifier. A interface solicita uma ação ao StudyProvider, que chama o AIService. Quando existe um backend configurado, o aplicativo envia uma requisição HTTP e recebe JSON estruturado. Esse JSON é convertido em objetos Dart para montar quiz e flashcards. Os resultados são persistidos localmente com SharedPreferences e as telas são atualizadas através de notifyListeners.

## Se perguntarem onde está o Dart

Mostrar:

- `QuizQuestion` em `models/`;
- `StudyProvider`;
- `async/await` em `AIService`;
- `jsonEncode/jsonDecode`;
- listas e classes;
- `Navigator`;
- `setState` no Quiz e Flashcards;
- `ChangeNotifier` e `notifyListeners`.

## Se perguntarem por que Provider

> Para separar o estado e a regra de negócio das telas. Quando um quiz é finalizado, o Provider atualiza o histórico e as telas interessadas são reconstruídas automaticamente.

## Se perguntarem sobre segurança da IA

> A chave secreta não fica no aplicativo. O Flutter chama um backend, e somente o backend conhece a chave do provedor de IA.

## Se a internet falhar

O StudyAI possui modo demonstração/fallback.

Use o exemplo sobre Provider. As funcionalidades continuam operando localmente.

## Frase de fechamento

> A proposta foi aplicar conceitos de Desenvolvimento Mobile em um problema real de estudo, utilizando IA como recurso adicional, mas mantendo Flutter, Dart, gerenciamento de estado, navegação, persistência e comunicação com API como base técnica do projeto.
