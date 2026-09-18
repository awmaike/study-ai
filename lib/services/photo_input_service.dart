import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:pasteboard/pasteboard.dart';

import '../models/study_image.dart';
import '../screens/capture_screen.dart';

class PhotoInputService {
  Future<StudyImage?> gallery() async {
    final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 90,
        requestFullMetadata: false);
    return file == null ? null : prepare(file);
  }

  Future<StudyImage?> camera(BuildContext context) async {
    final file = await Navigator.of(context)
        .push<XFile>(MaterialPageRoute(builder: (_) => const CaptureScreen()));
    return file == null ? null : prepare(file);
  }

  Future<StudyImage?> clipboardImage() async {
    final bytes = await Pasteboard.image;
    if (bytes == null || bytes.isEmpty) return null;
    return prepare(XFile.fromData(bytes, name: 'imagem-colada.png'));
  }

  Future<StudyImage> prepare(XFile file) async {
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('Escolha uma foto com até 20 MB.');
    }
    final bytes = await file.readAsBytes();
    if (kIsWeb) return prepareWebImage(bytes, file.name);
    final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
    ui.ImageDescriptor? descriptor;
    try {
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      for (final edge in [1600, 960]) {
        final scale = min(1.0, edge / max(descriptor.width, descriptor.height));
        final codec = await descriptor.instantiateCodec(
            targetWidth: max(1, (descriptor.width * scale).round()),
            targetHeight: max(1, (descriptor.height * scale).round()));
        try {
          final frame = await codec.getNextFrame();
          try {
            final png =
                await frame.image.toByteData(format: ui.ImageByteFormat.png);
            if (png != null && png.lengthInBytes <= StudyImage.maxBytes) {
              return StudyImage(
                  bytes: png.buffer
                      .asUint8List(png.offsetInBytes, png.lengthInBytes),
                  name: file.name);
            }
          } finally {
            frame.image.dispose();
          }
        } finally {
          codec.dispose();
        }
      }
      throw const FormatException(
          'A foto ficou muito grande. Recorte a área do texto e tente novamente.');
    } finally {
      descriptor?.dispose();
      buffer.dispose();
    }
  }

}

StudyImage prepareWebImage(Uint8List bytes, String name) {
  img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    throw const FormatException('A imagem não pôde ser lida. Escolha JPG, PNG ou WebP.');
  }
  if (decoded == null) {
    throw const FormatException('A imagem não pôde ser lida. Escolha JPG, PNG ou WebP.');
  }
  final oriented = img.bakeOrientation(decoded);
  for (final edge in [1600, 960]) {
    final scale = min(1.0, edge / max(oriented.width, oriented.height));
    final resized = scale == 1
        ? oriented
        : img.copyResize(oriented,
            width: max(1, (oriented.width * scale).round()),
            height: max(1, (oriented.height * scale).round()),
            interpolation: img.Interpolation.linear);
    final png = img.encodePng(resized);
    if (png.length <= StudyImage.maxBytes) {
      return StudyImage(bytes: png, name: name);
    }
  }
  throw const FormatException(
      'A foto ficou muito grande. Recorte a área do texto e tente novamente.');
}
