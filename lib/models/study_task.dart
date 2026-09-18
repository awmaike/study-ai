class StudyTask {
  const StudyTask(
      {required this.id,
      required this.title,
      required this.subject,
      required this.dueDate,
      this.completed = false});
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final bool completed;

  StudyTask toggle() => StudyTask(
      id: id,
      title: title,
      subject: subject,
      dueDate: dueDate,
      completed: !completed);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'dueDate': dueDate.toIso8601String(),
        'completed': completed
      };

  factory StudyTask.fromJson(Map<String, dynamic> json) => StudyTask(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      completed: json['completed'] == true);
}
