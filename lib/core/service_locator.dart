import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/controller/user_location_controller.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/repositories/feedback_repository.dart';
import 'package:folio/repositories/message_repository.dart';
import 'package:folio/repositories/portfolio_repository.dart';
import 'package:folio/repositories/user_repository.dart';
import 'package:folio/services/auth_services.dart';
import 'package:folio/services/cloud_messaging_services.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/gemini_services.dart';
import 'package:folio/services/storage_services.dart';
import 'package:geolocator/geolocator.dart';
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

final firebaseFunctionsProvider = Provider<FirebaseFunctions>((ref) {
  return FirebaseFunctions.instance;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
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

final cloudMessagingServicesProvider = Provider<CloudMessagingServices>((ref) {
  final firestoreServices = ref.read(firestoreServicesProvider);
  final firebaseMessaging = ref.read(firebaseMessagingProvider);
  final firebaseFunctions = ref.read(firebaseFunctionsProvider);

  return CloudMessagingServices(firebaseMessaging, firestoreServices, firebaseFunctions);
});

final geminiServicesProvider = Provider<GeminiServices>((ref){
  return GeminiServices(ref);
});

////////////////// SERVICE FILES //////////////////

////////////////// REPOSITORIES //////////////////

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final authServices = ref.watch(authServicesProvider);
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final storageServices = ref.watch(storageServicesProvider);
  final cloudMessagingServices = ref.watch(cloudMessagingServicesProvider);
  return UserRepository(authServices, firestoreServices, storageServices, ref,
      cloudMessagingServices);
});

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final storageServices = ref.watch(storageServicesProvider);
  return PortfolioRepository(firestoreServices, storageServices);
});

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  return FeedbackRepository(firestoreServices);
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  final authServices = ref.watch(authServicesProvider);
  final cloudMessagingServices = ref.watch(cloudMessagingServicesProvider);
  return MessageRepository(firestoreServices, authServices, cloudMessagingServices);
});

////////////////// REPOSITORIES //////////////////

////////////////// STREAMS //////////////////

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

final emailVerificationStreamProvider = StreamProvider<bool>((ref) async* {
  final auth = ref.read(authServicesProvider);
  final userRepository = ref.read(userRepositoryProvider);

  while (true) {
    await Future.delayed(const Duration(seconds: 5));
    final user = auth.currentUser();
    try {
      await user?.reload(); // Reload user data
      final isVerified = user?.emailVerified ?? false;
      yield isVerified; // Emit the email verification status
      if (isVerified) {
        // Update Firestore when email is verified
        await userRepository.updateProfile(fields: {'isEmailVerified': true});
        break; // Stop emitting once verified
      }
    } catch (e) {
      yield false;
      break;
    }
  }
});

final chatroomStreamProvider = StreamProvider<List<ChatroomModel>>((ref) {
  final authState = ref.watch(authStateProvider).value;

  if (authState != null) {
    final firestoreServices = ref.read(firestoreServicesProvider);
    return firestoreServices.getChatrooms(authState.uid);
  } else {
    return Stream.value([]);
  }
});

final servicesStreamProvider = StreamProvider<List<String>>((ref){
  final firestoreServices = ref.watch(firestoreServicesProvider);
  return  firestoreServices.getServicesStream();
});

////////////////// STREAMS //////////////////
///
final locationServiceProvider = Provider<LocationService>((ref){
   GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
   GeocodingService geocodingService = GeocodingService();
      return LocationService(geolocatorPlatform, geocodingService);
    
});

final positionStreamProvider = StreamProvider<Position>((ref){
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getPositionStream();
});

final currentPositionProvider = StateProvider<Position?>((ref) => null);

final positionListenerProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<Position>>(positionStreamProvider, (previous, next) {
    next.whenData((position) {
      ref.read(currentPositionProvider.notifier).state = position;
    });
  });
});

final nearbyPortfoliosProvider = FutureProvider<List<PortfolioModel>>((ref) async {
  final positionAsyncValue = ref.watch(positionStreamProvider);
  return positionAsyncValue.when(data: (position) async {
    if (position.latitude >= -90 && position.latitude <= 90 &&
          position.longitude >= -180 && position.longitude <= 180) {
        return await ref.read(portfolioRepositoryProvider).getNearbyPortfolios(position.latitude, position.longitude);
      }      return [];
  }, loading: () => [],
    error: (error, stack) => [],);
});

final allPortfoliosProvider = FutureProvider<List<PortfolioModel>>((ref) async {
  final portfolioRepo = ref.read(portfolioRepositoryProvider);
  return portfolioRepo.getAllPortfolios();
});

void setupEmulators({bool useEmulators = false}) {
  if (useEmulators) {
    try {
      FirebaseAuth.instance.useAuthEmulator('127.0.0.1', 9099);
      FirebaseFirestore.instance.useFirestoreEmulator('127.0.0.1', 8080);
      FirebaseStorage.instance.useStorageEmulator('127.0.0.1', 9199);
      FirebaseFunctions.instance.useFunctionsEmulator('127.0.0.1', 5001);
      FirebaseMessaging.instance.setAutoInitEnabled(false);
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
