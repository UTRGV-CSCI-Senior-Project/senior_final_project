import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/services/firestore_services.dart';

class CloudMessagingServices {
  final FirebaseMessaging _firebaseMessaging;
  final FirestoreServices _firestoreServices;
  final FirebaseFunctions _firebaseFunctions;

  CloudMessagingServices(this._firebaseMessaging, this._firestoreServices,
      this._firebaseFunctions) {
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      updateToken(newToken);
    });
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    final fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      updateToken(fcmToken);
    }
  }

  Future<void> updateToken(String token) async {
    try {
      await _firestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayUnion([token])
      });
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('update-token-error');
      }
    }
  }

  Future<void> removeToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _firestoreServices.updateUser({
          'fcmTokens': FieldValue.arrayRemove([token])
        });
        await _firebaseMessaging.deleteToken();
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('delete-token-error');
      }
    }
  }

  Future<void> sendNotification(
      List<String> tokens, String title, String body) async {
    try {
      final HttpsCallable callable =
          _firebaseFunctions.httpsCallable('sendChatNotification');
      await callable.call(<String, dynamic>{
        'tokens': tokens,
        'title': title,
        'body': body,
      }.map((key, value) => MapEntry(key, value)));
    } on FirebaseFunctionsException catch (error) {
      throw AppException(error.code);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('send-notification-error');
      }
    }
  }
}
