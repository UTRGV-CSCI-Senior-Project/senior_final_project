import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/models/feedback_model.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FeedbackRepository {
  final FirestoreServices _firestoreServices;
  final DeviceInfoPlugin _deviceInfoPlugin;

  FeedbackRepository(this._firestoreServices, [DeviceInfoPlugin? deviceInfoPlugin]) : _deviceInfoPlugin = deviceInfoPlugin ?? DeviceInfoPlugin();

  Future<void> sendFeedback(String subject, String message, String type, String userId) async {
    try{
      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = packageInfo.version;

      
      String deviceInfoString = '';

      if(defaultTargetPlatform == TargetPlatform.android){
        final androidInfo = await _deviceInfoPlugin.androidInfo;
        deviceInfoString = '${androidInfo.manufacturer} ${androidInfo.model} (Android ${androidInfo.version.release})';

      }else if (defaultTargetPlatform == TargetPlatform.iOS){
        final iosInfo = await _deviceInfoPlugin.iosInfo;
        deviceInfoString = '${iosInfo.model} (iOS ${iosInfo.systemVersion})';

      }else{
        deviceInfoString = 'Unkown device';
      }

      final feedback = FeedbackModel(id: DateTime.now().millisecondsSinceEpoch.toString(), subject: subject, message: message, type: type, deviceInfo: deviceInfoString, appVersion: appVersion, createdAt: DateTime.now(), userId: userId);

      await _firestoreServices.addFeedback(feedback);

    }catch(e){
      if(e is AppException){
        rethrow;
      }else{
        throw AppException('send-feedback-error');
      }
    }
  }



}