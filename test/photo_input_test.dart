import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:study_ai/services/photo_input_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('prepara uma imagem PNG pequena para análise', () async {
    final bytes = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAADklEQVR4nGP4DwYMEAoAU7oL9ZisIGcAAAAASUVORK5CYII=');
    final image = await PhotoInputService()
        .prepare(XFile.fromData(bytes, name: 'teste.png'));
    expect(image.bytes, isNotEmpty);
    final webImage = prepareWebImage(bytes, 'teste.png');
    expect(webImage.bytes, isNotEmpty);
    expect(webImage.name, 'teste.png');
  });

  test('prepara JPEG e reduz imagem grande no caminho web', () {
    final source = img.Image(width: 2000, height: 1200);
    img.fill(source, color: img.ColorRgb8(240, 240, 240));
    final result = prepareWebImage(img.encodeJpg(source), 'pagina.jpg');
    final decoded = img.decodePng(result.bytes)!;
    expect(decoded.width, 1600);
    expect(decoded.height, 960);
    expect(result.bytes.length, lessThanOrEqualTo(4 * 1024 * 1024));
  });

  test('rejeita bytes que não são uma imagem', () {
    expect(() => prepareWebImage(base64Decode('dGVzdGU='), 'ruim.jpg'),
        throwsFormatException);
  });
}
