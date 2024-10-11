

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref){
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref){
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref){
  return FirebaseStorage.instance;
});

final authServicesProvider = Provider<AuthServices>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthServices(firebaseAuth);
});

final firestoreServicesProvider = Provider<FirestoreServices>((ref){
  final firebaseFirestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreServices(firebaseFirestore, ref);
});

final storageServicesProvider = Provider<StorageServices>((ref){
  final firebaseStorage = ref.watch(firebaseStorageProvider);
  return StorageServices(ref, firebaseStorage);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authServices = ref.watch(authServicesProvider);
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final storageServices = ref.watch(storageServicesProvider);
  return UserRepository(authServices, firestoreServices, storageServices, ref);
});

final authStateProvider = StreamProvider<User?>((ref){
  return ref.watch(authServicesProvider).authStateChanges();
});


final userModelProvider = FutureProvider<UserModel?>((ref) async {
  final authState = await ref.watch(authStateProvider.future);
  if (authState != null) {
    final firestoreServices = ref.read(firestoreServicesProvider);
    return await firestoreServices.getUser(authState.uid);
  }
  return null;
});

final userStreamProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider).value;

  if (authState != null) {
    final firestoreServices = ref.read(firestoreServicesProvider);
    return firestoreServices.getUserStream(authState.uid);
  } else {
    return Stream.value(null);
  }
});

void setupEmulators({bool useEmulators = false}) {
  if(useEmulators){
    try {
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      // Add other emulators as needed
    } catch (e) {
    }
  }

}