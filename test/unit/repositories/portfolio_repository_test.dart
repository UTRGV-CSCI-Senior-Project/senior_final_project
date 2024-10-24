import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/repositories/portfolio_repository.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/user_repository_test.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockFirestoreServices mockFirestoreServices;
  late MockStorageServices mockStorageServices;

  setUp(() {
    mockFirestoreServices = MockFirestoreServices();
    mockStorageServices = MockStorageServices();

    container = ProviderContainer(overrides: [
      firestoreServicesProvider.overrideWithValue(mockFirestoreServices),
      storageServicesProvider.overrideWithValue(mockStorageServices)
    ]);
  });

  group('createPortfolio', () {
    test('should successfully create portfolio with images', () async {
      // Arrange
      final images = [File('test1.jpg'), File('test2.jpg')];
      const imageData = [
        {'filePath': 'image1/path', 'downloadUrl': 'image1.url'}
      ];
      final portfolioData = {
        'service': 'Photographer',
        'details': 'Professional photography',
        'years': 2,
        'months': 6,
        'images': imageData
      };

      when(mockStorageServices.uploadFilesForUser(images))
          .thenAnswer((_) async => imageData);
      when(mockFirestoreServices.savePortfolioDetails(portfolioData))
          .thenAnswer((_) async => {});
      when(mockFirestoreServices.updateUser({'isProfessional': true}))
          .thenAnswer((_) async => {});

      // Act
      final repository = container.read(portfolioRepositoryProvider);
      await repository.createPortfolio(
          'Photographer', 'Professional photography', 6, 2, images);

      // Assert
      verify(mockStorageServices.uploadFilesForUser(images)).called(1);
      verify(mockFirestoreServices.savePortfolioDetails(portfolioData))
          .called(1);
      verify(mockFirestoreServices.updateUser({'isProfessional': true}))
          .called(1);
    });

    test('should throw AppException when storage service fails', () async {
      // Arrange
      final images = [File('test.jpg')];
      when(mockStorageServices.uploadFilesForUser(images))
          .thenThrow(AppException('upload-files-error'));

      // Act & Assert
      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () =>
            repository.createPortfolio('Photography', 'Details', 6, 2, images),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('upload-files-error'))),
      );
    });

    test('should throw AppException when firestore update portfolio fails',
        () async {
      // Arrange
      final images = [File('test1.jpg'), File('test2.jpg')];
      const imageData = [
        {'filePath': 'image1/path', 'downloadUrl': 'image1.url'}
      ];

      when(mockStorageServices.uploadFilesForUser(images))
          .thenAnswer((_) async => imageData);
      when(mockFirestoreServices.savePortfolioDetails(any))
          .thenThrow(AppException('update-portfolio-error'));

      // Act & Assert
      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () =>
            repository.createPortfolio('Photography', 'Details', 6, 2, images),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('update-portfolio-error'))),
      );
    });

    test('should throw AppException when firestore update user fails',
        () async {
      // Arrange
      final images = [File('test1.jpg'), File('test2.jpg')];
      const imageData = [
        {'filePath': 'image1/path', 'downloadUrl': 'image1.url'}
      ];

      when(mockStorageServices.uploadFilesForUser(images))
          .thenAnswer((_) async => imageData);
      when(mockFirestoreServices.savePortfolioDetails(any))
          .thenAnswer((_) async => {});
      when(mockFirestoreServices.updateUser({'isProfessional': true}))
          .thenThrow(AppException('update-user-error'));

      // Act & Assert
      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () =>
            repository.createPortfolio('Photography', 'Details', 6, 2, images),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('update-user-error'))),
      );
    });
  });

  group('updatePortfolio', () {
    test('should update portfolio with new images', () async {
      // Arrange
      final images = [File('new.jpg')];
      const imageData = [
        {'filePath': 'image1/path', 'downloadUrl': 'image1.url'}
      ];
      final updateFields = {'service': 'Updated Service', 'images': imageData};

      when(mockStorageServices.uploadFilesForUser(images))
          .thenAnswer((_) async => imageData);
      when(mockFirestoreServices.savePortfolioDetails(updateFields))
          .thenAnswer((_) async => {});

      // Act
      final repository = container.read(portfolioRepositoryProvider);
      await repository.updatePortfolio(
        images: images,
        fields: {'service': 'Updated Service'},
      );

      // Assert
      verify(mockStorageServices.uploadFilesForUser(images)).called(1);
      verify(mockFirestoreServices.savePortfolioDetails(updateFields))
          .called(1);
    });

    test('should update portfolio without images', () async {
      // Arrange
      final updateFields = {'service': 'Updated Service'};
      when(mockFirestoreServices.savePortfolioDetails(updateFields))
          .thenAnswer((_) async => {});

      // Act
      final repository = container.read(portfolioRepositoryProvider);
      await repository.updatePortfolio(fields: updateFields);

      // Assert
      verifyNever(mockStorageServices.uploadFilesForUser(any));
      verify(mockFirestoreServices.savePortfolioDetails(updateFields))
          .called(1);
    });

    test('should throw AppException when storage upload fails', () {
      final images = [File('new.jpg')];

      when(mockStorageServices.uploadFilesForUser(images))
          .thenThrow(AppException('upload-files-error'));

      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () => repository
            .updatePortfolio(images: images, fields: {'service': 'newservice'}),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('upload-files-error'))),
      );
    });

    test('should throw AppException when firestore update fails', () {
      final images = [File('new.jpg')];
      const imageData = [
        {'filePath': 'image1/path', 'downloadUrl': 'image1.url'}
      ];
      final updateFields = {'service': 'Updated Service', 'images': imageData};
      when(mockStorageServices.uploadFilesForUser(images))
          .thenAnswer((_) async => imageData);
      when(mockFirestoreServices.savePortfolioDetails(updateFields))
          .thenThrow(AppException('update-portfolio-error'));

      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () => repository.updatePortfolio(images: images, fields: updateFields),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('update-portfolio-error'))),
      );
    });
  });

 group('deletePortfolioImage', () {
    test('should successfully delete portfolio image', () async {
      // Arrange
      const filePath = 'images/test.jpg';
      const downloadUrl = 'https://example.com/test.jpg';

      when(mockFirestoreServices.deletePortfolioImage(filePath, downloadUrl))
          .thenAnswer((_) async => {});
      when(mockStorageServices.deleteImage(filePath))
          .thenAnswer((_) async => {});

      // Act
      final repository = container.read(portfolioRepositoryProvider);
      await repository.deletePortfolioImage(filePath, downloadUrl);

      // Assert
      verify(mockFirestoreServices.deletePortfolioImage(filePath, downloadUrl)).called(1);
      verify(mockStorageServices.deleteImage(filePath)).called(1);
    });

    test('should throw AppException when firestore deletion fails', () async {
      // Arrange
      const filePath = 'images/test.jpg';
      const downloadUrl = 'https://example.com/test.jpg';

      when(mockFirestoreServices.deletePortfolioImage(filePath, downloadUrl))
          .thenThrow(AppException('delete-portfolio-image-error'));

      // Act & Assert
      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () => repository.deletePortfolioImage(filePath, downloadUrl),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-portfolio-image-error'))),
      );
    });

      test('should throw AppException when storage deletion fails', () async {
      // Arrange
      const filePath = 'images/test.jpg';
      const downloadUrl = 'https://example.com/test.jpg';

      when(mockFirestoreServices.deletePortfolioImage(filePath, downloadUrl))
          .thenAnswer((_) async => {});
      when(mockStorageServices.deleteImage(filePath))
          .thenThrow(AppException('delete-image-error'));

      // Act & Assert
      final repository = container.read(portfolioRepositoryProvider);
      expect(
        () => repository.deletePortfolioImage(filePath, downloadUrl),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-image-error'))),
      );
    });
  });
}
