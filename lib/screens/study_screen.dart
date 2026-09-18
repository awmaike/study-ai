import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/study_samples.dart';
import '../models/study_action.dart';
import '../models/study_image.dart';
import '../services/photo_input_service.dart';
import '../providers/study_provider.dart';
import '../widgets/action_tile.dart';
import '../widgets/study_glyph.dart';
import 'flashcards_screen.dart';
import 'quiz_screen.dart';
import 'library_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key, this.initialContent = '', this.photoService});
  final String initialContent;
  final PhotoInputService? photoService;

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();
  final FocusNode _contentFocus = FocusNode();
  String _explanationMode = 'simple';
  final Random _random = Random();
  int? _lastSampleIndex;
  int _questionCount = 10;
  String _difficulty = 'medium';
  StudyImage? _image;
  bool _pickingPhoto = false;
  late final PhotoInputService _photos =
      widget.photoService ?? PhotoInputService();

  Future<void> _pickPhoto({required bool camera}) async {
    if (_pickingPhoto || context.read<StudyProvider>().isLoading) return;
    setState(() => _pickingPhoto = true);
    try {
      final photo =
          camera ? await _photos.camera(context) : await _photos.gallery();
      if (mounted && photo != null)
        setState(() {
          _image = photo;
        });
    } catch (error) {
      debugPrint('Falha ao preparar foto: $error');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error is FormatException
                ? error.message
                : 'Não foi possível abrir a foto. Tente uma imagem JPG, PNG ou WebP.')));
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  Future<void> _pasteContent() async {
    if (_pickingPhoto || context.read<StudyProvider>().isLoading) return;
    setState(() => _pickingPhoto = true);
    try {
      final image = await _photos.clipboardImage();
      if (!mounted) return;
      if (image != null) {
        setState(() {
          _image = image;
        });
        return;
      }
      final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
      if (!mounted) return;
      if (text == null || text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Copie um texto ou uma imagem antes de colar.')));
        return;
      }
      final selection = _controller.selection;
      final start =
          selection.isValid ? selection.start : _controller.text.length;
      final end = selection.isValid ? selection.end : start;
      _controller.value = TextEditingValue(
        text: _controller.text.replaceRange(start, end, text),
        selection: TextSelection.collapsed(offset: start + text.length),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Não foi possível colar. Confira a permissão da área de transferência.')));
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialContent;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  StudyGlyphKind _glyphFor(StudyAction action) {
    switch (action) {
      case StudyAction.summary:
        return StudyGlyphKind.summary;
      case StudyAction.explanation:
        return StudyGlyphKind.explanation;
      case StudyAction.quiz:
        return StudyGlyphKind.quiz;
      case StudyAction.flashcards:
        return StudyGlyphKind.cards;
    }
  }

  String _subtitleFor(StudyAction action) {
    switch (action) {
      case StudyAction.summary:
        return 'Pontos principais';
      case StudyAction.explanation:
        return 'Entenda melhor';
      case StudyAction.quiz:
        return 'Teste seu conhecimento';
      case StudyAction.flashcards:
        return 'Revisão rápida';
    }
  }

  Future<void> _generate() async {
    if (_controller.text.trim().isEmpty && _image == null) {
      _contentFocus.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Digite um tema, cole um texto ou adicione uma foto.'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    final provider = context.read<StudyProvider>();
    final action = provider.selectedAction;

    final ok = await provider.runAction(
      content: _controller.text,
      explanationMode: _explanationMode,
      questionCount: _questionCount,
      difficulty: _difficulty,
      image: _image,
    );

    if (!mounted || !ok) return;
    final extractedText = provider.lastExtractedText.trim();
    if (_image != null && extractedText.isNotEmpty) {
      setState(() {
        _controller.text = [
          _controller.text.trim(),
          extractedText,
        ].where((text) => text.isNotEmpty).join('\n\n');
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
        _image = null;
      });
    }

    if (action == StudyAction.quiz) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const QuizScreen(),
        ),
      );
    } else if (action == StudyAction.flashcards) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const FlashcardsScreen(),
        ),
      );
    } else {
      await WidgetsBinding.instance.endOfFrame;
      if (mounted && _resultKey.currentContext != null) {
        await Scrollable.ensureVisible(
          _resultKey.currentContext!,
          alignment: 0.08,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      key: const PageStorageKey('study-scroll'),
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4166F5), Color(0xFF8052DB)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                  child: StudyGlyph(StudyGlyphKind.book,
                      color: Colors.white, size: 28)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Espaço de Estudos',
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    'Transforme seu conteúdo em aprendizado',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text('1. Adicione seu conteúdo',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Text(
              'texto ou foto',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          key: const Key('study-content-field'),
          controller: _controller,
          enabled: !study.isLoading && !_pickingPhoto,
          focusNode: _contentFocus,
          minLines: 4,
          maxLines: 12,
          textAlignVertical: TextAlignVertical.top,
          decoration: const InputDecoration(
            hintText:
                'Digite um tema, como Valorant ou fotossíntese, ou cole o texto que queira estudar...',
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            key: const Key('paste-button'),
            onPressed: study.isLoading || _pickingPhoto ? null : _pasteContent,
            icon: const Icon(Icons.content_paste_rounded),
            label: const Text('Colar texto ou imagem'),
          ),
        ),
        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
            key: const Key('gallery-button'),
            onPressed: study.isLoading || _pickingPhoto
                ? null
                : () => _pickPhoto(camera: false),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galeria'),
          )),
          const SizedBox(width: 8),
          Expanded(
              child: FilledButton.tonalIcon(
            key: const Key('camera-button'),
            onPressed: study.isLoading || _pickingPhoto
                ? null
                : () => _pickPhoto(camera: true),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Tirar foto'),
          )),
        ]),
        if (_pickingPhoto)
          const Padding(
              padding: EdgeInsets.only(top: 10),
              child: LinearProgressIndicator()),
        if (_image != null) ...[
          const SizedBox(height: 12),
          Card(
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: ClipRect(
                    child: Image.memory(_image!.bytes,
                        key: const Key('photo-preview'),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                            child: Text('Não foi possível mostrar a prévia.'))),
                  ),
                ),
                ListTile(
                    title: const Text('Foto pronta para estudar'),
                    subtitle: Text(_image!.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                        tooltip: 'Remover foto',
                        onPressed: study.isLoading
                            ? null
                            : () => setState(() {
                                  _image = null;
                                }),
                        icon: const Icon(Icons.close_rounded))),
                const Padding(
                    padding: EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Text(
                        'Não precisa digitar: ao gerar, a IA lerá o texto da foto. Você pode acrescentar uma observação no campo acima.',
                        style: TextStyle(fontSize: 12))),
              ])),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                key: const Key('load-sample-button'),
                onPressed: study.isLoading || _pickingPhoto
                    ? null
                    : () {
                        final previousIndex = _lastSampleIndex;
                        var index = _random.nextInt(
                          studySamples.length - (previousIndex == null ? 0 : 1),
                        );
                        if (previousIndex != null && index >= previousIndex) {
                          index++;
                        }
                        _lastSampleIndex = index;
                        _controller.text = studySamples[index];
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Exemplo carregado. Agora escolha uma ação.')),
                        );
                      },
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('Usar texto aleatório'),
              ),
            ),
            IconButton(
              tooltip: 'Limpar texto',
              onPressed: study.isLoading || _pickingPhoto
                  ? null
                  : () => setState(_controller.clear),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '2. Escolha como estudar',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: StudyAction.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.96,
          ),
          itemBuilder: (context, index) {
            final action = StudyAction.values[index];
            return ActionTile(
              glyph: _glyphFor(action),
              title: action.label,
              subtitle: _subtitleFor(action),
              selected: study.selectedAction == action,
              onTap: () => study.selectAction(action),
            );
          },
        ),
        if (study.selectedAction == StudyAction.quiz) ...[
          const SizedBox(height: 20),
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Seu quiz, no seu ritmo',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      const Text('Quantidade de perguntas'),
                      Wrap(spacing: 8, children: [
                        for (final count in [5, 10, 15])
                          ChoiceChip(
                              label: Text('$count'),
                              selected: _questionCount == count,
                              onSelected: study.isLoading
                                  ? null
                                  : (_) =>
                                      setState(() => _questionCount = count)),
                      ]),
                      const SizedBox(height: 12),
                      const Text('Dificuldade'),
                      Wrap(spacing: 8, children: [
                        for (final entry in {
                          'easy': 'Básico',
                          'medium': 'Intermediário',
                          'hard': 'Avançado'
                        }.entries)
                          ChoiceChip(
                              label: Text(entry.value),
                              selected: _difficulty == entry.key,
                              onSelected: study.isLoading
                                  ? null
                                  : (_) =>
                                      setState(() => _difficulty = entry.key)),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                          'Textos curtos podem render menos perguntas para evitar repetições.',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ))),
        ],
        if (study.selectedAction == StudyAction.explanation) ...[
          const SizedBox(height: 18),
          Text(
            'Nível da explicação',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('🧒 Simples'),
                selected: _explanationMode == 'simple',
                onSelected: (_) => setState(() => _explanationMode = 'simple'),
              ),
              ChoiceChip(
                label: const Text('🎓 Acadêmica'),
                selected: _explanationMode == 'academic',
                onSelected: (_) =>
                    setState(() => _explanationMode = 'academic'),
              ),
              ChoiceChip(
                label: const Text('⚡ Resumida'),
                selected: _explanationMode == 'short',
                onSelected: (_) => setState(() => _explanationMode = 'short'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 22),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            key: const Key('generate-button'),
            onPressed: study.isLoading || _pickingPhoto ? null : _generate,
            icon: study.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              study.isLoading
                  ? (_image == null
                      ? 'Analisando conteúdo...'
                      : 'Lendo foto e preparando...')
                  : '${study.selectedAction.label} com IA',
            ),
          ),
        ),
        if (study.errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.errorContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    study.errorMessage!,
                    style: TextStyle(color: scheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (study.lastTextResult.isNotEmpty &&
            (study.selectedAction == StudyAction.summary ||
                study.selectedAction == StudyAction.explanation)) ...[
          const SizedBox(height: 24),
          Row(
            key: _resultKey,
            children: [
              Expanded(
                child: Text(
                  'Resultado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (study.usedDemoLastRequest)
                Chip(
                  avatar: const Icon(Icons.offline_bolt_rounded, size: 18),
                  label: const Text('Demo'),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: scheme.outlineVariant.withOpacity(0.6),
              ),
            ),
            child: SelectableText(
              study.lastTextResult,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.55,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            FilledButton.tonalIcon(
              key: const Key('save-study-button'),
              onPressed: study.currentResultSaved || study.savingLibrary
                  ? null
                  : () async {
                      try {
                        await study.saveCurrentResult();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Material salvo na sua biblioteca.')));
                        }
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  'Não foi possível salvar. Verifique o espaço ou remova um material da biblioteca.')));
                        }
                      }
                    },
              icon: Icon(study.currentResultSaved
                  ? Icons.bookmark_added_rounded
                  : Icons.bookmark_add_outlined),
              label: Text(study.currentResultSaved
                  ? 'Salvo na biblioteca'
                  : 'Salvar na biblioteca'),
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar'),
              onPressed: () async {
                await Clipboard.setData(
                    ClipboardData(text: study.lastTextResult));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Texto copiado.')));
                }
              },
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LibraryScreen())),
              child: const Text('Abrir biblioteca'),
            ),
          ]),
        ],
      ],
    );
  }
}
