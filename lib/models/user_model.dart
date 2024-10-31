class UserModel {
  final String _uid;
  final String _username;
  final String? _fullName;
  final String _email;
  final bool _isProfessional;
  final bool _completedOnboarding;
  final List<String> _preferredServices;
  final String? _profilePictureUrl;
  String _city;
  double? _lati;
  double? _long;

  UserModel({
    required String uid,
    required String username,
    String? fullName,
    required String email,
    required bool isProfessional,
    bool completedOnboarding = false,
    List<String> preferredServices = const [],
    String? profilePictureUrl,
    required String city,
    double? lati,
    double? long,
  })  : _uid = uid,
        _username = username,
        _fullName = fullName,
        _email = email,
        _isProfessional = isProfessional,
        _completedOnboarding = completedOnboarding,
        _preferredServices = preferredServices,
        _profilePictureUrl = profilePictureUrl,
        _city = city,
        _lati = lati,
        _long = long {
    if (_uid.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }
    if (_username.isEmpty) {
      throw ArgumentError('Username cannot be empty');
    }
    if (_email.isEmpty) {
      throw ArgumentError('Email cannot be empty');
    }
    if (_city.isEmpty) {
      throw ArgumentError('You must choose a city');
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
  String get city => _city;
  double? get lati => _lati;
  double? get long => _long;

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
      "city": city,
      "latitude": lati,
      "longitude": long,
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
        city:json['city'] as String,
        lati: json["latitude"] as double?,
        long: json["longitude"] as double?,
        );
  }
}
