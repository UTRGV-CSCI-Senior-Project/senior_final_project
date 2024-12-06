import 'dart:io';
import 'package:folio/core/app_exception.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';

class PortfolioRepository {
  final FirestoreServices _firestoreServices;
  final StorageServices _storageServices;

  PortfolioRepository(this._firestoreServices, this._storageServices);

  Future<void> createPortfolio(
      String service,
      String details,
      int months,
      int years,
      List<File> images,
      Map<String, String?>? location,
      Map<String, double?>? latAndLong,
      String professionalsName,
      String uid) async {
    try {
      final imageData = await _storageServices.uploadFilesForUser(images);

      final initialDate = DateTime.now();
      final portfolio = PortfolioModel(
          service: service,
          details: details,
          experienceStartDate: initialDate,
          years: years,
          months: months,
          images: imageData,
          location: location,
          latAndLong: latAndLong,
          professionalsName: professionalsName,
          nameArray: professionalsName.split(' '),
          uid: uid);
      await _firestoreServices.savePortfolioDetails(portfolio.toJson());

      await _firestoreServices.addService(service);

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

      if (updateFields.containsKey('years') ||
          updateFields.containsKey('months')) {
        updateFields['experienceStartDate'] = DateTime.now();
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

  Future<void> deletePortfolio() async {
    try {
      final portfolio = await _firestoreServices.getPortfolio();

      if (portfolio == null) {
        throw AppException('no-portfolio');
      }

      for (var image in portfolio.images) {
        await deletePortfolioImage(
            image['filePath']!, // Access the filePath from the map
            image['downloadUrl']! // Access the downloadUrl from the map
            );
      }
      await _firestoreServices.deletePortfolio();

      await _firestoreServices.updateUser({'isProfessional': false});
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('delete-portfolio-error');
      }
    }
  }

  Future<List<PortfolioModel>> getNearbyPortfolios(
      double lat, double long) async {
    try {
      return await _firestoreServices.getNearbyPortfolios(lat, long);
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-nearby-portfolios-error');
      }
    }
  }

  Future<List<PortfolioModel>> getDiscoverPortfolios(List<String> searchQuery) async {
    try{
      return await _firestoreServices.discoverPortfolios(searchQuery);
    } catch (e) {
      if (e is AppException){
        rethrow;
      }else{
        throw AppException('get-discover-portfolios-error');
      }
    }
  }
}
