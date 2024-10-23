
class ErrorConstants {
  static const Map<String, String> errorMessages = {
    'email-already-in-use': 'This email is already associated with another account.',
    'invalid-email': 'The email provided is not a valid email address.',
    'weak-password': 'Password must be at least 8 characters long and include numbers, letters, and special characters.',
    'too-many-requests': 'Too many attempts. Please wait a while before trying again.',
    'network-request-failed': 'Unable to connect to the server. Please check your internet connection and try again.',
    'username-taken': 'This username is already taken. Please try a different one.',
    'unexpected-error': 'An unexpected error occurred. Please try again later or contact support if the problem persists.',
    'empty-fields': 'Please fill in all required fields to continue.',
    'invalid-credential': 'Invalid login credentials. Please check your email and password.',
    'user-disabled': 'This account has been disabled. Please contact support for assistance.',
    'user-not-found': 'No account found with this email address. Please check the email or create a new account.',
    'wrong-password': 'Incorrect password. Please try again or reset your password.',
    'no-user': 'Session expired. Please log in again to continue.',
    
    'pfp-error': 'Unable to upload profile picture.',
    'pfp-upload-error': 'Failed to update profile picture. Please try a different image or try again later.',
    'delete-image-error': 'Unable to delete image. Please try again later.',
    'upload-files-error': 'Failed to upload images. Please try again later.',
    'fetch-images-error': 'Unable to load images. Please check your connection and try again.',
    
    'create-portfolio-error': 'Failed to create your portfolio. Please try again later.',
    'update-portfolio-error': 'Changes to your portfolio could not be saved. Please try again.',
    'delete-portfolio-error': 'Unable to delete portfolio. Please try again later.',
    'invalid-portfolio-data': 'Some portfolio information is invalid. Please review and try again.',
    'portfolio-stream-error': 'Unable to load portfolio updates. Please restart the app.',
    'delete-portfolio-image-error': 'Failed to remove portfolio image. Please try again later.',
    
    'sign-up-error': 'Unable to complete registration. Please try again or contact support.',
    'create-user-error': 'Failed to create account. Please check your information and try again.',
    'sign-in-error': 'Unable to sign in. Please check your credentials and try again.',
    'sign-out-error': 'Unable to sign out. Please try again or restart the app.',
    'update-profile-error': 'Failed to update profile information. Please try again.',
    'delete-user-error': 'Unable to delete account. Please contact support for assistance.',
    'update-user-error': 'Failed to update account information. Please try again later.',
    'add-user-error': 'Unable to add user to the system. Please try again.',
    'invalid-user-data': 'Some of the provided information is invalid. Please review and try again.',
    'user-stream-error': 'Unable to load user updates. Please restart the app.',
    
    'already-verified': 'This email is already verified.',
    'email-verification-error': 'Unable to send verification email. Please try again later.',
    
    'get-services-error': 'Unable to load available services. Please restart the app.',
    'username-unique-error': 'Unable to verify username availability. Please try again.',
  };

  static String getMessage(String errorCode) {
    return errorMessages[errorCode] ?? 'An unexpected error occurred. Please try again later or contact support if the problem persists.';
  }


}