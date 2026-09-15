# Edge Function `study-ai`

Backend do StudyAI usando Gemini.

## Secret obrigatório

- `GEMINI_API_KEY`: chave criada no Google AI Studio.

## Secret opcional

- `GEMINI_MODEL`: padrão `gemini-3.5-flash-lite`.

## Segurança

A função valida o cabeçalho `apikey` contra as chaves públicas do projeto.
`verify_jwt` fica desativado porque o aplicativo acadêmico não possui login de
usuários. A chave do Gemini nunca é enviada ao Flutter.
