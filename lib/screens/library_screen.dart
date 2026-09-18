import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/study_provider.dart';
import '../widgets/study_glyph.dart';
import '../models/study_action.dart';
import 'study_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;
    final items = study.library
        .where((item) => '${item.title} ${item.text}'
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Minha biblioteca')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Seu conhecimento, sempre à mão.',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                  '${study.library.length} ${study.library.length == 1 ? "material salvo" : "materiais salvos"} neste dispositivo. Leia mesmo sem conexão.',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 22),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                    hintText: 'Buscar nos materiais',
                    prefixIcon: Icon(Icons.search_rounded)),
              ),
              const SizedBox(height: 20),
              if (items.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
                  child: Column(children: [
                    Icon(Icons.bookmarks_outlined,
                        size: 58, color: scheme.primary),
                    const SizedBox(height: 18),
                    Text(
                        study.library.isEmpty
                            ? 'Sua biblioteca começa com uma descoberta.'
                            : 'Nenhum material encontrado.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text(
                        study.library.isEmpty
                            ? 'Gere um resumo ou uma explicação e toque em Salvar na biblioteca.'
                            : 'Tente buscar por outro tema ou palavra.',
                        textAlign: TextAlign.center),
                  ]),
                ),
              for (final item in items)
                Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    key: ValueKey(item.id),
                    leading: StudyGlyph(StudyGlyphKind.summary,
                        color: scheme.primary),
                    title: Text(item.title,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        '${item.kind} • ${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}'),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      SelectableText(item.text,
                          style: const TextStyle(height: 1.6)),
                      const SizedBox(height: 16),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final action in [
                          StudyAction.quiz,
                          StudyAction.flashcards
                        ])
                          FilledButton.tonalIcon(
                            icon: StudyGlyph(
                                action == StudyAction.quiz
                                    ? StudyGlyphKind.quiz
                                    : StudyGlyphKind.cards,
                                size: 20),
                            label: Text(action == StudyAction.quiz
                                ? 'Criar quiz deste material'
                                : 'Criar flashcards'),
                            onPressed: study.isLoading
                                ? null
                                : () {
                                    study.selectAction(action);
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (_) => Scaffold(
                                                  appBar: AppBar(
                                                      title: Text(item.title,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis)),
                                                  body: Center(
                                                      child: ConstrainedBox(
                                                          constraints:
                                                              const BoxConstraints(
                                                                  maxWidth:
                                                                      680),
                                                          child: StudyScreen(
                                                              initialContent:
                                                                  item.text))),
                                                )));
                                  },
                          ),
                      ]),
                      const SizedBox(height: 10),
                      Wrap(spacing: 8, children: [
                        TextButton.icon(
                          icon: const Icon(Icons.copy_rounded),
                          label: const Text('Copiar'),
                          onPressed: () async {
                            await Clipboard.setData(
                                ClipboardData(text: item.text));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Material copiado.')));
                            }
                          },
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Remover'),
                          onPressed: study.savingLibrary
                              ? null
                              : () async {
                                  try {
                                    await study.removeSavedStudy(item.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Material removido da biblioteca.')));
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Não foi possível remover. Tente novamente.')));
                                    }
                                  }
                                },
                        ),
                      ]),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
