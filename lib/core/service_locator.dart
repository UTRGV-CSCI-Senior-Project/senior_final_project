import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/repositories/feedback_repository.dart';
import 'package:folio/repositories/message_repository.dart';
import 'package:folio/repositories/portfolio_repository.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:developer' as developer;

final imagePickerProvider = Provider<ImagePicker>((ref) {
  final imagePicker = ImagePicker();
  return imagePicker;
});


////////////////// FIREBASE SERVICES //////////////////

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

////////////////// FIREBASE SERVICES //////////////////


////////////////// SERVICE FILES //////////////////

final authServicesProvider = Provider<AuthServices>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthServices(firebaseAuth);
});

final firestoreServicesProvider = Provider<FirestoreServices>((ref) {
  final firebaseFirestore = ref.watch(firebaseFirestoreProvider);
  return FirestoreServices(firebaseFirestore, ref);
});

final storageServicesProvider = Provider<StorageServices>((ref) {
  final firebaseStorage = ref.watch(firebaseStorageProvider);
  return StorageServices(ref, firebaseStorage);
});

////////////////// SERVICE FILES //////////////////

////////////////// REPOSITORIES //////////////////

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authServices = ref.watch(authServicesProvider);
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final storageServices = ref.watch(storageServicesProvider);
  return UserRepository(authServices, firestoreServices, storageServices, ref);
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final storageServices = ref.watch(storageServicesProvider);
  return PortfolioRepository(firestoreServices, storageServices);
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref){
  final firestoreServices = ref.watch(firestoreServicesProvider);
  return FeedbackRepository(firestoreServices);
});

final messageRepositoryProvider = Provider<MessageRepository>((ref){
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final authServices = ref.watch(authServicesProvider);

  return MessageRepository(firestoreServices, authServices);
});

////////////////// REPOSITORIES //////////////////


////////////////// USER STREAMS //////////////////

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServicesProvider).authStateChanges();
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

final userDataStreamProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authStateProvider).value;

  if (authState != null) {
    final firestoreServices = ref.watch(firestoreServicesProvider);
    final userStream = firestoreServices.getUserStream(authState.uid);
    final portfolioStream = firestoreServices.getPortfolioStream(authState.uid);
    return Rx.combineLatest2(userStream, portfolioStream,
        (userData, portfolio) => {'user': userData, 'portfolio': portfolio});
  }
  return Stream.value(null);
});

final chatroomStreamProvider = StreamProvider<List<ChatroomModel>>((ref){
  final authState = ref.watch(authStateProvider).value;

  if (authState != null) {
    final firestoreServices = ref.read(firestoreServicesProvider);
    return firestoreServices.getChatrooms(authState.uid);
  } else {
    return Stream.value([]);
  }
});

final chatMessagesProvider = StreamProvider.autoDispose.family<List<MessageModel>, String>((ref, chatroomId) {
  final messageRepository = ref.watch(messageRepositoryProvider);
  return messageRepository.getChatroomMessages(chatroomId);
});


////////////////// USER STREAMS //////////////////


void setupEmulators({bool useEmulators = false}) {
  if (useEmulators) {
    try {
      FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
      // Add other emulators as needed

      developer.log(
        'Firebase emulators initialized successfully',
        name: 'EmulatorSetup',
        level: 1, // Info level
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to initialize Firebase emulators',
        name: 'EmulatorSetup',
        error: e,
        stackTrace: stackTrace,
        level: 900, // Error level
      );
    }
  }
}
