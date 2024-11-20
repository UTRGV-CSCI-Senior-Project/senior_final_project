
class ChatParticipant {
  final String uid;
  final String identifier;
  final String? profilePicture;

  ChatParticipant({
    required this.uid,
    required this.identifier,
     this.profilePicture,
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
    };
  }

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      uid: json['uid'] as String,
      identifier: json['identifier'] as String,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  
}
