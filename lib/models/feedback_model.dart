class FeedbackModel{
  final String _id;
  final String _subject;
  final String _message;
  final String _type; // 'bug' or 'feedback'
  final String _deviceInfo;
  final String _appVersion;
  final DateTime _createdAt;
  final String _userId;

  FeedbackModel({
    required String id,
    required String subject,
    required String message,
    required String type,
    required String deviceInfo,
    required String appVersion,
    required DateTime createdAt,
    required String userId,
  }) : _id = id,
      _subject = subject,
      _message = message,
      _type = type,
      _deviceInfo = deviceInfo,
      _appVersion = appVersion,
      _createdAt = createdAt,
      _userId = userId{
        if(id.isEmpty){
          throw ArgumentError('id cannot be empty');
        }
        if(subject.isEmpty){
          throw ArgumentError('subject cannot be empty');
        }
        if(message.isEmpty){
          throw ArgumentError('message cannot be empty');
        }
        if(type.isEmpty || (type != 'bug' && type != 'help')){
          throw ArgumentError('type must be either "bug" or "help"');
        }
        if(deviceInfo.isEmpty){
          throw ArgumentError('deviceInfo cannot be empty');
        }
        if(appVersion.isEmpty){
          throw ArgumentError('appVersion cannot be empty');
        }
        if(userId.isEmpty){
          throw ArgumentError('userId cannot be empty');
        }
      }

    String get id => _id;
        String get subject => _subject;
    String get message => _message;
    String get type => _type;
    String get deviceInfo => _deviceInfo;
    String get appVersion => _appVersion;
    DateTime get createdAt => _createdAt;
    String get userId => _userId;



   Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'subject': _subject,
      'message': _message,
      'type': _type,
      'deviceInfo': _deviceInfo,
      'appVersion': _appVersion,
      'createdAt': _createdAt,
      'userId': _userId,
    };
  }
}