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
      required this.isProfessional});

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
