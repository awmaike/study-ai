# StudyAI — Flutter + Dart + IA

## Versão 1.2 — IA real e execução em outro computador

- navegação refeita com `PageController`;
- Home redesenhada com visual moderno;
- tema claro e escuro aprimorados;
- feedback visível ao carregar conteúdo ou tentar gerar sem texto;
- teste automatizado da troca entre as telas principais;
- integração real com Gemini por uma Supabase Edge Function já publicada;
- inicializadores para Windows, Linux e macOS.

Projeto acadêmico mobile em Flutter para transformar conteúdos em:

- resumos;
- explicações em três níveis;
- quizzes;
- flashcards;
- estatísticas de desempenho.

O projeto foi pensado para ser apresentado no **Chrome em formato mobile**, mas a interface também funciona em um dispositivo móvel.

## 1. O que já funciona sem configurar IA

O StudyAI abre em **Modo Demonstração** e já permite testar todas as telas.

O exemplo sobre Provider possui respostas, quiz e flashcards prontos. Para textos diferentes, o modo demonstração usa uma lógica local simples.

Também já existem:

- Provider / ChangeNotifier;
- Navigator;
- HTTP e JSON preparados;
- SharedPreferences;
- tema claro e escuro;
- histórico dos quizzes;
- gráfico desenhado com CustomPainter;
- modo offline/fallback;
- teste unitário de conversão de JSON.

## 2. Rodando em outro computador

O Supabase e o Gemini rodam na nuvem. Portanto, no segundo computador não é
necessário instalar Supabase, publicar a função novamente nem cadastrar a chave
secreta da IA. É necessário apenas:

- Flutter instalado;
- Google Chrome;
- Git;
- conexão com a internet para usar a IA real.

Depois de clonar o repositório, abra a pasta `study_ai_flutter` no VS Code e
execute:

```bash
flutter doctor
flutter pub get
```

No Windows, inicie com dois cliques em `run_study_ai.bat` ou pelo terminal:

```powershell
.\run_study_ai.bat
```

No Linux ou macOS:

```bash
chmod +x run_study_ai.sh
./run_study_ai.sh
```

Esses arquivos já fornecem ao Flutter o endereço da função e a chave pública do
Supabase. A chave secreta do Gemini continua protegida no servidor.

## 3. Abrindo uma cópia baixada no VS Code

1. Extraia a pasta `study_ai`.
2. Abra o VS Code.
3. Vá em **File > Open Folder**.
4. Escolha a pasta `study_ai`.
5. Abra o terminal integrado.
6. Execute:

```bash
flutter doctor
flutter pub get
flutter run -d chrome
```

Ao trocar a versão antiga por esta, faça uma reconstrução completa:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

Se o Chrome não aparecer como dispositivo:

```bash
flutter config --enable-web
flutter devices
```

Depois rode novamente:

```bash
flutter run -d chrome
```

## 4. Melhor forma de apresentar como aplicativo mobile

Quando abrir no Chrome:

1. pressione `F12`;
2. clique no ícone **Toggle device toolbar**;
3. escolha um celular como iPhone/Pixel;
4. mantenha o app em modo retrato.

A própria interface limita a largura no desktop, então continuará com aparência mobile mesmo sem o DevTools.

## 5. Teste rápido da versão entregue

No aplicativo:

1. Abra **Estudar**.
2. Clique em **Carregar exemplo sobre Provider**.
3. Selecione **Resumir** e gere.
4. Troque para **Explicar** e teste os três níveis.
5. Selecione **Quiz** e responda.
6. Selecione **Flashcards** e toque nos cartões.
7. Veja **Desempenho**.
8. Em **Ajustes**, teste o tema escuro e os dados de demonstração.

## 6. IA real com Gemini

O Flutter NÃO guarda a chave secreta.

Arquitetura:

```text
Flutter
  ↓ HTTP/JSON
Supabase Edge Function
  ↓
Provedor de IA
  ↓
JSON estruturado
  ↓
Flutter
```

O backend de exemplo está em:

```text
supabase/functions/study-ai/index.ts
```

O backend já está publicado e o secret `GEMINI_API_KEY` já foi cadastrado no
Supabase. Execute `run_study_ai.bat`, `run_study_ai.sh` ou use:

```bash
flutter run -d chrome --dart-define=AI_ENDPOINT=https://abyivhafxbutmvgudktw.supabase.co/functions/v1/study-ai --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_SOOZgD8Lx2yPMhcyWazyBA_5QpODy4W
```

No segundo computador não é necessário repetir essa configuração.

### Secrets usados pelo backend

```text
GEMINI_API_KEY
GEMINI_MODEL   (opcional; padrão gemini-3.5-flash-lite)
```

Nunca coloque `GEMINI_API_KEY` dentro de `lib/`.

## 7. Estrutura principal

```text
lib/
├── main.dart
├── app.dart
├── models/
├── providers/
├── screens/
├── services/
├── theme/
└── widgets/
```

### Fluxo técnico

```text
Tela
 ↓
StudyProvider
 ↓
AIService
 ↓
HTTP / modo demo
 ↓
JSON
 ↓
Models Dart
 ↓
notifyListeners()
 ↓
Tela atualizada
```

## 8. Arquivos importantes para explicar ao professor

- `lib/main.dart`: inicialização e MultiProvider.
- `lib/providers/study_provider.dart`: estado principal do app.
- `lib/services/ai_service.dart`: HTTP, JSON, fallback.
- `lib/models/quiz_question.dart`: POO e conversão JSON.
- `lib/screens/quiz_screen.dart`: estado local, navegação e correção.
- `lib/services/storage_service.dart`: persistência com SharedPreferences.
- `lib/widgets/mini_line_chart.dart`: gráfico feito com CustomPainter.

## 9. Comandos úteis

```bash
flutter pub get
flutter run -d chrome
flutter analyze
flutter test
```

Para limpar e reconstruir:

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## 10. Observação

Este pacote foi montado sem executar o compilador Flutter no ambiente em que foi gerado. Por isso, no seu computador, a primeira etapa deve ser executar `flutter pub get` e `flutter analyze`. Se o seu Flutter estiver muito antigo, atualize para uma versão estável recente antes da apresentação.
