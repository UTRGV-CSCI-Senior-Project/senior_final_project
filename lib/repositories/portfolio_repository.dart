import 'dart:io';
import 'package:folio/services/firestore_services.dart';
import 'package:folio/services/storage_services.dart';

class PortfolioRepository {
  final FirestoreServices _firestoreServices;
  final StorageServices _storageServices;

  PortfolioRepository(this._firestoreServices, this._storageServices);


  Future<void> createPortfolio(String service, String details, int months, int years, List<File> images) async {
    try{

      final imageData = await _storageServices.uploadFilesForUser(images);

     await _firestoreServices.savePortfolioDetails({
        'service': service,
        'details': details,
        'years': years,
        'months': months,
        'images': imageData
      });

      await _firestoreServices.updateUser({'isProfessional': true});

    }catch (e){
      throw 'unexpected-error';
    }
  }

  Future<void> updatePortfolio({List<File>? images, Map<String, dynamic>? fields}) async {
    try{

      Map<String, dynamic> updateFields = fields ?? {};

      if(images != null && images.isNotEmpty){
        final imageData = await _storageServices.uploadFilesForUser(images);
        updateFields['images'] = imageData;
      }

      await _firestoreServices.savePortfolioDetails(updateFields);


    }catch (e)
    {
      throw 'unexpected-error';
    }
  }

  Future<void> deletePortfolioImage(String filePath, String downloadUrl) async {
    try{ 
      await _firestoreServices.deletePortfolioImage(filePath, downloadUrl);

      await _storageServices.deleteImage(filePath);

    }catch (e){
      throw 'delete-failed';
    }
  }



}