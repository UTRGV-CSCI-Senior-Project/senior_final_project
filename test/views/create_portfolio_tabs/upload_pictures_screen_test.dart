import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/create_portfolio_tabs/upload_pictures_screen.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/onboarding_screen_test.mocks.dart';

void main() {
  late MockImagePicker mockImagePicker;
  late MockXFile mockXFile;

  setUp(() {
    mockImagePicker = MockImagePicker();
    mockXFile = MockXFile();
  });

  group('Upload Pictures Screen Tests', () {
    testWidgets('shows image picker button', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            imagePickerProvider.overrideWithValue(mockImagePicker),
          ],
          child: MaterialApp(
              home: Scaffold(
            body: UploadPictures(
              onImagesAdded: (_) {},
              selectedImages: const [],
            ),
          )),
        ),
      );

      expect(find.byKey(const Key('image-picker-button')), findsOneWidget);
    });

    testWidgets('can select images, and they are shown on the sccreen',
        (WidgetTester tester) async {
      List<File> selectedImages = [];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            imagePickerProvider.overrideWithValue(mockImagePicker),
          ],
          child: MaterialApp(
              home: Scaffold(
            body: UploadPictures(
              onImagesAdded: (files) {
                selectedImages = files;
              },
              selectedImages: [],
            ),
          )),
        ),
      );

      when(mockImagePicker.pickMultiImage()).thenAnswer(
          (_) async => [mockXFile, mockXFile, mockXFile, mockXFile, mockXFile]);
      when(mockXFile.path).thenReturn('path/to/image');

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('image-picker-button')));
      expect(selectedImages.length, 5);
    });

    testWidgets('can remove selected images', (WidgetTester tester) async {
      final testImage = File('test/assets/test_image.jpg');
      List<File> currentImages = [testImage];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            imagePickerProvider.overrideWithValue(mockImagePicker),
          ],
          child: MaterialApp(
            home: UploadPictures(
              onImagesAdded: (images) => currentImages = images,
              selectedImages: [testImage],
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('remove-image-1')));
      await tester.pumpAndSettle();
      expect(currentImages.isEmpty, isTrue);
    });
  });
}
