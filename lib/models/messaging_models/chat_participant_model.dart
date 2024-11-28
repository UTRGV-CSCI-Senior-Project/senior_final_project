
import 'package:folio/models/user_model.dart';

class ChatParticipant {
  final String uid;
  final String identifier;
  final String? profilePicture;
  final List<String>? fcmTokens;

  ChatParticipant({
    required this.uid,
    required this.identifier,
     this.profilePicture,
     this.fcmTokens
  }){
    if(uid.isEmpty){
      throw ArgumentError('uid cannot be empty');
    }
    if(identifier.isEmpty){
      throw ArgumentError('identifier cannot be empty');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'identifier': identifier,
      'profilePicture': profilePicture,
      'fcmTokens': fcmTokens
    };
  }

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {

     List<String>? tokensList;
    if (json['fcmTokens'] != null) {
      tokensList = (json['fcmTokens'] as List).map((e) => e.toString()).toList();
    }

    return ChatParticipant(
      uid: json['uid'] as String,
      identifier: json['identifier'] as String,
      profilePicture: json['profilePicture'] as String?,
      fcmTokens: tokensList
    );
  }

  factory ChatParticipant.fromUserModel(UserModel user){
    return ChatParticipant(uid: user.uid, identifier: user.fullName ?? user.username, profilePicture: user.profilePictureUrl, fcmTokens: user.fcmTokens);
  }

  
}
