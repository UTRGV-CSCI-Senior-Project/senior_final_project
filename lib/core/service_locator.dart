

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:senior_final_project/repositories/user_repository.dart';
import 'package:senior_final_project/services/auth_services.dart';
import 'package:senior_final_project/services/user_firestore_services.dart';

//Global instance of GetIt, allows for global access of services
final locator = GetIt.instance;

void setUpLocator({bool useEmulators = false}) {


  //For testing, run services on emulators.
  if(useEmulators){
    //Set up Firebase authentication emulator
    FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

    //Set up Firebase Firestore emulator
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  //Register necessary services
  locator.registerSingleton<AuthServices>(AuthServices());
  locator.registerSingleton<UserFirestoreServices>(UserFirestoreServices());
  locator.registerSingleton<UserRepository>(UserRepository(locator<AuthServices>(), locator<UserFirestoreServices>()));

}