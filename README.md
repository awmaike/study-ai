# StudyAI — apresentação do projeto

## Para abrir na hora da apresentação (Windows)

Abra o terminal **na pasta do projeto** e execute:

```powershell
flutter doctor
flutter pub get
.\run_study_ai.bat
```

O arquivo `run_study_ai.bat` abre o app no Chrome com a IA configurada. **Não use apenas `flutter run -d chrome` se quiser demonstrar quiz, temas ou fotos com IA.**

Se o terminal disser que `flutter` não é reconhecido, use o caminho instalado neste computador:

```powershell
& 'C:\Users\maike.weber\Documents\dev_flutter\flutter\bin\flutter.bat' doctor
& 'C:\Users\maike.weber\Documents\dev_flutter\flutter\bin\flutter.bat' pub get
$env:Path = 'C:\Users\maike.weber\Documents\dev_flutter\flutter\bin;' + $env:Path
.\run_study_ai.bat
```

Depois que o Chrome abrir, pressione **F12**, ative a barra de dispositivos e selecione um celular em modo retrato.

Aplicativo de estudos desenvolvido em **Flutter e Dart** para transformar temas, textos e fotos em materiais de revisão. A interface foi pensada para celular e também pode ser demonstrada no Chrome com a visualização mobile.

## Resumo para falar (cerca de 1 minuto)

> O StudyAI é um aplicativo de estudos desenvolvido em Flutter e Dart. Ele permite inserir um tema, colar um texto ou fotografar um conteúdo para gerar resumos, explicações, quizzes e flashcards. Também oferece uma rotina com tarefas e cronômetro de foco, uma biblioteca de materiais salvos e uma tela de desempenho. Usei Provider e ChangeNotifier para gerenciar o estado, SharedPreferences para guardar dados localmente e uma Supabase Edge Function para comunicar o aplicativo com o Gemini por HTTP e JSON. A chave secreta da IA fica no servidor. O objetivo é reunir estudo, prática e acompanhamento em um aplicativo mobile.

## Funcionalidades para mostrar

- **Estudar:** resumo, explicação em níveis simples, acadêmico e resumido, quiz com 5, 10 ou 15 questões e três dificuldades, e flashcards.
- **Entradas:** tema curto, texto colado, foto da galeria ou câmera. A IA extrai o texto da foto antes de gerar o material.
- **Quiz:** quatro alternativas, correção com explicação, pontuação, revisão de todas as respostas ou só dos erros e registro no histórico.
- **Biblioteca:** salva resumos e explicações localmente, com busca, cópia e uso do material para gerar quiz ou flashcards.
- **Rotina:** tarefas por matéria e data, meta diária configurável de 5, 10, 15 ou 20 questões e cronômetro de foco de 15, 25 ou 45 minutos.
- **Progresso:** média, acertos, histórico e gráfico de desempenho.
- **Ajustes:** tema claro/escuro, escolha da meta diária e histórico de exemplo.

## Como executar para a apresentação

É preciso ter **Flutter** e **Google Chrome** instalados. Para usar o Gemini, também é necessária conexão com a internet. No terminal, dentro da pasta do projeto:

```bash
flutter doctor
flutter pub get
```

No Windows, execute `run_study_ai.bat`. No Linux ou macOS, execute `./run_study_ai.sh` (talvez seja necessário `chmod +x run_study_ai.sh`). Esses inicializadores passam ao Flutter o endereço da função Supabase e sua chave pública. A chave secreta do Gemini permanece nos Secrets do servidor.

O comando `flutter run -d chrome` sem o inicializador abre o app sem a IA configurada. Nesse modo, resumos, explicações e flashcards baseados em texto podem usar respostas locais de demonstração; **quizzes, temas e fotos precisam da IA conectada**. Faça uma geração real para conferir que o serviço está acessível.

Para exibir como celular no Chrome, pressione **F12**, ative a barra de dispositivos e escolha um aparelho em modo retrato.

## Roteiro da demonstração (5 a 7 minutos)

1. **Início:** apresente os atalhos e indicadores de estudo.
2. **Estudar:** carregue o exemplo sobre Provider, gere um resumo, salve na biblioteca e mostre dois níveis de explicação.
3. **Quiz:** gere 5 perguntas, responda algumas, mostre a correção e revise os erros ao finalizar.
4. **Progresso:** mostre o resultado registrado, a média e o gráfico.
5. **Biblioteca e flashcards:** abra o resumo salvo, gere flashcards com ele e vire um cartão.
6. **Rotina:** crie ou conclua uma tarefa, mostre o cronômetro de foco e altere a meta diária em Ajustes para ver o progresso atualizar.
7. **Foto, se houver tempo:** selecione uma imagem legível ou tire uma foto e gere um resumo. Confira previamente a permissão da câmera.
8. **Ajustes:** alterne o tema e mostre a escolha da meta diária.

## Como explicar a implementação

```text
Tela Flutter → StudyProvider → AIService → Supabase Edge Function → Gemini
       ↑              ↓                                    ↓
  widgets atualizados  modelos Dart ← resposta em JSON estruturado
```

O `StudyProvider` concentra o estado e as ações do aplicativo. Ele chama o `AIService`, que envia requisições HTTP ao backend e converte a resposta em modelos Dart. `notifyListeners()` atualiza as telas que dependem desses dados. O `StorageService` usa SharedPreferences para manter histórico, biblioteca, tarefas, foco e preferências locais. A chave secreta do Gemini fica somente na função Supabase; o aplicativo recebe apenas a chave pública usada para chamar essa função.

Arquivos úteis para mostrar ao professor:

- `lib/main.dart` e `lib/app.dart`: inicialização e configuração dos providers.
- `lib/providers/study_provider.dart`: estado e regras das funcionalidades.
- `lib/services/ai_service.dart`: HTTP, JSON, validação e respostas de demonstração para algumas ações com texto.
- `lib/services/storage_service.dart`: persistência local.
- `lib/screens/quiz_screen.dart`: interação e correção do quiz.
- `lib/widgets/mini_line_chart.dart`: gráfico desenhado com CustomPainter.
- `supabase/functions/study-ai/index.ts`: backend que acessa o Gemini.

**Por que Provider?** Para manter estado e regras fora das telas. Ao concluir um quiz, o resultado é salvo e as telas de início e progresso recebem a atualização.

**E se a internet falhar?** Demonstre resumo, explicação e flashcards com um texto colado. Explique que quiz, estudo por tema e leitura de foto exigem IA conectada.

## Conferência antes de apresentar

- [ ] No computador da apresentação, executar `flutter doctor` e `flutter pub get`.
- [ ] Reexecutar `flutter test` e `flutter build web` após a inclusão da meta configurável. Antes dessa mudança, 25 testes passaram e a compilação web concluiu.
- [x] Conferir `flutter analyze`: sem erros de compilação; restam 36 avisos informativos sobre estilo e APIs depreciadas.
- [x] Confirmar que o backend responde a um resumo e a um quiz real de 5 questões.
- [ ] Abrir a interface com `run_study_ai.bat` e repetir o fluxo de resumo e quiz no navegador.
- [ ] Testar a visualização mobile e a legibilidade no Chrome.
- [ ] Preparar um texto curto e, se for mostrar foto, uma imagem nítida de reserva.
- [ ] Deixar um quiz concluído e um material salvo. Para preencher o gráfico rapidamente, use **Ajustes → Carregar histórico de exemplo** e identifique esses dados como demonstração.
- [ ] Conferir câmera e galeria no dispositivo escolhido, se fizerem parte da demonstração.

Neste ambiente, o Flutter SDK foi encontrado em `C:\Users\maike.weber\Documents\dev_flutter\flutter\bin\flutter.bat` e executado pelo caminho completo, pois não está no PATH do terminal. A compilação web mostrou também avisos de compatibilidade com WebAssembly na dependência `image`; a compilação web padrão concluiu normalmente.

## Fechamento sugerido

> O projeto aplica interface mobile, navegação, gerenciamento de estado, persistência local e integração com API a um problema concreto: organizar o estudo e transformar conteúdo em revisão prática.
