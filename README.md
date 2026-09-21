# StudyAI — tutorial de execução para o professor

## Início rápido — computador da universidade

Como Flutter e Chrome já estão instalados, abra o **PowerShell na pasta do projeto** (a que contém `pubspec.yaml`) e execute:

```powershell
flutter pub get
.\run_study_ai.bat
```
Só rode estes 3 Comandos no TERMINAL do VSCODE

Aguarde o Chrome abrir, crie uma conta ou faça login e acesse **Estudar** para usar o aplicativo. Mantenha o terminal aberto e o computador conectado à internet.

**Se ainda não baixou o projeto**, execute:

```powershell
git clone https://github.com/awmaike/study-ai-flutter.git
cd study-ai-flutter
flutter pub get
.\run_study_ai.bat
```

**Use o inicializador `run_study_ai.bat`**, pois ele fornece as configurações de login e IA. Para encerrar, pressione **q** no terminal.

As instruções de instalação abaixo são apenas para o caso de algum requisito estar ausente. Com o aplicativo aberto, siga a seção **5. Testar as funcionalidades**.

O StudyAI é um aplicativo de estudos feito em Flutter e Dart. Ele gera resumos, explicações, quizzes e flashcards a partir de textos, temas ou fotos, além de oferecer biblioteca, tarefas e acompanhamento do desempenho.

Este tutorial explica como executar e avaliar o projeto em um computador **Windows da universidade**, usando o **Google Chrome**.

## 1. Preparar o computador

Você precisará de:

- **Google Chrome** instalado.
- **Git para Windows**, utilizado pelas ferramentas do Flutter e, opcionalmente, para baixar o projeto.
- **Flutter SDK 3.44.0 ou superior**, com Dart compatível. O `pubspec.lock` atual exige Dart `>=3.12.0 <4.0.0`; o Dart já acompanha o Flutter.
- **Internet** para baixar as dependências, entrar na conta e gerar conteúdo com IA.
- Uma pasta na qual seu usuário tenha permissão de escrita.

Para esta execução no navegador, não é necessário preparar emulador Android nem instalar Android Studio ou Visual Studio. O VS Code é opcional.

### Se o Flutter ainda não estiver instalado

1. Siga a [instalação oficial do Flutter](https://docs.flutter.dev/install/manual) e extraia o SDK em uma pasta do seu usuário, por exemplo, `C:\Users\SEU_USUARIO\dev\flutter`.
2. Adicione a pasta `bin` do SDK ao `Path` do usuário, seguindo o [guia oficial de configuração do PATH](https://docs.flutter.dev/install/add-to-path).
3. Feche e abra novamente o PowerShell.
4. Confira a instalação:

```powershell
flutter --version
flutter doctor
flutter devices
```

O Chrome deve aparecer entre os dispositivos. Avisos do `flutter doctor` sobre ferramentas de Android ou Windows desktop não impedem, por si só, a execução web. Veja também a [configuração oficial para web](https://docs.flutter.dev/platform-integration/web/setup).

Se a universidade bloquear instalações ou downloads, solicite ao suporte do laboratório a preparação desses requisitos.

## 2. Baixar o projeto

Escolha uma das opções abaixo.

### Opção A — baixar o ZIP

1. Acesse o [repositório do StudyAI](https://github.com/awmaike/study-ai-flutter).
2. Clique em **Code → Download ZIP**.
3. Extraia o arquivo em uma pasta do computador.
4. Abra a pasta extraída que contém `pubspec.yaml` e `run_study_ai.bat`.
5. No Explorador de Arquivos, digite `powershell` na barra de endereço e pressione **Enter** para abrir o terminal nessa pasta.

### Opção B — usar Git

Abra o PowerShell na pasta em que deseja guardar o projeto e execute:

```powershell
git clone https://github.com/awmaike/study-ai-flutter.git
cd study-ai-flutter
```

Se recebeu o projeto por pendrive ou outra forma, copie a pasta completa para o computador e abra o PowerShell na pasta que contém `pubspec.yaml`.

## 3. Instalar as dependências e iniciar

No PowerShell, dentro da pasta do projeto, execute:

```powershell
flutter pub get
.\run_study_ai.bat
```

A primeira execução pode levar alguns minutos. Aguarde o Chrome abrir e mostrar a tela de login do **StudyAI**. Mantenha o terminal aberto durante o uso.

**Use o arquivo `run_study_ai.bat` para iniciar.** Ele já fornece o endereço do serviço e a chave pública necessários ao login e à IA. Executar somente `flutter run -d chrome` deixa essas configurações ausentes e exibe uma mensagem pedindo o uso do inicializador.

O professor não precisa criar um servidor nem configurar uma chave do Gemini para usar o serviço já indicado no projeto. O funcionamento depende de esse serviço continuar disponível; a chave secreta da IA fica no servidor.

### Se aparecer “flutter não é reconhecido”

Localize a pasta onde o Flutter foi extraído. Se ela estiver em `dev\flutter` dentro da pasta do seu usuário, execute:

```powershell
$env:Path = "$env:USERPROFILE\dev\flutter\bin;" + $env:Path
flutter --version
flutter pub get
.\run_study_ai.bat
```

Se o SDK estiver em outro local, substitua o caminho pela pasta `bin` correta. Esse ajuste vale apenas para o terminal atual; para torná-lo permanente, siga o guia de PATH da etapa 1.

## 4. Entrar no aplicativo

1. Na tela inicial, clique em **Criar uma conta** se ainda não tiver cadastro.
2. Informe seu e-mail e uma senha e clique em **Criar conta**.
3. Se já tiver cadastro, informe as credenciais e clique em **Entrar**.
4. Aguarde a abertura da tela principal.

Se aparecer a mensagem de que a confirmação por e-mail está ativa, confira a caixa de entrada e o spam. Se não conseguir concluir o acesso, informe ao responsável pelo projeto a mensagem exibida para que ele verifique a configuração do cadastro.

## 5. Testar as funcionalidades

### Gerar e salvar um resumo

1. Abra **Estudar**.
2. Cole o texto abaixo no campo de conteúdo ou use **Usar texto aleatório**:

```text
Provider é um pacote utilizado no Flutter para gerenciamento de estado.
Ele permite compartilhar dados entre diferentes widgets da aplicação.
ChangeNotifier mantém o estado e notifica seus ouvintes quando ocorre uma mudança.
ChangeNotifierProvider disponibiliza esse estado aos widgets descendentes.
Consumer reconstrói a parte da interface que depende dos dados alterados.
Essa organização ajuda a separar as regras de negócio da interface.
```

3. Selecione a opção de resumo e clique no botão de geração.
4. Aguarde o resultado e use a opção de salvar na biblioteca.
5. Abra a **Biblioteca** e confira se o material aparece.

### Gerar uma explicação e flashcards

1. Volte a **Estudar** e mantenha ou cole novamente o texto.
2. Escolha a explicação e selecione um nível: **Simples**, **Acadêmica** ou **Resumida**.
3. Gere o resultado e leia a explicação.
4. Depois, selecione flashcards, gere os cartões e toque em um deles para ver a resposta.

### Responder a um quiz

1. Em **Estudar**, digite um tema, como `Gerenciamento de estado com Provider no Flutter`.
2. Selecione quiz, escolha **5 perguntas** e a dificuldade desejada.
3. Gere o quiz e aguarde a resposta da IA.
4. Responda às perguntas e confira as correções e explicações.
5. Finalize o quiz e consulte a pontuação e a revisão das respostas.
6. Abra **Progresso** para conferir o resultado registrado.

### Testar foto, rotina e ajustes

- **Foto:** em Estudar, use **Galeria** para selecionar uma imagem com texto legível ou **Tirar foto** para usar a câmera. Gere um resumo do conteúdo. Se usar a câmera, permita o acesso quando o navegador solicitar.
- **Rotina:** crie uma tarefa, marque-a como concluída e experimente o cronômetro de foco.
- **Ajustes:** alterne o tema claro/escuro e altere a meta diária de questões.
- **Histórico de exemplo:** em Ajustes, use **Carregar histórico de exemplo** se quiser visualizar os gráficos com dados de demonstração.

Para conferir a interface em formato de celular, pressione **F12** no Chrome, ative a barra de dispositivos com **Ctrl + Shift + M** e escolha um celular em modo retrato. Isso é opcional.

## 6. Entender onde os dados ficam salvos

O login utiliza uma conta on-line, mas a biblioteca, as tarefas e os resultados são armazenados localmente no navegador, separados por conta. Entrar em outro computador não sincroniza esses materiais.

Limpar os dados do navegador pode apagar os registros locais. Em execução de desenvolvimento, mudanças de porta ou de perfil do Chrome também podem fazer os dados anteriores deixarem de aparecer. Não conte com a máquina do laboratório como cópia permanente dos materiais; copie os textos que desejar guardar.

Ao terminar em um computador compartilhado, acesse **Ajustes → Sair da conta**. Depois, volte ao terminal e pressione **q** para encerrar a execução do Flutter; se necessário, use **Ctrl + C**.

Para executar novamente, abra o PowerShell na pasta do projeto e execute `.\run_study_ai.bat`. Execute `flutter pub get` novamente se atualizar o projeto ou suas dependências.

## 7. Resolver problemas comuns

| Problema | Como resolver |
| --- | --- |
| `flutter` não é reconhecido | Configure o PATH conforme a etapa 3 e confira com `flutter --version`. |
| Erro de versão do Dart ou Flutter ao baixar dependências | Confira `flutter --version`. Use um SDK que atenda aos requisitos da etapa 1. |
| `No pubspec.yaml file found` | Abra o terminal na pasta que contém `pubspec.yaml`. |
| Chrome não aparece ou não abre | Confira se está instalado e execute `flutter devices`. Se a opção web estiver desativada, execute `flutter config --enable-web` e tente novamente. |
| A tela pede para iniciar pelo `run_study_ai.bat` | Encerre a execução atual e inicie com `.\run_study_ai.bat`. |
| Não consegue entrar ou criar conta | Confira as credenciais, a internet e a mensagem da tela. Se persistir, encaminhe a mensagem ao responsável pelo projeto. |
| IA demora ou não gera quiz, tema ou conteúdo de foto | Confira a conexão e tente novamente. Essas funções dependem do serviço de IA; bloqueios da rede, indisponibilidade ou limites do serviço podem impedir a geração. |
| O resultado mostra **Demo** | Foi usada uma resposta local de demonstração. Isso pode ocorrer em resumos, explicações e flashcards feitos com texto quando a IA falha; não confirma que a IA está funcionando. |
| Câmera indisponível | Confira a permissão no Chrome ou teste uma imagem pela opção **Galeria**. |
| Downloads ou acesso bloqueados pela rede da universidade | Peça ao suporte que confira o acesso aos serviços de download do Flutter e das dependências e ao backend do projeto. |

**Não há um fluxo completo de primeiro acesso sem internet:** o login precisa do serviço on-line. As respostas locais de demonstração são um recurso limitado para algumas ações com texto depois de acessar o aplicativo.

## 8. Referência para avaliação do código

| Arquivo ou pasta | Responsabilidade |
| --- | --- |
| `lib/main.dart` e `lib/app.dart` | Inicialização e configuração do aplicativo. |
| `lib/screens/` | Telas e interação com o usuário. |
| `lib/providers/study_provider.dart` | Estado e ações de estudo. |
| `lib/services/ai_service.dart` | Comunicação HTTP com a IA e tratamento das respostas. |
| `lib/services/storage_service.dart` | Persistência local dos dados. |
| `supabase/functions/study-ai/index.ts` | Serviço que faz a integração com o Gemini. |
| `test/` | Testes automatizados do projeto. |

Para uma verificação técnica opcional, execute na pasta do projeto:

```powershell
flutter analyze
flutter test
```

Esses comandos fazem a análise do código e executam os testes; o teste manual de login e geração de quiz continua necessário para verificar a disponibilidade do serviço on-line na rede da universidade.
