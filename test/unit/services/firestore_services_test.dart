import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/feedback_model.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/services/auth_services.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/firestore_services.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  QuerySnapshot,
  Query,
  DocumentReference,
  QueryDocumentSnapshot,
  DocumentSnapshot,
  Ref,
  WriteBatch
])
import '../../mocks/firestore_services_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  //Create ncessary mocks for services
  late FirestoreServices firestoreServices;
  late MockRef mockRef;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockAuthServices mockAuthServices;

  setUp(() {
    mockRef = MockRef();
    mockAuthServices = MockAuthServices();
    mockFirebaseFirestore = MockFirebaseFirestore();
    firestoreServices = FirestoreServices(mockFirebaseFirestore, mockRef);
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    provideDummy<AsyncValue<User?>>((const AsyncValue.data(null)));
    provideDummy<AuthServices>(mockAuthServices);
  });
  tearDown(() {});

  group('addUser', () {
    test('adds user successfuly', () async {
      //Create necessary information for creating a user
      final user = UserModel(
          uid: '1',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false);

      //When accessing users collection and storing a user, return successfully
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(user.uid))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(user.toJson()))
          .thenAnswer((_) async => {});
      when(mockDocumentReference.get())
          .thenAnswer((_) => Future.value(mockDocumentSnapshot));
      when(mockDocumentSnapshot.exists).thenReturn(false);
      //Expect the addUser to return successfully
      expect(() => firestoreServices.addUser(user), returnsNormally);
      //Expect all necessary function to add a user to be called
      verify(mockFirebaseFirestore.collection('users')).called(1);
      verify(mockCollectionReference.doc(user.uid)).called(1);
    });

    test('fails with generic exception', () async {
      //Create necessary information for a user
      final user = UserModel(
          uid: '1',
          username: 'username',
          email: 'email@email.com',
          isProfessional: false);

      //When accessing users collection and storing a user, throw a general exception
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(user.uid))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(user.toJson()))
          .thenThrow(Exception('failed'));
      when(mockDocumentReference.get())
          .thenAnswer((_) => Future.value(mockDocumentSnapshot));
      when(mockDocumentSnapshot.exists).thenReturn(false);

      //Expect a general exception to be caught
      expect(
          () => firestoreServices.addUser(user),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('add-user-error'))));
    });
  });

  group('isUsernameUnique', () {
    test('returns true if username is unique', () async {
      const username = "uniqueUsername";

      //When accessing users collection and storing a user with a unique username, return an empty snapshot
      //Empty means no doc with the provided username was found == unique username
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('username', isEqualTo: username))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

      //Call isUsernameUnique to check username
      final result = await firestoreServices.isUsernameUnique(username);

      //Expect true == unique username
      expect(result, true);
    });

    test('returns false if username is false', () async {
      const username = "takenUsername";

      //When accessing users collection and storing a user with a taken username, return a mock snapshot
      //Empty means no doc with the provided username was found == unique username
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('username', isEqualTo: username))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      final mockQueryDocumentSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

      //Call isUsernameUnique to check username
      final result = await firestoreServices.isUsernameUnique(username);

      //Expect false = taken username
      expect(result, false);
    });
  });

  group('updateUser', () {
    test('should update user successful', () async {
      const uid = 'testUid';
      final fieldsToUpdate = {'username': 'newUsername'};
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.update(fieldsToUpdate))
          .thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.updateUser(fieldsToUpdate),
        completes,
      );

      verify(mockDocumentReference.update(fieldsToUpdate)).called(1);
    });

    test('should throw update-user-error on error', () async {
      const uid = 'testUid';
      final fieldsToUpdate = {'username': 'newUsername'};

      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.update(fieldsToUpdate))
          .thenThrow(Exception('Update failed'));

      expect(
        () => firestoreServices.updateUser(fieldsToUpdate),
        throwsA(predicate((e) =>
            e is AppException && e.toString().contains('update-user-error'))),
      );
    });
  });

  group('getServices', () {
    test('should return list of services', () async {
      final mockQueryDocumentSnapshot1 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockQueryDocumentSnapshot2 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();

      when(mockFirebaseFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs)
          .thenReturn([mockQueryDocumentSnapshot1, mockQueryDocumentSnapshot2]);

      when(mockQueryDocumentSnapshot1.get('service')).thenReturn('Service 1');
      when(mockQueryDocumentSnapshot2.get('service')).thenReturn('Service 2');

      final result = await firestoreServices.getServices();

      expect(result, equals(['Service 1', 'Service 2']));
    });

    test('should throw get-services-error on fail', () async {
      when(mockFirebaseFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.get()).thenThrow(Exception('Fetch failed'));

      expect(
          firestoreServices.getServices,
          throwsA(predicate((e) =>
              e is AppException &&
              e.toString().contains('get-services-error'))));
    });
  });

  group('getUserStream', () {
    test('returns a stream of UserModel when the data is valid', () async {
      const uid = 'testUid';
      final userJson = {
        'uid': uid,
        'username': 'testUsername',
        'fullName': 'test name',
        'email': 'test@email.com',
        'isProfessional': false,
        'completedOnboarding': false,
        'preferredServices': [],
        'profilePictureUrl': null
      };
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(userJson);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockDocumentSnapshot]));

      final stream = firestoreServices.getUserStream(uid);

      expect(stream, emits(isA<UserModel>()));

      final user = await stream.first;
      expect(user.toJson(), equals(userJson));
    });

    test('should throw no-user when document does not exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocumentSnapshot.exists).thenReturn(false);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockDocumentSnapshot]));

      final stream = firestoreServices.getUserStream(uid);

      expect(
          stream,
          emitsError(predicate((error) =>
              error is AppException && error.toString().contains('no-user'))));
    });

    test('should throw invalid-user-data when data is invalid', () async {
      const uid = 'testUid';
      final invalidUserJson = {
        'uid': uid,
        'username': 'testUsername',
        // Missing required fields
      };

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(invalidUserJson);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockDocumentSnapshot]));

      final stream = firestoreServices.getUserStream(uid);

      expect(
          stream,
          emitsError(predicate((error) =>
              error is AppException &&
              error.toString().contains('invalid-user-data'))));
    });

    test('should throw user-stream-error on stream error', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.error(Exception('Network error')));

      final stream = firestoreServices.getUserStream(uid);

      expect(
          stream,
          emitsError(predicate((error) =>
              error is AppException &&
              error.toString().contains('user-stream-error'))));
    });
  });

  group('getPortfolioStream', () {
    test('returns stream of PortfolioModel when data is valid', () async {
      const uid = 'testUid';
      final portfolioJson = {
        'service': 'Barber',
        'details': 'details',
        'years': 5,
        'months': 3,
        'images': [
          {
            'filePath': 'path/to/image1',
            'downloadUrl': 'http://example.com/image1'
          },
          {
            'filePath': 'path/to/image2',
            'downloadUrl': 'http://example.com/image2'
          }
        ],
        'experienceStartDate': null
      };

      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(portfolioJson);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockDocumentSnapshot]));

      final stream = firestoreServices.getPortfolioStream(uid);

      expect(stream, emits(isA<PortfolioModel>()));

      final portfolio = await stream.first;
      expect(portfolio?.toJson(), equals(portfolioJson));
    });

    test('returns null when portfolio document does not exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      when(mockDocumentSnapshot.exists).thenReturn(false);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockDocumentSnapshot]));

      final stream = firestoreServices.getPortfolioStream(uid);
      expect(stream, emits(isNull));
    });

    test('throws invalid-portfolio-data when data is invalid', () async {
      const uid = 'testUid';
      final invalidPortfolioJson = {
        'service': 'Nail Tech',
        // Missing required fields
      };

      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(invalidPortfolioJson);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockDocumentSnapshot]));

      final stream = firestoreServices.getPortfolioStream(uid);
      expect(
          stream,
          emitsError(predicate((error) =>
              error is AppException &&
              error.toString().contains('invalid-portfolio-data'))));
    });

    test('throws portfolio-stream-error on stream error', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);

      when(mockDocumentReference.snapshots())
          .thenAnswer((_) => Stream.error(Exception('Network error')));

      final stream = firestoreServices.getPortfolioStream(uid);
      expect(
          stream,
          emitsError(predicate((error) =>
              error is AppException &&
              error.toString().contains('portfolio-stream-error'))));
    });
  });

  group('savePortfolioDetails', () {
    const uid = 'testUid';
    final Map<String, String> fieldsToUpdate = {
      'service': 'landscaper',
      'details': 'grass'
    };

    setUp(() {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
    });

    test('creates new portfolio when document does not exist', () async {
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);
      when(mockDocumentReference.set(fieldsToUpdate))
          .thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.savePortfolioDetails(fieldsToUpdate),
        completes,
      );

      verify(mockDocumentReference.set(fieldsToUpdate)).called(1);
    });

    test('updates existing portfolio when document exists', () async {
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentReference.update(fieldsToUpdate))
          .thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.savePortfolioDetails(fieldsToUpdate),
        completes,
      );

      verify(mockDocumentReference.update(fieldsToUpdate)).called(1);
    });

    test('throws no-user when uid is null', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(null));

      expect(
        () => firestoreServices.savePortfolioDetails(fieldsToUpdate),
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('no-user'))),
      );
    });

    test('throws update-portfolio-error on general error', () async {
      when(mockDocumentReference.get()).thenThrow(Exception('Update failed'));

      expect(
        () => firestoreServices.savePortfolioDetails(fieldsToUpdate),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('update-portfolio-error'))),
      );
    });
  });

  group('deletePortfolioImage', () {
    const uid = 'testUid';
    const filePath = 'path/to/image';
    const downloadUrl = 'http://example.com/image';

    setUp(() {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
    });

    test('successfully removes image from portfolio', () async {
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.deletePortfolioImage(filePath, downloadUrl),
        completes,
      );

      verify(mockDocumentReference.update({
        'images': FieldValue.arrayRemove([
          {
            'filePath': filePath,
            'downloadUrl': downloadUrl,
          }
        ])
      })).called(1);
    });

    test('throws no-user when uid is null', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(null));

      expect(
        () => firestoreServices.deletePortfolioImage(filePath, downloadUrl),
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('no-user'))),
      );
    });

    test('throws delete-portfolio-image-error on general error', () async {
      when(mockDocumentReference.update(any))
          .thenThrow(Exception('Delete failed'));

      expect(
        () => firestoreServices.deletePortfolioImage(filePath, downloadUrl),
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-portfolio-image-error'))),
      );
    });
  });

  group('deletePortfolio', () {
    const uid = 'testUid';

    setUp(() {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockFirebaseFirestore.collection('portfolios'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
    });

    test('successfully deletes portfolio document', () async {
      when(mockDocumentReference.delete()).thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.deletePortfolio(),
        completes,
      );

      verify(mockDocumentReference.delete()).called(1);
    });

    test('throws no-user when uid is null', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(null));

      expect(
        firestoreServices.deletePortfolio,
        throwsA(predicate(
            (e) => e is AppException && e.toString().contains('no-user'))),
      );
    });

    test('throws delete-portfolio-error on general error', () async {
      when(mockDocumentReference.delete())
          .thenThrow(Exception('Delete failed'));

      expect(
        firestoreServices.deletePortfolio,
        throwsA(predicate((e) =>
            e is AppException &&
            e.toString().contains('delete-portfolio-error'))),
      );
    });
  });

  group('getUser', () {
    test('returns UserModel when user exists', () async {
      // Arrange
      const String uid = 'test-uid';
      final Map<String, dynamic> userData = {
        'uid': uid,
        'email': 'test@example.com',
        'username': 'testuser',
        'fullName': 'Test User',
        'completedOnboarding': true,
        'isProfessional': false,
        'preferredServices': ['service1', 'service2'],
        'profilePictureUrl': 'https://example.com/pic.jpg',
      };
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(userData);

      // Act
      final result = await firestoreServices.getUser();

      // Assert
      expect(result, isA<UserModel>());
      expect(result?.uid, equals(uid));
      expect(result?.email, equals('test@example.com'));
    });

    test('returns null when user document does not exist', () async {
      // Arrange
      const String uid = 'test-uid';
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      // Act
      final result = await firestoreServices.getUser();

      // Assert
      expect(result, isNull);
    });

    test('throws AppException when no current user', () async {
      // Arrange
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(null));
      // Act & Assert
      expect(
        () => firestoreServices.getUser(),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'no-user',
        )),
      );
    });
  });

  group('getPortfolio', () {
    test('returns PortfolioModel when portfolio exists', () async {
      // Arrange
      const String uid = 'test-uid';
      final Map<String, dynamic> portfolioData = {
        'details': 'Test bio',
        'service': 'Barber',
        'years': 4,
        'months': 4,
        'images': [
          {'filePath': 'path1', 'downloadUrl': 'url1'},
          {'filePath': 'path2', 'downloadUrl': 'url2'},
        ],
      };
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(portfolioData);

      // Act
      final result = await firestoreServices.getPortfolio();

      // Assert
      expect(result, isA<PortfolioModel>());
      expect(result?.service, equals('Barber'));
    });

    test('returns null when portfolio does not exist', () async {
      // Arrange
      const String uid = 'test-uid';
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);

      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);

      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      // Act
      final result = await firestoreServices.getPortfolio();

      // Assert
      expect(result, isNull);
    });

    test('throws AppException when no current user', () async {
      // Arrange
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);

      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => firestoreServices.getPortfolio(),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'no-user',
        )),
      );
    });
  });

  group('deleteUser', () {
    test('successfully deletes user fields', () async {
      // Arrange
      const String uid = 'test-uid';
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

      // Act & Assert
      await firestoreServices.deleteUser();

      verify(mockDocumentReference.update({
        'completedOnboarding': FieldValue.delete(),
        'email': FieldValue.delete(),
        'fullName': FieldValue.delete(),
        'isProfessional': FieldValue.delete(),
        'preferredServices': FieldValue.delete(),
        'profilePictureUrl': FieldValue.delete(),
        'uid': FieldValue.delete(),
        'username': FieldValue.delete(),
      })).called(1);
    });

    test('throws AppException when no current user', () async {
      // Arrange
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);

      // Act & Assert
      expect(
        () => firestoreServices.deleteUser(),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'no-user',
        )),
      );
    });

    test('throws AppException when update fails', () async {
      // Arrange
      const String uid = 'test-uid';
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.update(any))
          .thenThrow(Exception('Update failed'));

      // Act & Assert
      expect(
        () => firestoreServices.deleteUser(),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'delete-user-error',
        )),
      );
    });
  });

  group('addFeedback', ()  {
 test('adds feedback successfuly', () async {
      //Create necessary information for creating a feedback
      final now = DateTime.now();
      final feedback = FeedbackModel(
        id: '123',
        subject: 'Test Subject',
        message: 'Test Message',
        type: 'bug',
        deviceInfo: 'Test Device',
        appVersion: '1.0.0',
        createdAt: now,
        userId: 'user123',
      );
      //When accessing feedback collection and storing a feedback, return successfully
      when(mockFirebaseFirestore.collection('feedback'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(feedback.id))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(feedback.toJson()))
          .thenAnswer((_) async => {});
     
      //Expect the addFeedback to return successfully
      expect(() => firestoreServices.addFeedback(feedback), returnsNormally);
      //Expect all necessary function to add a feedback to be called
      verify(mockFirebaseFirestore.collection('feedback')).called(1);
      verify(mockCollectionReference.doc(feedback.id)).called(1);
    });

    test('fails with generic exception', () async {
      //Create necessary information for creating a feedback
      final now = DateTime.now();
      final feedback = FeedbackModel(
        id: '123',
        subject: 'Test Subject',
        message: 'Test Message',
        type: 'bug',
        deviceInfo: 'Test Device',
        appVersion: '1.0.0',
        createdAt: now,
        userId: 'user123',
      );
      //When accessing feedback collection and storing a feedback, throw a general exception
      when(mockFirebaseFirestore.collection('feedback'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(feedback.id))
          .thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(feedback.toJson()))
          .thenThrow(Exception('failed'));
      
      //Expect a general exception to be caught
      expect(
          () => firestoreServices.addFeedback(feedback),
          throwsA(predicate((e) =>
              e is AppException && e.toString().contains('add-feedback-error'))));
    });
  });
}
