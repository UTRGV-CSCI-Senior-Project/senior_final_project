

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';

final locator = GetIt.instance;

void setUpLocator({bool useEmulators = false}) {

  if(useEmulators){
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  locator.registerSingleton<AuthServices>(AuthServices());
  locator.registerSingleton<UserFirestoreServices>(UserFirestoreServices());
  locator.registerSingleton<UserRepository>(UserRepository(locator<AuthServices>(), locator<UserFirestoreServices>()));

}