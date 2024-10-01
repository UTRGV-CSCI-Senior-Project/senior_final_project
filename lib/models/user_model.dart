class UserModel {
  final String uid;
  final String username;
  final String? fullName;
  final String email;
  final bool isProfessional;

  UserModel(
      {required this.uid,
      required this.username,
      this.fullName,
      required this.email,
      required this.isProfessional}){
    if (uid.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }
    if (username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
    if (email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
  }

  toJson() {
    return {
      "uid": uid,
      "username": username,
      "fullName": fullName,
      "email": email,
      "isProfessional": isProfessional
    };
  }
}
