import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/services/cloud_messaging_services.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../mocks/cloud_messaging_services_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

@GenerateMocks(
    [FirebaseFunctions, FirebaseMessaging, HttpsCallable, HttpsCallableResult])
void main() {
  late MockFirebaseFunctions mockFirebaseFunctions;
  late MockFirebaseMessaging mockFirebaseMessaging;
  late MockFirestoreServices mockFirestoreServices;
  late CloudMessagingServices cloudMessagingServices;
  late Stream<String> mockTokenRefreshStream;
  late MockHttpsCallable mockHttpsCallable;

  setUp(() {
    mockFirebaseMessaging = MockFirebaseMessaging();
    mockFirebaseFunctions = MockFirebaseFunctions();
    mockFirestoreServices = MockFirestoreServices();
    mockTokenRefreshStream = Stream.value('token?');
    mockHttpsCallable = MockHttpsCallable();

    when(mockFirebaseMessaging.onTokenRefresh)
        .thenAnswer((_) => mockTokenRefreshStream);

    cloudMessagingServices = CloudMessagingServices(
        mockFirebaseMessaging, mockFirestoreServices, mockFirebaseFunctions);
  });

  group('initNotifications', () {
    const testToken = 'test-fcm-token';
    test('should request notification permissions and update token', () async {
      when(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).thenAnswer((_) async => const NotificationSettings(
            alert: AppleNotificationSetting.enabled,
            announcement: AppleNotificationSetting.disabled,
            authorizationStatus: AuthorizationStatus.authorized,
            badge: AppleNotificationSetting.enabled,
            carPlay: AppleNotificationSetting.disabled,
            lockScreen: AppleNotificationSetting.disabled,
            notificationCenter: AppleNotificationSetting.disabled,
            showPreviews: AppleShowPreviewSetting.never,
            timeSensitive: AppleNotificationSetting.disabled,
            criticalAlert: AppleNotificationSetting.disabled,
            sound: AppleNotificationSetting.enabled,
          ));

      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => testToken);

      when(mockFirestoreServices.updateUser(any)).thenAnswer((_) async {});

      await cloudMessagingServices.initNotifications();

      verify(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).called(1);

      verify(mockFirebaseMessaging.getToken()).called(1);

      verify(mockFirestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayUnion([testToken])
      })).called(1);
    });

    test('should not update token if permission is denied', () async {
      when(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).thenAnswer((_) async => const NotificationSettings(
          authorizationStatus: AuthorizationStatus.denied,
          alert: AppleNotificationSetting.disabled,
          announcement: AppleNotificationSetting.disabled,
          badge: AppleNotificationSetting.disabled,
          carPlay: AppleNotificationSetting.disabled,
          lockScreen: AppleNotificationSetting.disabled,
          notificationCenter: AppleNotificationSetting.disabled,
          showPreviews: AppleShowPreviewSetting.never,
          timeSensitive: AppleNotificationSetting.disabled,
          criticalAlert: AppleNotificationSetting.disabled,
          sound: AppleNotificationSetting.disabled));

      await cloudMessagingServices.initNotifications();

      verify(mockFirebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      )).called(1);

      verifyNever(mockFirebaseMessaging.getToken());

      verifyNever(mockFirestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayUnion([testToken])
      }));
    });
    test('should update token when token is refreshed', () async {
      when(mockFirestoreServices.updateUser(any)).thenAnswer((_) async {});

      // Simulate token refresh stream
      final tokenRefreshController = StreamController<String>();
      when(mockFirebaseMessaging.onTokenRefresh)
          .thenAnswer((_) => tokenRefreshController.stream);

      // Recreate the service to trigger the token refresh listener
      cloudMessagingServices = CloudMessagingServices(
          mockFirebaseMessaging, mockFirestoreServices, mockFirebaseFunctions);

      // Add token to stream, like if token was refreshed
      tokenRefreshController.add(testToken);

      // Allow some time for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      // Make sure token was updated
      verify(mockFirestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayUnion([testToken])
      })).called(1);

      // Clean up
      await tokenRefreshController.close();
    });
  });

  group('updateToken', () {
    const testToken = 'test-fcm-token';

    test('should update user token in Firestore', () async {
      when(mockFirestoreServices.updateUser(any)).thenAnswer((_) async {});

      await cloudMessagingServices.updateToken(testToken);

      verify(mockFirestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayUnion([testToken])
      })).called(1);
    });

    test('should rethrow AppException', () async {
      final testException = AppException('update-user-error');
      when(mockFirestoreServices.updateUser(any)).thenThrow(testException);

      expect(
          () => cloudMessagingServices.updateToken(testToken),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'code', 'update-user-error')));
    });

    test('should throw generic AppException for other errors', () async {
      when(mockFirestoreServices.updateUser(any))
          .thenThrow(Exception('unexpected error'));

      expect(
          () => cloudMessagingServices.updateToken(testToken),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'error code', 'update-token-error')));
    });
  });

  group('removeToken', () {
    const testToken = 'test-fcm-token';
    test('should remove token from Firestore and delete FCM token', () async {
      when(mockFirebaseMessaging.getToken()).thenAnswer((_) async => testToken);

      when(mockFirestoreServices.updateUser(any)).thenAnswer((_) async {});

      when(mockFirebaseMessaging.deleteToken()).thenAnswer((_) async {});

      await cloudMessagingServices.removeToken();

      verify(mockFirebaseMessaging.getToken()).called(1);
      verify(mockFirestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayRemove([testToken])
      })).called(1);
      verify(mockFirebaseMessaging.deleteToken()).called(1);
    });

    test('should handle null token gracefully', () async {
      when(mockFirebaseMessaging.getToken())
          .thenAnswer((_) => Future.value(null));

      await cloudMessagingServices.removeToken();

      verify(mockFirebaseMessaging.getToken()).called(1);
      verifyNever(mockFirestoreServices.updateUser({
        'fcmTokens': FieldValue.arrayRemove([null])
      }));
      verifyNever(mockFirebaseMessaging.deleteToken());
    });
  });

  group('sendNotifications', () {
    test('should send notification via Firebase Functions', () async {
      final testTokens = ['token1', 'token2'];
      const testTitle = 'Test Title';
      const testBody = 'Test Body';

      when(mockFirebaseFunctions.httpsCallable('sendChatNotification'))
          .thenReturn(mockHttpsCallable);
      final mockCallableResult = MockHttpsCallableResult<dynamic>();

      when(mockHttpsCallable.call(any))
          .thenAnswer((_) async => mockCallableResult);

      await cloudMessagingServices.sendNotification(
          testTokens, testTitle, testBody);

      verify(mockFirebaseFunctions.httpsCallable('sendChatNotification'))
          .called(1);
      verify(mockHttpsCallable.call({
        'tokens': testTokens,
        'title': testTitle,
        'body': testBody,
      })).called(1);
    });

    test('should handle FirebaseFunctionsException', () async {
      final testTokens = ['token1', 'token2'];
      const testTitle = 'Test Title';
      const testBody = 'Test Body';

      final functionsException = FirebaseFunctionsException(
          code: 'test-error-code', message: 'Test error', details: null);

      when(mockFirebaseFunctions.httpsCallable('sendChatNotification'))
          .thenReturn(mockHttpsCallable);

      when(mockHttpsCallable.call(any)).thenThrow(functionsException);

      expect(
          () => cloudMessagingServices.sendNotification(
              testTokens, testTitle, testBody),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'error code', 'test-error-code')));
    });

    test('should throw generic AppException for other errors', () async {
      final testTokens = ['token1', 'token2'];
      const testTitle = 'Test Title';
      const testBody = 'Test Body';

      when(mockFirebaseFunctions.httpsCallable('sendChatNotification'))
          .thenReturn(mockHttpsCallable);

      when(mockHttpsCallable.call(any))
          .thenThrow(Exception('unexpected error'));

      expect(
          () => cloudMessagingServices.sendNotification(
              testTokens, testTitle, testBody),
          throwsA(isA<AppException>()
              .having((e) => e.code, 'error code', 'send-notification-error')));
    });
  });
}
