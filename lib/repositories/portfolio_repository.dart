import 'dart:io';
import 'package:folio/core/app_exception.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';
import 'package:social_share/social_share.dart';

class PortfolioRepository {
  final FirestoreServices _firestoreServices;
  final StorageServices _storageServices;

  PortfolioRepository(this._firestoreServices, this._storageServices);

  Future<void> createPortfolio(String service, String details, int months,
      int years, List<File> images) async {
    try {
      final imageData = await _storageServices.uploadFilesForUser(images);

      await _firestoreServices.savePortfolioDetails({
        'service': service,
        'details': details,
        'years': years,
        'months': months,
        'images': imageData
      });

      await _firestoreServices.updateUser({'isProfessional': true});
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('create-portfolio-error');
      }
    }
  }

  Future<void> updatePortfolio(
      {List<File>? images, Map<String, dynamic>? fields}) async {
    try {
      Map<String, dynamic> updateFields = fields ?? {};

      if (images != null && images.isNotEmpty) {
        final imageData = await _storageServices.uploadFilesForUser(images);
        updateFields['images'] = imageData;
      }

      await _firestoreServices.savePortfolioDetails(updateFields);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('update-portfolio-error');
      }
    }
  }

  Future<void> deletePortfolioImage(String filePath, String downloadUrl) async {
    try {
      await _firestoreServices.deletePortfolioImage(filePath, downloadUrl);

      await _storageServices.deleteImage(filePath);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('delete-image-error');
      }
    }
  }

  void shareMessageOnFacebook() {
    const String message =
        "Hello everyone! \nI invite you to check out my profile on the Folio App, \nwhere I showcase my car detailing services. You'll find a variety of photos \nthat highlight the quality of my work. The Folio App is available for download on both the App Store and Google Play Store.";
    SocialShare.shareOptions(message).then((result) {
      print(result);
    }).catchError((error) {
      print("Error sharing: $error");
    });
  }
}
