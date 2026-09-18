# Edge Function `study-ai`

Backend do StudyAI usando Gemini.

## Quiz

`quiz.ts` define as instruções e valida as perguntas, alternativas, gabaritos e
trechos de apoio copiados do texto. `questionCount` permite 5, 10 ou 15 perguntas
(padrão 10), e `difficulty` aceita `easy`, `medium` ou `hard` (padrão `medium`).
Para temas, exige a quantidade selecionada e citações vazias; o conteúdo vem do
conhecimento do modelo. Para textos, aceita menos questões se o material for curto.
`study_input.ts` detecta temas para clientes sem `inputMode` explícito.
Essa verificação confirma a presença do
trecho, mas a avaliação semântica da resposta depende do modelo.

Execute os testes com Node.js 24:

```sh
node --test supabase/functions/study-ai/quiz_test.ts
```

## Secret obrigatório

- `GEMINI_API_KEY`: chave criada no Google AI Studio.

## Secret opcional

- `GEMINI_MODEL`: padrão `gemini-3.5-flash-lite`.

## Segurança

A função valida o cabeçalho `apikey` e verifica o token do usuário no Supabase
Auth antes de chamar o Gemini. `verify_jwt` continua desativado na plataforma;
a função faz essa verificação explicitamente. A chave do Gemini nunca é enviada
ao Flutter.
