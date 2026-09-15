# IA real do StudyAI — Gemini + Supabase

O backend `study-ai` já está publicado no projeto Supabase secundário e a chave
do Gemini já foi cadastrada nos Secrets.

## Configuração já concluída

O secret abaixo existe apenas no Supabase e não precisa ser recriado em outro
computador:

```text
Nome: GEMINI_API_KEY
Valor: protegido no Supabase
```

O modelo padrão do backend é `gemini-3.5-flash-lite`. Não é necessário cadastrar o
modelo manualmente. Para trocar no futuro, crie o secret `GEMINI_MODEL`.

## Executar o aplicativo

No Windows, execute `run_study_ai.bat`. No Linux ou macOS, execute
`./run_study_ai.sh`. Também é possível usar diretamente:

```powershell
flutter run -d chrome --dart-define=AI_ENDPOINT=https://abyivhafxbutmvgudktw.supabase.co/functions/v1/study-ai --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_SOOZgD8Lx2yPMhcyWazyBA_5QpODy4W
```

No topo da tela **Estudar** deve aparecer:

```text
IA configurada — fallback offline ativo
```

Se o Gemini ficar indisponível, o aplicativo continua funcionando com o modo
de demonstração local.

## Segurança

- `GEMINI_API_KEY` fica somente nos Secrets do Supabase.
- A chave pública do Supabase pode ficar no aplicativo e tem privilégios baixos.
- A função confere essa chave pública antes de aceitar a requisição.
- O endpoint não altera nem consulta a tabela `uptime_checks` do outro sistema.
