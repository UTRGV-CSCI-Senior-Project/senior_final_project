import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/feedback_model.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
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
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.update(fieldsToUpdate))
          .thenAnswer((_) async => {});
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(userData);
      when(mockCollectionReference.where('participantIds', arrayContains: uid))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);

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
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
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
        'profilePictureUrl': null,
        'isEmailVerified': false,
        'phoneNumber': null,
        'isPhoneVerified': false,
        'fcmTokens': null,
         'latitude': null,
         'longitude': null
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
        'uid': 'test-uid',
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
        'experienceStartDate': null,
        'address':  null,
        'latAndLong': null,
        'professionalsName': null,
        'nameArray': null
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

      final result = await firestoreServices.getUser();

      expect(result, isA<UserModel>());
      expect(result?.uid, equals(uid));
      expect(result?.email, equals('test@example.com'));
    });

    test('returns null when user document does not exist', () async {
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

      final result = await firestoreServices.getUser();

      expect(result, isNull);
    });

    test('throws AppException when no current user', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(null));
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
      const String uid = 'test-uid';
      final Map<String, dynamic> portfolioData = {
        'details': 'Test bio',
        'service': 'Barber',
        'uid': 'test-uid',
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

      final result = await firestoreServices.getPortfolio();

      expect(result, isA<PortfolioModel>());
      expect(result?.service, equals('Barber'));
    });

    test('returns null when portfolio does not exist', () async {
      const String uid = 'test-uid';
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);

      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);

      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      final result = await firestoreServices.getPortfolio();

      expect(result, isNull);
    });

    test('throws AppException when no current user', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);

      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);

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
      const String uid = 'test-uid';
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

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
        'isEmailVerified': FieldValue.delete(),
        'isPhoneVerified': FieldValue.delete(),
        'phoneNumber': FieldValue.delete(),
        'fcmTokens': FieldValue.delete(),
        'latitude': FieldValue.delete(),
        'longitude': FieldValue.delete(),
      })).called(1);
    });

    test('throws AppException when no current user', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);

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
      const String uid = 'test-uid';
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);
      when(mockDocumentReference.update(any))
          .thenThrow(Exception('Update failed'));

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

  group('addFeedback', () {
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
              e is AppException &&
              e.toString().contains('add-feedback-error'))));
    });
  });

  group('getChatParticipants', () {
    test('successfully retrieves chat participants', () async {
      final snapshot1 = MockDocumentSnapshot<Map<String, dynamic>>();
      final snapshot2 = MockDocumentSnapshot<Map<String, dynamic>>();
      final reference1 = MockDocumentReference<Map<String, dynamic>>();
      final reference2 = MockDocumentReference<Map<String, dynamic>>();

      const String chatroomId = 'user1_user2';
      final UserModel userOne = UserModel(
        uid: 'user1',
        username: 'testUser1',
        email: 'user1@test.com',
        isProfessional: false,
      );
      final UserModel userTwo = UserModel(
        uid: 'user2',
        username: 'testUser2',
        email: 'user2@test.com',
        isProfessional: true,
      );

      // Mock current user
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => 'user1');

      // Mock getUser
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('user1')).thenReturn(reference1);
      when(mockCollectionReference.doc('user2')).thenReturn(reference2);
      when(reference1.get()).thenAnswer((_) async => snapshot1);
      when(reference2.get()).thenAnswer((_) async => snapshot2);
      when(snapshot1.exists).thenReturn(true);
      when(snapshot2.exists).thenReturn(true);
      when(snapshot1.data()).thenReturn(userOne.toJson());
      when(snapshot2.data()).thenReturn(userTwo.toJson());

      final participants =
          await firestoreServices.getChatParticipants(chatroomId);

      expect(participants.length, 2);
      expect(participants[0].uid, 'user1');
      expect(participants[1].uid, 'user2');
    });

    test('throws get-user-error when current user is null', () async {
      const String chatroomId = 'user1_user2';

      // Mock current user
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);

      expect(
        () => firestoreServices.getChatParticipants(chatroomId),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'no-user',
        )),
      );
    });

    test('throws get-user-error when other user is null', () async {
      final snapshot1 = MockDocumentSnapshot<Map<String, dynamic>>();
      final snapshot2 = MockDocumentSnapshot<Map<String, dynamic>>();
      final reference1 = MockDocumentReference<Map<String, dynamic>>();
      final reference2 = MockDocumentReference<Map<String, dynamic>>();
      const String chatroomId = 'user1_user2';
      final UserModel userOne = UserModel(
        uid: 'user1',
        username: 'testUser1',
        email: 'user1@test.com',
        isProfessional: false,
      );

      // Mock current user
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => 'user1');
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('user1')).thenReturn(reference1);
      when(mockCollectionReference.doc('user2')).thenReturn(reference2);
      when(reference1.get()).thenAnswer((_) async => snapshot1);
      when(reference2.get()).thenAnswer((_) async => snapshot2);
      when(snapshot1.exists).thenReturn(true);
      when(snapshot2.exists).thenReturn(false);
      when(snapshot1.data()).thenReturn(userOne.toJson());

      expect(
        () => firestoreServices.getChatParticipants(chatroomId),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'no-chat-participant',
        )),
      );
    });
  });

  group('sendMessage', () {
    test('successfully sends a message to an existing chatroom', () async {
      const chatroomId = 'user1_user2';
      final MessageModel messageModel = MessageModel(
        senderId: 'user1',
        recieverId: 'user2',
        message: 'Test message',
        timestamp: DateTime.now(),
      );

      // Mock Firestore collections and documents
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(chatroomId))
          .thenReturn(mockDocumentReference);

      // Mock document snapshot to simulate existing chatroom
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);

      // Mock message collection
      when(mockDocumentReference.collection('messages'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.add(messageModel.toJson()))
          .thenAnswer((_) async => mockDocumentReference);
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.sendMessage(messageModel, chatroomId),
        completes,
      );
    });

    test('creates new chatroom when it does not exist', () async {
      final snapshot1 = MockDocumentSnapshot<Map<String, dynamic>>();
      final snapshot2 = MockDocumentSnapshot<Map<String, dynamic>>();
      final reference1 = MockDocumentReference<Map<String, dynamic>>();
      final reference2 = MockDocumentReference<Map<String, dynamic>>();
      const String chatroomId = 'user1_user2';
      final UserModel userOne = UserModel(
        uid: 'user1',
        username: 'testUser1',
        email: 'user1@test.com',
        isProfessional: false,
      );
      final UserModel userTwo = UserModel(
        uid: 'user2',
        username: 'testUser2',
        email: 'user2@test.com',
        isProfessional: true,
      );
      final MessageModel messageModel = MessageModel(
        senderId: 'user1',
        message: 'Test message',
        timestamp: DateTime.now(),
        recieverId: 'user2',
      );

      // Mock Firestore collections and documents
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(chatroomId))
          .thenReturn(mockDocumentReference);

      // Mock document snapshot to simulate non-existing chatroom
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      //Mock call to getChatParticipants
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => 'user1');
      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('user1')).thenReturn(reference1);
      when(mockCollectionReference.doc('user2')).thenReturn(reference2);
      when(reference1.get()).thenAnswer((_) async => snapshot1);
      when(reference2.get()).thenAnswer((_) async => snapshot2);
      when(snapshot1.exists).thenReturn(true);
      when(snapshot2.exists).thenReturn(true);
      when(snapshot1.data()).thenReturn(userOne.toJson());
      when(snapshot2.data()).thenReturn(userTwo.toJson());

      // Mock message collection
      when(mockDocumentReference.collection('messages'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.add(messageModel.toJson()))
          .thenAnswer((_) async => mockDocumentReference);
      when(mockDocumentReference.update(any)).thenAnswer((_) async => {});

      await expectLater(
        firestoreServices.sendMessage(messageModel, chatroomId),
        completes,
      );
    });

    test('throws send-message-error on general exception', () async {
      const String chatroomId = 'user1_user2';
      final MessageModel messageModel = MessageModel(
        senderId: 'user1',
        message: 'Test message',
        timestamp: DateTime.now(),
        recieverId: 'user2',
      );

      // Mock to throw a generic exception
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenThrow(Exception('Generic error'));

      expect(
        () => firestoreServices.sendMessage(messageModel, chatroomId),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'send-message-error',
        )),
      );
    });
  });

  group('getChatrooms', () {
    test('returns list of chatrooms for a user', () async {
      const String userId = 'user1';
      final mockQueryDocumentSnapshot1 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockQueryDocumentSnapshot2 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();

      // Mock Firestore query
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('participantIds',
              arrayContains: userId))
          .thenReturn(mockQuery);
      when(mockQuery.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockQuerySnapshot]));

      // Mock chatroom data
      when(mockQuerySnapshot.docs).thenReturn([
        mockQueryDocumentSnapshot1,
        mockQueryDocumentSnapshot2,
      ]);

      final chatroom = ChatroomModel(
          id: 'chatroom1',
          participants: [
            ChatParticipant(uid: 'uid', identifier: 'identifier'),
            ChatParticipant(uid: 'uid', identifier: 'identifier')
          ],
          lastMessage: MessageModel(
              senderId: 'senderId',
              recieverId: 'recieverId',
              message: 'message',
              timestamp: DateTime.now()),
          participantIds: ['uid', 'uid']);

      when(mockQueryDocumentSnapshot1.data()).thenReturn(chatroom.toJson());
      when(mockQueryDocumentSnapshot2.data()).thenReturn(chatroom.toJson());

      final chatroomsStream = firestoreServices.getChatrooms(userId);

      expect(
        chatroomsStream,
        emits(
          allOf(
            hasLength(2),
            contains(isA<ChatroomModel>()),
          ),
        ),
      );
    });

    test('throws get-chatrooms-error on exception', () async {
      const String userId = 'user1';

      // Mock to throw an exception
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenThrow(Exception('Generic error'));

      expect(
        () => firestoreServices.getChatrooms(userId),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'get-chatrooms-error',
        )),
      );
    });
  });

  group('getChatroomMessages', () {
    test('returns stream of messages for a chatroom', () async {
      const String chatroomId = 'user1_user2';
      final mockQueryDocumentSnapshot1 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockQueryDocumentSnapshot2 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();

      // Mock Firestore query
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(chatroomId))
          .thenReturn(mockDocumentReference);

      final mockMessagesCollection =
          MockCollectionReference<Map<String, dynamic>>();
      when(mockDocumentReference.collection('messages'))
          .thenReturn(mockMessagesCollection);
      when(mockMessagesCollection.orderBy('timestamp', descending: true))
          .thenReturn(mockQuery);
      when(mockQuery.limit(100)).thenReturn(mockQuery);
      when(mockQuery.snapshots())
          .thenAnswer((_) => Stream.fromIterable([mockQuerySnapshot]));

      // Mock message data
      when(mockQuerySnapshot.docs).thenReturn([
        mockQueryDocumentSnapshot1,
        mockQueryDocumentSnapshot2,
      ]);

      final message1 = MessageModel(
          senderId: 'user1',
          recieverId: 'user2',
          message: 'Hello',
          timestamp: DateTime.now());
      final message2 = MessageModel(
          senderId: 'user2',
          recieverId: 'user1',
          message: 'Hi there!',
          timestamp: DateTime.now());

      when(mockQueryDocumentSnapshot1.data()).thenReturn(message1.toJson());
      when(mockQueryDocumentSnapshot2.data()).thenReturn(message2.toJson());

      final messagesStream = firestoreServices.getChatroomMessages(chatroomId);

      await expectLater(
        messagesStream,
        emits(
          allOf(
            hasLength(2),
            contains(isA<MessageModel>()),
          ),
        ),
      );
    });

    test('throws get-messages-error on exception', () async {
      const String chatroomId = 'user1_user2';

      // Mock to throw an exception
      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenThrow(Exception('Generic error'));

      expect(
        () => firestoreServices.getChatroomMessages(chatroomId),
        throwsA(isA<AppException>().having(
          (e) => e.code,
          'code',
          'get-messages-error',
        )),
      );
    });
  });

  group('updateChatroomParticipant', () {
    test('successfully updates participant info', () async {
      const String uid = 'user1';
      final UserModel updatedUser = UserModel(
        uid: uid,
        username: 'updatedUsername',
        email: 'updated@test.com',
        isProfessional: true,
      );

      // Mock current user retrieval
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);

      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(updatedUser.toJson());

      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('participantIds', arrayContains: uid))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      final mockChatroomDoc1 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockChatroomDoc2 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs)
          .thenReturn([mockChatroomDoc1, mockChatroomDoc2]);
      final chatroom1 = ChatroomModel(
          id: 'user1_user2',
          participants: [
            ChatParticipant(uid: 'user1', identifier: 'user 1'),
            ChatParticipant(uid: 'user2', identifier: 'user2')
          ],
          lastMessage: MessageModel(
              senderId: 'senderId',
              recieverId: 'recieverId',
              message: 'message',
              timestamp: DateTime.now()),
          participantIds: ['user1', 'user2']);
      final chatroom2 = ChatroomModel(
          id: 'user1_user3',
          participants: [
            ChatParticipant(uid: 'user1', identifier: 'user 1'),
            ChatParticipant(uid: 'user3', identifier: 'user3')
          ],
          lastMessage: MessageModel(
              senderId: 'senderId',
              recieverId: 'recieverId',
              message: 'message',
              timestamp: DateTime.now()),
          participantIds: ['user1', 'user3']);
      when(mockChatroomDoc1.data()).thenReturn(chatroom1.toJson());
      when(mockChatroomDoc2.data()).thenReturn(chatroom2.toJson());
      final docReference1 = MockDocumentReference<Map<String, dynamic>>();
      final docReference2 = MockDocumentReference<Map<String, dynamic>>();
      when(mockChatroomDoc1.reference).thenReturn(docReference1);
      when(mockChatroomDoc2.reference).thenReturn(docReference2);

      when(docReference1.update(any)).thenAnswer((_) async => Future.value());
      when(docReference1.update(any)).thenAnswer((_) async => Future.value());

      expectLater(firestoreServices.updateChatroomParticipant(), completes);
    });

    test('throws error when getUser fails', () async {
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => null);

      // Mock getUser failing

      expect(
          () => firestoreServices.updateChatroomParticipant(),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'error code', 'no-user')));
    });

    test('throws update-chatroom-participant-error when update fails',
        () async {
      const String uid = 'user1';
      final UserModel updatedUser = UserModel(
        uid: uid,
        username: 'updatedUsername',
        email: 'updated@test.com',
        isProfessional: true,
      );

      // Mock current user retrieval
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid()).thenAnswer((_) async => uid);

      when(mockFirebaseFirestore.collection(any))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
      when(mockRef.read(authServicesProvider)).thenReturn(mockAuthServices);
      when(mockAuthServices.currentUserUid())
          .thenAnswer((_) => Future.value(uid));
      when(mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(updatedUser.toJson());

      when(mockFirebaseFirestore.collection('chatrooms'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.where('participantIds', arrayContains: uid))
          .thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      final mockChatroomDoc1 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockChatroomDoc2 =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs)
          .thenReturn([mockChatroomDoc1, mockChatroomDoc2]);
      final chatroom1 = ChatroomModel(
          id: 'user1_user2',
          participants: [
            ChatParticipant(uid: 'user1', identifier: 'user 1'),
            ChatParticipant(uid: 'user2', identifier: 'user2')
          ],
          lastMessage: MessageModel(
              senderId: 'senderId',
              recieverId: 'recieverId',
              message: 'message',
              timestamp: DateTime.now()),
          participantIds: ['user1', 'user2']);
      final chatroom2 = ChatroomModel(
          id: 'user1_user3',
          participants: [
            ChatParticipant(uid: 'user1', identifier: 'user 1'),
            ChatParticipant(uid: 'user3', identifier: 'user3')
          ],
          lastMessage: MessageModel(
              senderId: 'senderId',
              recieverId: 'recieverId',
              message: 'message',
              timestamp: DateTime.now()),
          participantIds: ['user1', 'user3']);
      when(mockChatroomDoc1.data()).thenReturn(chatroom1.toJson());
      when(mockChatroomDoc2.data()).thenReturn(chatroom2.toJson());
      final docReference1 = MockDocumentReference<Map<String, dynamic>>();
      final docReference2 = MockDocumentReference<Map<String, dynamic>>();
      when(mockChatroomDoc1.reference).thenReturn(docReference1);
      when(mockChatroomDoc2.reference).thenReturn(docReference2);

      when(docReference1.update(any)).thenThrow(Exception('error'));

      expectLater(
          firestoreServices.updateChatroomParticipant(),
          throwsA(isA<AppException>().having(
              (e) => e.code, 'error', 'update-chatroom-participant-error')));
    });
  });

  group('getBounds', () {
    test('calculates correct bounds for given location and radius', () {
      const centerLat = 40.7128;
      const centerLong = -74.0060;
      const radiusKm = 10.0;

      final bounds = firestoreServices.getBounds(centerLat, centerLong, radiusKm);

      expect(bounds['minLat'], lessThan(centerLat));
      expect(bounds['maxLat'], greaterThan(centerLat));
      expect(bounds['minLong'], lessThan(centerLong));
      expect(bounds['maxLong'], greaterThan(centerLong));
    });

    test('handles zero radius correctly', () {
      const centerLat = 40.7128;
      const centerLong = -74.0060;
      const radiusKm = 0.0;

      final bounds = firestoreServices.getBounds(centerLat, centerLong, radiusKm);

      expect(bounds['minLat'], closeTo(centerLat, 0.0001));
      expect(bounds['maxLat'], closeTo(centerLat, 0.0001));
      expect(bounds['minLong'], closeTo(centerLong, 0.0001));
      expect(bounds['maxLong'], closeTo(centerLong, 0.0001));
    });
  });

  group('getNearbyPortfolios', () {
    test('retrieves nearby portfolios successfully', () async {
      const lat = 40.7128;
      const lng = -74.0060;
      final bounds = firestoreServices.getBounds(lat, lng, 32.1869);
      final Map<String, dynamic> portfolioData = {
        'details': 'Test bio',
        'service': 'Barber',
        'uid': 'test-uid',
        'years': 4,
        'months': 4,
        'images': [
          {'filePath': 'path1', 'downloadUrl': 'url1'},
          {'filePath': 'path2', 'downloadUrl': 'url2'},
        ],
      };
    

      // Setup mock chain for Firestore query
      when(mockFirebaseFirestore.collection('portfolios')).thenReturn(mockCollectionReference);
      // Chained where clauses with specific arguments
      when(mockCollectionReference.where(
        'latAndLong.longitude', 
        isGreaterThanOrEqualTo: bounds['minLong']
      )).thenReturn(mockQuery);
      
      when(mockQuery.where(
        'latAndLong.longitude', 
        isLessThanOrEqualTo: bounds['maxLong']
      )).thenReturn(mockQuery);
      
      when(mockQuery.where(
        'latAndLong.latitude', 
        isGreaterThanOrEqualTo: bounds['minLat']
      )).thenReturn(mockQuery);
      
      when(mockQuery.where(
        'latAndLong.latitude', 
        isLessThanOrEqualTo: bounds['maxLat']
      )).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async {
        return mockQuerySnapshot;
      });
      final mockQueryDocumentSnapshot =
          MockQueryDocumentSnapshot<Map<String, dynamic>>();
      when(mockQuerySnapshot.docs).thenReturn([
          mockQueryDocumentSnapshot
        ]);
      when(mockQueryDocumentSnapshot.data()).thenReturn(portfolioData);

      final result = await firestoreServices.getNearbyPortfolios(lat, lng);

      expect(result, isNotEmpty);
      expect(result.first.uid, 'test-uid');
    });

    test('handles generic exception by throwing AppException', () async {
      const lat = 40.7128;
      const lng = -74.0060;

      // Setup mock to throw a generic exception
      when(mockFirebaseFirestore.collection('portfolios')).thenReturn(mockCollectionReference);
      when(mockCollectionReference.where(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenThrow(Exception('Database error'));

      expect(
        () => firestoreServices.getNearbyPortfolios(lat, lng),
        throwsA(predicate((e) => 
          e is AppException && e.toString().contains('get-portfolios-error')
        ))
      );
    });
  });

  group('discoverPortfolios', () {

    test('retrieves discover portfolios correctly', () async {
    MockQuery<Map<String, dynamic>> mockNameQuery = MockQuery<Map<String, dynamic>>();
    MockQuery<Map<String, dynamic>> mockServiceQuery = MockQuery<Map<String, dynamic>>();  
    MockQuerySnapshot<Map<String, dynamic>> mockNameQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    MockQuerySnapshot<Map<String, dynamic>> mockServiceQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    MockQueryDocumentSnapshot<Map<String, dynamic>> mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    final mockDocs = [
      mockQueryDocumentSnapshot
    ];
     final portfolioJson = {
        'service': 'Nail Tech',
        'uid': 'test-uid',
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
        'experienceStartDate': null,
        'location':  null,
        'latAndLong': null,
        'professionalsName': null,
        'nameArray': null
      };

    final searchQuery = ['Nail Tech'];
         when(mockFirebaseFirestore.collection('portfolios'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.where('nameArray', arrayContainsAny: searchQuery))
        .thenReturn(mockNameQuery);
    when(mockCollectionReference.where('service', whereIn: searchQuery))
        .thenReturn(mockServiceQuery);
    when(mockNameQuery.get()).thenAnswer((_) async => mockNameQuerySnapshot);
    when(mockServiceQuery.get()).thenAnswer((_) async => mockServiceQuerySnapshot);
    when(mockNameQuerySnapshot.docs).thenReturn(mockDocs);
    when(mockServiceQuerySnapshot.docs).thenReturn(mockDocs);
    when(mockQueryDocumentSnapshot.data()).thenReturn(portfolioJson);

final result = await firestoreServices.discoverPortfolios(searchQuery);
    expect(result.length, 1);
    expect(result.first.service, 'Nail Tech');

    });

    test('returns empty list when searchQuery is empty', () async {
    final result = await firestoreServices.discoverPortfolios([]);
    expect(result, isEmpty);
  });

   test('throws AppException on error', () async {
    final searchQuery = ['nail', 'tech'];
    when(mockFirebaseFirestore.collection('portfolios'))
        .thenThrow(Exception('Firestore error'));

    expect(
      () async => await firestoreServices.discoverPortfolios(searchQuery),
      throwsA(isA<AppException>().having((e) => e.code, 'code', 'discover-portfolios-error')),
    );
  });
  });
}
