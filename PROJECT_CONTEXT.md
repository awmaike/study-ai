# PROJECT_CONTEXT — StudyAI

## Objetivo

Aplicativo acadêmico para a disciplina de Desenvolvimento Mobile.

Tecnologias principais:

- Flutter;
- Dart;
- Provider;
- SharedPreferences;
- HTTP/JSON;
- backend opcional com Supabase Edge Functions;
- integração com IA.

A apresentação será feita principalmente no Chrome, simulando uma tela mobile.

## Funcionalidades implementadas

### Home
- card principal;
- atalhos para Resumo, Explicação, Quiz e Flashcards;
- média;
- quantidade de quizzes;
- gráfico recente;
- último resultado.

### Laboratório IA
- área para colar conteúdo;
- conteúdo de exemplo sobre Provider;
- resumo;
- explicação simples;
- explicação acadêmica;
- explicação resumida;
- geração de quiz;
- geração de flashcards;
- loading;
- mensagens de erro;
- indicador de modo demonstração/IA.

### Quiz
- múltipla escolha;
- progresso;
- correção;
- explicação após resposta;
- pontuação;
- tela final;
- salvar resultado.

### Flashcards
- frente/verso;
- animação;
- progresso;
- anterior/próximo.

### Desempenho
- média geral;
- melhor resultado;
- questões;
- acertos;
- histórico;
- gráfico via CustomPainter.

### Ajustes
- tema escuro;
- carregar histórico de demonstração;
- limpar histórico;
- status de IA;
- tecnologias do projeto.

## Persistência

SharedPreferences armazena:

- histórico dos quizzes;
- preferência de tema.

## IA

Sem `AI_ENDPOINT`, AIService usa DemoAIService.

Com `AI_ENDPOINT`, AIService envia:

```json
{
  "action": "quiz",
  "content": "texto...",
  "mode": "simple"
}
```

Caso o backend falhe ou exceda o tempo limite, o aplicativo volta automaticamente ao modo demonstração.

## Segurança

A chave do provedor de IA não deve entrar no Flutter.
Ela deve ficar no backend.

## Próximas melhorias possíveis

- upload de PDF;
- histórico de conteúdos estudados;
- login;
- matérias/categorias;
- streak diário;
- geração de questões por dificuldade;
- leitura de imagem;
- exportação de resumo;
- backend com autenticação;
- rate limiting.

## Regra para futuras alterações

Manter o projeto prioritariamente como aplicativo Flutter/Dart de Desenvolvimento Mobile.
A IA é uma funcionalidade do app, não deve substituir os conceitos de Flutter que precisam ser demonstrados.
