class SavedStudy {
  const SavedStudy(
      {required this.id,
      required this.title,
      required this.kind,
      required this.text,
      required this.createdAt});

  final String id;
  final String title;
  final String kind;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'kind': kind,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedStudy.fromJson(Map<String, dynamic> json) => SavedStudy(
        id: json['id'] as String,
        title: json['title'] as String,
        kind: json['kind'] as String,
        text: json['text'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
