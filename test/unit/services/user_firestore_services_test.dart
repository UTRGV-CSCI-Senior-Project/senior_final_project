import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:senior_final_project/models/user_model.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  QuerySnapshot,
  Query,
  DocumentReference,
  QueryDocumentSnapshot
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

  setUp(() {
    mockFirebaseFirestore = MockFirebaseFirestore();
    userFirestoreServices = UserFirestoreServices(firestore: mockFirebaseFirestore);
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
  });
  tearDown(() {});

  test('add user successful', () async {
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
    when(mockDocumentReference.set(user.toJson())).thenAnswer((_) async => {});

    //Expect the addUser to return successfully
    expect(() => userFirestoreServices.addUser(user), returnsNormally);
    //Expect all necessary function to add a user to be called
    verify(mockFirebaseFirestore.collection('users')).called(1);
    verify(mockCollectionReference.doc(user.uid)).called(1);
    verify(mockDocumentReference.set(user.toJson())).called(1);
  });

  test('add user fails with generic exception', () async {
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
    expect(
        () => userFirestoreServices.addUser(user),
        throwsA(equals('unexpected-error')));
  });

  test('isUsernameUnique returns true if username is unique', () async {
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

  test('isUsernameUnique returns false if username is false', () async {
    const username = "takenUsername";

    //When accessing users collection and storing a user with a taken username, return a mock snapshot
    //Empty means no doc with the provided username was found == unique username 
    when(mockFirebaseFirestore.collection('users'))
        .thenReturn(mockCollectionReference);
    when(mockCollectionReference.where('username', isEqualTo: username))
        .thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
    when(mockQuerySnapshot.docs).thenReturn([mockQueryDocumentSnapshot]);

    //Call isUsernameUnique to check username
    final result = await userFirestoreServices.isUsernameUnique(username);

    //Expect false = taken username
    expect(result, false);
  });

}
