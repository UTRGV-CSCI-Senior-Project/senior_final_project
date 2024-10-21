import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/firestore_services.dart';

import '../../mocks/auth_services_test.mocks.dart';
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  QuerySnapshot,
  Query,
  DocumentReference,
  QueryDocumentSnapshot,
  DocumentSnapshot, 
  Ref
])
import '../../mocks/firestore_services_test.mocks.dart';
import '../../mocks/storage_services_test.mocks.dart';

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
  late MockUser mockUser;

  setUp(() {
    mockRef = MockRef();
    mockUser = MockUser();
    mockFirebaseFirestore = MockFirebaseFirestore();
    firestoreServices = FirestoreServices(mockFirebaseFirestore, mockRef);
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    provideDummy<AsyncValue<User?>>((const AsyncValue.data(null)));

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

      //Expect the addUser to return successfully
      expect(() => firestoreServices.addUser(user), returnsNormally);
      //Expect all necessary function to add a user to be called
      verify(mockFirebaseFirestore.collection('users')).called(1);
      verify(mockCollectionReference.doc(user.uid)).called(1);
      verify(mockDocumentReference.set(user.toJson())).called(1);
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

      //Expect a general exception to be caught
      expect(() => firestoreServices.addUser(user),
          throwsA(equals('unexpected-error')));
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

  group('getUser', () {
    test('should return UserModel when the user exists', () async {
      const user = {
        'uid': 'testUid',
        'username': 'testUsername',
        'fullName': 'testName',
        'email': 'test@email.com',
        'isProfessional': false,
        'completedOnboarding': false
      };

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('testUid')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(user);

      final result = await firestoreServices.getUser('testUid');
      expect(result!.toJson(), equals(user));
    });

    test('should throw user-not-found when the user doesnt exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      expect(() => firestoreServices.getUser(uid), throwsA('user-not-found'));
    });

    test('should throw unexpected-error when the user doesnt exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenThrow(Exception());

      expect(() => firestoreServices.getUser(uid), throwsA('unexpected-error'));
    });
  });

  group('updateUser', (){

    test('should update user successful',  () async {
      const uid = 'testUid';
      final fieldsToUpdate = {'username': 'newUsername'};

      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(uid);
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

    test('should throw update-failed on error', () async {
      const uid = 'testUid';
      final fieldsToUpdate = {'username': 'newUsername'};
      
      when(mockRef.read(authStateProvider)).thenReturn(AsyncValue.data(mockUser));
      when(mockUser.uid).thenReturn(uid);
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.update(fieldsToUpdate))
          .thenThrow(Exception('Update failed'));

      expect(
        () => firestoreServices.updateUser(fieldsToUpdate),
        throwsA('update-failed'),
      );
    });
  });

  group('getServices', () {
    test('should return list of services', () async {
      final mockQueryDocumentSnapshot1 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final mockQueryDocumentSnapshot2 = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      
      when(mockFirebaseFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot1, mockQueryDocumentSnapshot2]);
      
      when(mockQueryDocumentSnapshot1.get('service')).thenReturn('Service 1');
      when(mockQueryDocumentSnapshot2.get('service')).thenReturn('Service 2');

      final result = await firestoreServices.getServices();
      
      expect(result, equals(['Service 1', 'Service 2']));
    });

    test('should throw unexpected-error on fail', () async {
      when(mockFirebaseFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.get())
          .thenThrow(Exception('Fetch failed'));

      expect(
        firestoreServices.getServices,
        throwsA('unexpected-error'),
      );
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
      };
      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      
      final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(userJson);
      
      when(mockDocumentReference.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockDocumentSnapshot])
      );

      final stream = firestoreServices.getUserStream(uid);
      
      expect(stream, emits(isA<UserModel>()));
      
      final user = await stream.first;
      expect(user.toJson(), equals(userJson));

    });

    test('should throw user-not-found when document does not exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      
      final mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
      when(mockDocumentSnapshot.exists).thenReturn(false);
      
      when(mockDocumentReference.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockDocumentSnapshot])
      );

      final stream = firestoreServices.getUserStream(uid);
      
      expect(stream, emitsError('no-user'));
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
      
      when(mockDocumentReference.snapshots()).thenAnswer(
        (_) => Stream.fromIterable([mockDocumentSnapshot])
      );

      final stream = firestoreServices.getUserStream(uid);
      
      expect(stream, emitsError('invalid-user-data'));
    });

    test('should throw unexpected-error on stream error', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      
      when(mockDocumentReference.snapshots()).thenAnswer(
        (_) => Stream.error(Exception('Network error'))
      );

      final stream = firestoreServices.getUserStream(uid);
      
      expect(stream, emitsError('unexpected-error'));
    });
  });
}
