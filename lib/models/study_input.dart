/// A short title is a topic; sentences and pasted material are source text.
bool isStudyTopic(String content) {
  final trimmed = content.trim();
  return trimmed.isNotEmpty &&
      trimmed.split(RegExp(r'\s+')).length <= 12 &&
      !RegExp(r'[.!?\n\r]').hasMatch(trimmed);
}
