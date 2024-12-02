class UserModel {
  final String _uid;
  final String _username;
  final String? _fullName;
  final String _email;
  final bool _isProfessional;
  final bool _completedOnboarding;
  final List<String> _preferredServices;
  final String? _profilePictureUrl;
  final bool _isEmailVerified;
  final String? _phoneNumber;
  final bool _isPhoneVerified;
  final List<String>? _fcmTokens;
  double? _latitude;
  double? _longitude;

  UserModel(
      {required String uid,
      required String username,
      String? fullName,
      required String email,
      required bool isProfessional,
      bool completedOnboarding = false,
      List<String> preferredServices = const [],
      String? profilePictureUrl,
    double? latitude,
    double? longitude,
    List<String>? fcmTokens,
      bool isEmailVerified = false,
      String? phoneNumber,
      bool isPhoneVerified = false})
      : _uid = uid,
        _username = username,
        _fullName = fullName,
        _email = email,
        _isProfessional = isProfessional,
        _completedOnboarding = completedOnboarding,
        _preferredServices = preferredServices,
        _profilePictureUrl = profilePictureUrl,
        _latitude = latitude,
        _longitude = longitude,
        _fcmTokens = fcmTokens,
        _isEmailVerified = isEmailVerified,
        _phoneNumber = phoneNumber,
        _isPhoneVerified = isPhoneVerified {
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
  List<String> get preferredServices => _preferredServices;
  String? get profilePictureUrl => _profilePictureUrl;
  bool get isEmailVerified => _isEmailVerified;
  String? get phoneNumber => _phoneNumber;
  bool get isPhoneVerified => _isPhoneVerified;
  List<String>? get fcmTokens => _fcmTokens;  double? get latitude => _latitude;
  double? get longitude => _longitude;

  toJson() {
    return {
      "uid": uid,
      "username": username,
      "fullName": fullName,
      "email": email,
      "isProfessional": isProfessional,
      "completedOnboarding": completedOnboarding,
      "preferredServices": preferredServices,
      "profilePictureUrl": profilePictureUrl,
      "isEmailVerified": isEmailVerified,
      "isPhoneVerified": isPhoneVerified,
      "phoneNumber": phoneNumber,
      "fcmTokens": fcmTokens
      "latitude": latitude,
      "longitude": longitude,
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
      completedOnboarding: json['completedOnboarding'] ?? false,
      preferredServices: (json['preferredServices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      profilePictureUrl: json['profilePictureUrl'] as String?,
      latitude: json["latitude"] as double?,
      longitude: json["longitude"] as double?,
    ,
        isEmailVerified: json['isEmailVerified'] ?? false,
        phoneNumber: json['phoneNumber'] as String?,
        isPhoneVerified: json['isPhoneVerified'] ?? false,
        fcmTokens: (json['fcmTokens'] as List?)?.map((e) => e.toString()).toList()
        );
      
  }
}
