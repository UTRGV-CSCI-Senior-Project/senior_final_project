class UserModel {
  final String _uid;
  final String _username;
  final String? _fullName;
  final String _email;
  final bool _isProfessional;
  final bool _completedOnboarding;

  UserModel(
      {required String uid,
      required String username,
      String? fullName,
      required String email,
      required bool isProfessional,
      bool completedOnboarding = false
      
      })
      : _uid = uid,
        _username = username,
        _fullName = fullName,
        _email = email,
        _isProfessional = isProfessional,
        _completedOnboarding = completedOnboarding
         {
    if (_uid.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }
    if (_username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
    if (_email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
  }

  String get uid => _uid;
  String get username => _username;
  String? get fullName => _fullName;
  String get email => _email;
  bool get isProfessional => _isProfessional;
  bool get completedOnboarding => _completedOnboarding;

  toJson() {
    return {
      "uid": uid,
      "username": username,
      "fullName": fullName,
      "email": email,
      "isProfessional": isProfessional,
      "completedOnboarding": completedOnboarding
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('uid')) {
      throw ArgumentError('empty-uid');
    }
    if (!json.containsKey('username')) {
      throw ArgumentError('empty-username');
    }
    if (!json.containsKey('email')) {
      throw ArgumentError('empty-email');
    }
    if (!json.containsKey('isProfessional')) {
      throw ArgumentError('empty-isProfessional');
    }

    return UserModel(
        uid: json['uid'] as String,
        username: json['username'] as String,
        fullName: json['fullName'] as String?,
        email: json['email'] as String,
        isProfessional: json['isProfessional'] as bool,
        completedOnboarding: json['completedOnboarding'] ?? false
        );
  }
}
