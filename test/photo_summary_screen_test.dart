import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:study_ai/models/study_image.dart';
import 'package:study_ai/providers/study_provider.dart';
import 'package:study_ai/screens/study_screen.dart';
import 'package:study_ai/services/ai_service.dart';
import 'package:study_ai/services/photo_input_service.dart';
import 'package:study_ai/services/storage_service.dart';

class _PhotoService extends PhotoInputService {
  @override
  Future<StudyImage?> gallery() async => StudyImage(
        bytes: base64Decode(
            'iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAIAAAD91JpzAAAADklEQVR4nGP4DwYMEAoAU7oL9ZisIGcAAAAASUVORK5CYII='),
        name: 'pagina.png',
      );
}

void main() {
  testWidgets('foto resumida vira texto editável e a prévia desaparece',
      (tester) async {
    tester.view.physicalSize = const Size(400, 830);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    var requests = 0;
    final study = StudyProvider(
      storageService: StorageService(prefs),
      aiService: AIService(
        apiEndpoint: 'https://example.test/study',
        apiKey: 'test',
        client: MockClient((request) async {
          requests++;
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['content'], isEmpty);
          expect(body['image'], isNotNull);
          return http.Response(
              jsonEncode({
                'extractedText': 'A água evapora com o calor.',
                'result': 'O calor provoca a evaporação da água.',
              }),
              200,
              headers: {'content-type': 'application/json; charset=utf-8'});
        }),
      ),
    );
    addTearDown(study.dispose);
    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: study,
      child: MaterialApp(
        home: Scaffold(body: StudyScreen(photoService: _PhotoService())),
      ),
    ));
    await tester.tap(find.byKey(const Key('gallery-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('photo-preview')), findsOneWidget);
    expect(tester.getSize(find.byKey(const Key('photo-preview'))).height, 190);
    await tester.scrollUntilVisible(
        find.byKey(const Key('generate-button')), 250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.byKey(const Key('generate-button')));
    await tester.pumpAndSettle();
    expect(requests, 1);
    expect(find.byKey(const Key('photo-preview')), findsNothing);
    expect(find.text('O calor provoca a evaporação da água.'), findsOneWidget);
    await tester.scrollUntilVisible(
        find.byKey(const Key('study-content-field')), -250,
        scrollable: find.byType(Scrollable).first);
    final field =
        tester.widget<TextField>(find.byKey(const Key('study-content-field')));
    expect(field.controller!.text, 'A água evapora com o calor.');
    expect(tester.takeException(), isNull);
  });
}
