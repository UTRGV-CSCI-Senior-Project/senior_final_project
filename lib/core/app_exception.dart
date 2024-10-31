import 'package:folio/constants/error_constants.dart';

class AppException implements Exception{
  final String code;
  final String message;

  AppException(this.code) : message = ErrorConstants.getMessage(code);

  @override
  String toString() {
    return 'AppException: $code - $message';
  }

}