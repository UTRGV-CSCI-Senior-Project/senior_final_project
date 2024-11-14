import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/models/feedback_model.dart';
import 'package:folio/repositories/feedback_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../mocks/feedback_repository_test.mocks.dart';
import '../../mocks/user_repository_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FeedbackRepository feedbackRepository;
  late MockFirestoreServices mockFirestoreServices;
  late MockDeviceInfoPlugin mockDeviceInfoPlugin;
  late MockAndroidDeviceInfo mockAndroidDeviceInfo;
  late MockAndroidBuildVersion mockAndroidBuildVersion;

  setUp(() {
    mockFirestoreServices = MockFirestoreServices();
    mockDeviceInfoPlugin = MockDeviceInfoPlugin();
    mockAndroidDeviceInfo = MockAndroidDeviceInfo();
    mockAndroidBuildVersion = MockAndroidBuildVersion();
    feedbackRepository =
        FeedbackRepository(mockFirestoreServices, mockDeviceInfoPlugin);
  });

  group('sendFeedback', () {
    const testSubject = 'Test Subject';
    const testMessage = 'Test Message';
    const testType = 'bug';
    const testUserId = 'user123';

    test('successfully sends Android feedback', () async {
      // Mock PackageInfo
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      // Mock Android device info
      when(mockDeviceInfoPlugin.androidInfo)
          .thenAnswer((_) async => mockAndroidDeviceInfo);
      when(mockAndroidDeviceInfo.manufacturer).thenReturn('Samsung');
      when(mockAndroidDeviceInfo.model).thenReturn('Galaxy S21');
      when(mockAndroidDeviceInfo.version).thenReturn(mockAndroidBuildVersion);
      when(mockAndroidBuildVersion.release).thenReturn('12.0');

      // Set platform to Android for test
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      // Mock successful Firestore operation
      when(mockFirestoreServices.addFeedback(any)).thenAnswer((_) async {});

      await feedbackRepository.sendFeedback(
        testSubject,
        testMessage,
        testType,
        testUserId,
      );

      verify(mockFirestoreServices.addFeedback(any)).called(1);

      // Reset platform override
      debugDefaultTargetPlatformOverride = null;
    });

    test('successfully sends iOS feedback', () async {
      // Mock PackageInfo
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      // Mock iOS device info
      final iosInfo = IosDeviceInfo.fromMap({
        'name': 'iPhone',
        'systemName': 'iOS',
        'systemVersion': '15.0',
        'model': 'iPhone 13',
        'localizedModel': 'iPhone',
        'identifierForVendor': 'test',
        'isPhysicalDevice': true,
        'utsname': {
          'sysname': '',
          'nodename': '',
          'release': '',
          'version': '',
          'machine': '',
        },
      });
      when(mockDeviceInfoPlugin.iosInfo).thenAnswer((_) async => iosInfo);

      // Set platform to iOS for test
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      // Mock successful Firestore operation
      when(mockFirestoreServices.addFeedback(any)).thenAnswer((_) async {});

      await feedbackRepository.sendFeedback(
        testSubject,
        testMessage,
        testType,
        testUserId,
      );

      verify(mockFirestoreServices.addFeedback(any)).called(1);

      // Reset platform override
      debugDefaultTargetPlatformOverride = null;
    });

    test('handles Firestore error correctly', () async {
      // Mock PackageInfo
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      // Mock Firestore error
      when(mockFirestoreServices.addFeedback(any))
          .thenThrow(AppException('test-error'));

      expect(
        () => feedbackRepository.sendFeedback(
          testSubject,
          testMessage,
          testType,
          testUserId,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('handles unknown platform correctly', () async {
      // Mock PackageInfo
      PackageInfo.setMockInitialValues(
        appName: 'Test App',
        packageName: 'com.test.app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );

      // Set platform to Linux for test
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      // Mock successful Firestore operation
      when(mockFirestoreServices.addFeedback(any)).thenAnswer((_) async {});

      await feedbackRepository.sendFeedback(
        testSubject,
        testMessage,
        testType,
        testUserId,
      );

      verify(mockFirestoreServices.addFeedback(argThat(
        predicate<FeedbackModel>(
          (feedback) => feedback.deviceInfo == 'Unkown device',
        ),
      ))).called(1);

      // Reset platform override
      debugDefaultTargetPlatformOverride = null;
    });
  });
}
