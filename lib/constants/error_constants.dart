class ErrorConstants {
  static const Map<String, String> errorMessages = {
    'email-already-in-use': 'This email is already associated with another account.',
    'invalid-email': 'The email provided is not a valid email address.',
    'weak-password': 'The password provided is too weak.',
    'too-many-requests':'Too many requests. Please try again later.',
    'network-request-failed': 'A network error ocurred. Please check your connection and try again.',
    'username-taken': 'This username is already taken. Please try another one.',
    'unexpected-error': 'An unknown error ocurred. Please try again later.',
    'empty-fields': 'Please fill in all of the fields.',
    'invalid-credential': 'Your email address or password is incorrect.',
    'user-disabled': 'The account for the provided email has been disabled.',
    'user-not-found': 'There is no user corresponding to the email provided.',
    'wrong-password': 'Your email address or password is incorrect.',
    'no-user': 'Account not found, try logging in again.',
    'pfp-error': 'Error uploading your image, try again later.',  
  };

  static String getMessage(String errorCode){
    return errorMessages[errorCode] ?? 'An unknown error ocurred. Please try again later.';
  }
}