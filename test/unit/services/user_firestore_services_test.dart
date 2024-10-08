import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/services/user_firestore_services.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  QuerySnapshot,
  Query,
  DocumentReference,
  QueryDocumentSnapshot,
  DocumentSnapshot
])
import '../../mocks/user_firestore_services_test.mocks.dart';

void main() {
  //Create ncessary mocks for services
  late UserFirestoreServices userFirestoreServices;
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

  setUp(() {
    mockFirebaseFirestore = MockFirebaseFirestore();
    userFirestoreServices =
        UserFirestoreServices(firestore: mockFirebaseFirestore);
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
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
      expect(() => userFirestoreServices.addUser(user), returnsNormally);
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
      expect(() => userFirestoreServices.addUser(user),
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
      final result = await userFirestoreServices.isUsernameUnique(username);

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
      final result = await userFirestoreServices.isUsernameUnique(username);

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
        'isProfessional': false
      };

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc('testUid')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn(user);

      final result = await userFirestoreServices.getUser('testUid');
      expect(result!.toJson(), equals(user));
    });

    test('should throw user-not-found when the user doesnt exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      expect(() => userFirestoreServices.getUser(uid), throwsA('user-not-found'));
    });

    test('should throw unexpected-error when the user doesnt exist', () async {
      const uid = 'testUid';

      when(mockFirebaseFirestore.collection('users'))
          .thenReturn(mockCollectionReference);
      when(mockCollectionReference.doc(uid)).thenThrow(Exception());

      expect(() => userFirestoreServices.getUser(uid), throwsA('unexpected-error'));
    });
  });
}
