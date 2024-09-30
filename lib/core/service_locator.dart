

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';

final authServicesProvider = Provider<AuthServices>((ref) {
  return AuthServices();
});

final userFirestoreServicesProvider = Provider<UserFirestoreServices>((ref){
  return UserFirestoreServices();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authServices = ref.watch(authServicesProvider);
  final userFirestoreServices = ref.watch(userFirestoreServicesProvider);
  return UserRepository(authServices, userFirestoreServices);
});

void setupEmulators({bool useEmulators = false}) {
  if (useEmulators) {
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }
}