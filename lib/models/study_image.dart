import 'dart:convert';
import 'dart:typed_data';

class StudyImage {
  const StudyImage({required this.bytes, required this.name});
  static const maxBytes = 4 * 1024 * 1024;
  final Uint8List bytes;
  final String name;
  Map<String, String> toJson() =>
      {'mimeType': 'image/png', 'data': base64Encode(bytes)};
}
