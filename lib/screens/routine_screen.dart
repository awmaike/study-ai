import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/study_provider.dart';
import '../models/study_task.dart';
import '../widgets/study_glyph.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});
  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  String _filter = 'open';

  Future<void> _change(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Não foi possível salvar a alteração. Tente novamente.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final study = context.watch<StudyProvider>();
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tasks = study.tasks
        .where((task) => _filter == 'done'
            ? task.completed
            : !task.completed &&
                (_filter != 'today' || !task.dueDate.isAfter(today)))
        .toList();
    final pending = study.tasks.where((task) => !task.completed).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
      children: [
        Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('Minha rotina',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 6),
                Text('Planeje. Concentre. Avance.',
                    style: TextStyle(color: scheme.onSurfaceVariant)),
              ])),
          IconButton.filledTonal(
              tooltip: 'Nova tarefa',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  builder: (_) => const _TaskEditor())),
        ]),
        const SizedBox(height: 24),
        AnimatedBuilder(
            animation: study.focusTimer,
            builder: (context, _) {
              final focus = study.focusTimer;
              final seconds = focus.remainingSeconds;
              final clock =
                  '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
              return Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                        colors: [Color(0xFF192E68), Color(0xFF4D42B8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight)),
                child: Column(children: [
                  const Row(children: [
                    StudyGlyph(StudyGlyphKind.progress, color: Colors.white),
                    SizedBox(width: 10),
                    Text('MODO FOCO',
                        style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w800))
                  ]),
                  const SizedBox(height: 18),
                  SizedBox.square(
                      dimension: 164,
                      child: Stack(alignment: Alignment.center, children: [
                        SizedBox.expand(
                            child: CircularProgressIndicator(
                                value: focus.progress,
                                strokeWidth: 6,
                                backgroundColor:
                                    Colors.white.withValues(alpha: .15),
                                color: const Color(0xFFB8CDFF))),
                        Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(clock,
                              key: const Key('focus-clock'),
                              style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFeatures: [
                                    FontFeature.tabularFigures()
                                  ])),
                          Text(
                              focus.completed
                                  ? 'Sessão concluída'
                                  : focus.running
                                      ? 'Um passo de cada vez'
                                      : 'Seu tempo de aprender',
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFFD7DEFF))),
                        ]),
                      ])),
                  const SizedBox(height: 18),
                  Wrap(spacing: 8, children: [
                    for (final minutes in [15, 25, 45])
                      ChoiceChip(
                          label: Text('$minutes min'),
                          selected: focus.minutes == minutes,
                          onSelected: focus.running
                              ? null
                              : (_) => focus.reset(minutes: minutes)),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                        child: FilledButton.icon(
                      key: const Key('focus-toggle'),
                      onPressed: focus.running ? focus.pause : focus.start,
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF254AC2)),
                      icon: Icon(focus.running
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded),
                      label: Text(focus.running
                          ? 'Pausar'
                          : focus.completed
                              ? 'Nova sessão'
                              : focus.remainingSeconds < focus.minutes * 60
                                  ? 'Retomar'
                                  : 'Começar foco'),
                    )),
                    const SizedBox(width: 10),
                    IconButton(
                        tooltip: 'Reiniciar sessão',
                        onPressed: () => focus.reset(),
                        icon: const Icon(Icons.restart_alt_rounded,
                            color: Colors.white)),
                  ]),
                  const SizedBox(height: 12),
                  Text(
                      '${focus.minutesOn(now)} minutos de sessões concluídas hoje',
                      style: const TextStyle(
                          color: Color(0xFFD7DEFF), fontSize: 12)),
                  if (focus.completed)
                    const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                            'Bom trabalho! Faça uma pausa antes da próxima sessão.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white))),
                  if (focus.error != null)
                    Text(focus.error!,
                        style: const TextStyle(color: Colors.white)),
                ]),
              );
            }),
        const SizedBox(height: 26),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta diária de questões',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                    '${study.questionsOn(now)} / ${study.dailyGoal} questões concluídas hoje'),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (study.questionsOn(now) / study.dailyGoal).clamp(0, 1),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        Row(children: [
          Expanded(
              child: Text('Seu plano de estudos',
                  style: Theme.of(context).textTheme.titleLarge)),
          Text('$pending ${pending == 1 ? "pendente" : "pendentes"}',
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ]),
        const SizedBox(height: 12),
        Wrap(spacing: 8, children: [
          for (final entry in {
            'open': 'Pendentes',
            'today': 'Hoje e atrasadas',
            'done': 'Concluídas'
          }.entries)
            ChoiceChip(
                label: Text(entry.value),
                selected: _filter == entry.key,
                onSelected: (_) => setState(() => _filter = entry.key)),
        ]),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          Card(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(children: [
                    StudyGlyph(StudyGlyphKind.book,
                        size: 42, color: scheme.primary),
                    const SizedBox(height: 12),
                    Text(
                        _filter == 'done'
                            ? 'Suas tarefas concluídas aparecerão aqui.'
                            : 'Abra espaço para o próximo passo.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text(
                        'Adicione uma tarefa, escolha a matéria e reserve um momento para estudar.',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.tonalIcon(
                        onPressed: () => showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            builder: (_) => const _TaskEditor()),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Adicionar tarefa')),
                  ]))),
        for (final task in tasks)
          Card(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Checkbox(
                        value: task.completed,
                        onChanged: study.savingTasks
                            ? null
                            : (_) => _change(() => study.toggleTask(task.id))),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(task.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null)),
                          const SizedBox(height: 5),
                          Text(
                              '${task.subject} • ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                              style: Theme.of(context).textTheme.bodySmall),
                          if (!task.completed && task.dueDate.isBefore(today))
                            Text('Replanejar: prazo passou',
                                style: TextStyle(
                                    color: scheme.error, fontSize: 12)),
                        ])),
                    PopupMenuButton<String>(
                      tooltip: 'Opções da tarefa',
                      enabled: !study.savingTasks,
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'edit', child: Text('Editar tarefa')),
                        PopupMenuItem(
                            value: 'delete', child: Text('Remover tarefa')),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _change(() => study.deleteTask(task.id));
                        } else {
                          showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              useSafeArea: true,
                              builder: (_) => _TaskEditor(task: task));
                        }
                      },
                    ),
                  ]))),
      ],
    );
  }
}

class _TaskEditor extends StatefulWidget {
  const _TaskEditor({this.task});
  final StudyTask? task;
  @override
  State<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<_TaskEditor> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subject = TextEditingController();
  DateTime _date = DateTime.now();
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final task = widget.task;
    if (task != null) {
      _title.text = task.title;
      _subject.text = task.subject;
      _date = task.dueDate;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.viewInsetsOf(context).bottom + 24),
        child: SingleChildScrollView(
            child: Form(
                key: _form,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Um novo passo',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 20),
                    TextFormField(
                        controller: _title,
                        maxLength: 100,
                        autofocus: true,
                        decoration: const InputDecoration(
                            labelText: 'O que você vai estudar?'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Dê um nome à tarefa.'
                                : null),
                    const SizedBox(height: 12),
                    TextFormField(
                        controller: _subject,
                        maxLength: 40,
                        decoration: const InputDecoration(
                            labelText: 'Matéria ou tema',
                            hintText: 'Ex.: Programação')),
                    TextButton.icon(
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                            'Estudar em ${_date.day}/${_date.month}/${_date.year}'),
                        onPressed: _saving
                            ? null
                            : () async {
                                final now = DateTime.now();
                                final date = await showDatePicker(
                                    context: context,
                                    initialDate: _date,
                                    firstDate: DateTime(now.year - 1),
                                    lastDate: DateTime(now.year + 5),
                                    helpText: 'Quando estudar?',
                                    cancelText: 'Cancelar',
                                    confirmText: 'Escolher');
                                if (date != null && mounted) {
                                  setState(() => _date = date);
                                }
                              }),
                    if (_error != null)
                      Text(_error!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 16),
                    SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                            onPressed: _saving
                                ? null
                                : () async {
                                    if (!_form.currentState!.validate()) return;
                                    setState(() {
                                      _saving = true;
                                      _error = null;
                                    });
                                    try {
                                      final task = widget.task;
                                      if (task == null) {
                                        await context
                                            .read<StudyProvider>()
                                            .addTask(
                                                title: _title.text,
                                                subject: _subject.text,
                                                dueDate: _date);
                                      } else {
                                        await context
                                            .read<StudyProvider>()
                                            .updateTask(StudyTask(
                                                id: task.id,
                                                title: _title.text.trim(),
                                                subject:
                                                    _subject.text.trim().isEmpty
                                                        ? 'Geral'
                                                        : _subject.text.trim(),
                                                dueDate: DateTime(_date.year,
                                                    _date.month, _date.day),
                                                completed: task.completed));
                                      }
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    } catch (_) {
                                      if (mounted) {
                                        setState(() {
                                          _saving = false;
                                          _error =
                                              'Não foi possível salvar. Tente novamente.';
                                        });
                                      }
                                    }
                                  },
                            child: Text(
                                _saving ? 'Salvando...' : 'Salvar tarefa'))),
                  ],
                ))),
      );
}
