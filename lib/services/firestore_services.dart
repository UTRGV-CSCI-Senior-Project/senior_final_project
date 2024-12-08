import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/messaging_models/chat_participant_model.dart';
import 'package:folio/models/messaging_models/chatroom_model.dart';
import 'package:folio/models/feedback_model.dart';
import 'package:folio/models/messaging_models/message_model.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';

class FirestoreServices {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  FirestoreServices(this._firestore, this._ref);

  ///////////////////////// USER COLLECTION /////////////////////////

  Future<void> addUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toJson());
    } catch (e) {
      throw AppException('add-user-error');
    }
  }

  Future<UserModel?> getUser() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      try {
        return UserModel.fromJson(userDoc.data()!);
      } catch (e) {
        throw AppException('invalid-user-data');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-user-error');
      }
    }
  }

  Future<UserModel?> getOtherUser(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        return null;
      }

      try {
        return UserModel.fromJson(userDoc.data()!);
      } catch (e) {
        throw AppException('invalid-user-data');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-user-error');
      }
    }
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        throw AppException('no-user-doc');
      }
      try {
        return UserModel.fromJson(snapshot.data()!);
      } catch (e) {
        throw AppException('invalid-user-data');
      }
    }).handleError((error) {
      if (error is AppException) {
        throw error;
      } else {
        throw AppException('user-stream-error');
      }
    });
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw AppException('username-unique-error');
    }
  }

  Future<void> updateUser(Map<String, dynamic> fieldsToUpdate) async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();
      await _firestore.collection('users').doc(uid).update(fieldsToUpdate);
      await updateChatroomParticipant();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('update-user-error');
      }
    }
  }

  Future<void> deleteUser() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }
      final documentRef = _firestore.collection('users').doc(uid);

      await documentRef.update({
        'completedOnboarding': FieldValue.delete(),
        'email': FieldValue.delete(),
        'fullName': FieldValue.delete(),
        'isProfessional': FieldValue.delete(),
        'preferredServices': FieldValue.delete(),
        'profilePictureUrl': FieldValue.delete(),
        'uid': FieldValue.delete(),
        'username': FieldValue.delete(),
        'isEmailVerified': FieldValue.delete(),
        'isPhoneVerified': FieldValue.delete(),
        'phoneNumber': FieldValue.delete(),
        'fcmTokens': FieldValue.delete(),
        'latitude': FieldValue.delete(),
        'longitude': FieldValue.delete(),
      });
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('delete-user-error');
      }
    }
  }

  ///////////////////////// PORTFOLIO COLLECTION /////////////////////////

  Future<PortfolioModel?> getPortfolio() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final portfolioDoc =
          await _firestore.collection('portfolios').doc(uid).get();

      if (!portfolioDoc.exists) {
        return null;
      }

      try {
        final data = portfolioDoc.data()!;
        data['uid'] ??= portfolioDoc.id;
        return PortfolioModel.fromJson(data);
      } catch (e) {
        throw AppException('invalid-portfolio-data');
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-portfolio-error');
      }
    }
  }

  Stream<PortfolioModel?> getPortfolioStream(String uid) {
    return _firestore
        .collection('portfolios')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      try {
        final data = snapshot.data()!;
        data['uid'] ??= snapshot.id;
        return PortfolioModel.fromJson(data);
      } catch (e) {
        throw AppException('invalid-portfolio-data');
      }
    }).handleError((error) {
      if (error is AppException && error.code == 'invalid-portfolio-data') {
        throw error;
      } else {
        throw AppException('portfolio-stream-error');
      }
    });
  }

  Future<void> savePortfolioDetails(Map<String, dynamic> fieldsToUpdate) async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final portfolioRef = _firestore.collection('portfolios').doc(uid);
      final portoflioDoc = await portfolioRef.get();

      if (portoflioDoc.exists) {
        if (fieldsToUpdate.containsKey('images')) {
          fieldsToUpdate['images'] =
              FieldValue.arrayUnion(fieldsToUpdate['images']);
        }
        await portfolioRef.update(fieldsToUpdate);
      } else {
        await portfolioRef.set(fieldsToUpdate);
      }
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('update-portfolio-error');
      }
    }
  }

  Future<void> deletePortfolioImage(String filePath, String downloadUrl) async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final portfolioRef = _firestore.collection('portfolios').doc(uid);

      await portfolioRef.update({
        'images': FieldValue.arrayRemove([
          {
            'filePath': filePath,
            'downloadUrl': downloadUrl,
          }
        ])
      });
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('delete-portfolio-image-error');
      }
    }
  }

  Future<void> deletePortfolio() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      await _firestore.collection('portfolios').doc(uid).delete();
    } catch (e) {
      if (e is AppException && e.code == "no-user") {
        rethrow;
      } else {
        throw AppException('delete-portfolio-error');
      }
    }
  }

  Map<String, double> getBounds(
      double centerLat, double centerLong, double radiusKm) {
    const earthRadius = 6371.0;

    double latDelta = (radiusKm / earthRadius) * (180 / pi);
    double longDelta =
        (radiusKm / (earthRadius * cos(centerLat * pi / 180))) * (180 / pi);

    return {
      'minLat': centerLat - latDelta,
      'maxLat': centerLat + latDelta,
      'minLong': centerLong - longDelta,
      'maxLong': centerLong + longDelta
    };
  }

  Future<List<PortfolioModel>> getNearbyPortfolios(
      double lat, double lng) async {
    try {
      final bounds = getBounds(lat, lng, 32.1869);
      final query = _firestore
          .collection("portfolios")
          .where('latAndLong.longitude',
              isGreaterThanOrEqualTo: bounds['minLong'])
          .where('latAndLong.longitude', isLessThanOrEqualTo: bounds['maxLong'])
          .where('latAndLong.latitude',
              isGreaterThanOrEqualTo: bounds['minLat'])
          .where('latAndLong.latitude', isLessThanOrEqualTo: bounds['maxLat']);
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] ??= doc.id;
        return PortfolioModel.fromJson(data);
      }).toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-portfolios-error');
      }
    }
  }

  Future<List<PortfolioModel>> getAllPortfolios() async {
    try {
      final query = _firestore
          .collection("portfolios");
         
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] ??= doc.id;
        return PortfolioModel.fromJson(data);
      }).toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-portfolios-error');
      }
    }
  }

  Future<List<PortfolioModel>> discoverPortfolios(
      List<String> searchQuery) async {
    try {
      if (searchQuery.isEmpty) {
        return [];
      }

      // Run two queries: one for professionalsName and one for service
      final nameQuery = _firestore
          .collection('portfolios')
          .where('nameArray', arrayContainsAny: searchQuery)
          .get();

      final serviceQuery = _firestore
          .collection('portfolios')
          .where('service', whereIn: searchQuery)
          .get();

      // Wait for both queries to complete
      final results = await Future.wait([nameQuery, serviceQuery]);

      final nameResults = results[0].docs.map((doc) {
        final data = doc.data();
        // If uid is missing, add it from doc.id
        if (data['uid'] == null) {
          data['uid'] = doc.id;
        }
        return PortfolioModel.fromJson(data);
      }).toList();

      final serviceResults = results[1].docs.map((doc) {
        final data = doc.data();
        // If uid is missing, add it from doc.id
        if (data['uid'] == null) {
          data['uid'] = doc.id;
        }
        return PortfolioModel.fromJson(data);
      }).toList();

      // Merge results and remove duplicates based on a unique identifier
      final allResults = [
        ...nameResults,
        ...serviceResults,
      ];

      final uniqueResults = allResults.fold<Map<String, PortfolioModel>>(
        {},
        (map, result) {
          map[result.uid] = result;
          return map;
        },
      );
      return uniqueResults.values.toList();
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('discover-portfolios-error');
      }
    }
  }
  ///////////////////////// SERVICE COLLECTION /////////////////////////

  Future<List<String>> getServices() async {
    try {
      final QuerySnapshot servicesSnapshot =
          await _firestore.collection('services').get();

      List<String> servicesList = servicesSnapshot.docs
          .map((doc) => doc.get('service') as String)
          .toList();
      return servicesList;
    } catch (e) {
      throw AppException('get-services-error');
    }
  }

  Stream<List<String>> getServicesStream() {
    try {
    return _firestore
        .collection('services')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.get('service') as String)
            .toList());
  } catch (e) {
    throw AppException('get-services-stream-error');
  }
  }

  Future<void> addService(String service) async {
    try {
      final serviceRef = _firestore.collection('services').doc(service);
      final serviceDoc = await serviceRef.get();

      if (serviceDoc.exists) {
        return;
      } else {
        await serviceRef.set({
          'service': service,
        });
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('add-service-error');
      }
    }
  }

  ///////////////////////// FEEDBACK COLLECTION /////////////////////////

  Future<void> addFeedback(FeedbackModel feedbackModel) async {
    try {
      await _firestore
          .collection('feedback')
          .doc(feedbackModel.id)
          .set(feedbackModel.toJson());
    } catch (e) {
      throw AppException('add-feedback-error');
    }
  }

  ///////////////////////// FEEDBACK COLLECTION /////////////////////////

  ///////////////////////// MESSAGE COLLECTION /////////////////////////

  Future<List<ChatParticipant>> getChatParticipants(String chatroomId) async {
    try {
      final userOne = await getUser();
      if (userOne != null) {
        final userIds = chatroomId.split('_');
        final otherUserId =
            userIds.first == userOne.uid ? userIds.last : userIds.first;
        final userTwo = await getOtherUser(otherUserId);

        if (userTwo != null) {
          final participantOne = ChatParticipant.fromUserModel(userOne);
          final participantTwo = ChatParticipant.fromUserModel(userTwo);
          return [participantOne, participantTwo];
        } else {
          throw AppException('no-chat-participant');
        }
      }
      return [];
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('get-chat-participant-error');
      }
    }
  }

  Future<void> sendMessage(MessageModel messageModel, String chatroom) async {
    try {
      DocumentReference chatroomDoc =
          _firestore.collection('chatrooms').doc(chatroom);

      DocumentSnapshot docSnapshot = await chatroomDoc.get();

      if (!docSnapshot.exists) {
        final participants = await getChatParticipants(chatroom);

        if (participants.isNotEmpty) {
          chatroomDoc.set({
            'id': chatroom,
            'participants': [
              participants[0].toJson(),
              participants[1].toJson()
            ],
            'participantIds': [participants[0].uid, participants[1].uid],
            'lastMessage': messageModel.toJson()
          });
        }
      }

      await _firestore
          .collection('chatrooms')
          .doc(chatroom)
          .collection('messages')
          .add(messageModel.toJson());

      await _firestore
          .collection('chatrooms')
          .doc(chatroom)
          .update({'lastMessage': messageModel.toJson()});
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException('send-message-error');
      }
    }
  }

  Stream<List<ChatroomModel>> getChatrooms(String currentUserId) {
    try {
      return _firestore
          .collection('chatrooms')
          .where('participantIds', arrayContains: currentUserId)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => ChatroomModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw AppException('get-chatrooms-error');
    }
  }

  Stream<List<MessageModel>> getChatroomMessages(String chatroomId,
      {int limit = 100}) {
    try {
      return _firestore
          .collection('chatrooms')
          .doc(chatroomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromJson(doc.data()))
              .toList());
    } catch (e) {
      throw AppException('get-messages-error');
    }
  }

  Future<void> updateChatroomParticipant() async {
    try {
      final uid = await _ref.read(authServicesProvider).currentUserUid();

      if (uid == null) {
        throw AppException('no-user');
      }

      final updatedUser = await getUser();
      if (updatedUser == null) {
        throw AppException('no-user');
      }

      final updatedParticipant = ChatParticipant.fromUserModel(updatedUser);

      final chatroomsQuery = await _firestore
          .collection('chatrooms')
          .where('participantIds', arrayContains: uid)
          .get();

      for (var chatroomDoc in chatroomsQuery.docs) {
        final chatroom = ChatroomModel.fromJson(chatroomDoc.data());

        // Find and update the current user's participant info
        List<Map<String, dynamic>> updatedParticipants =
            chatroom.participants.map((participant) {
          if (participant.uid == uid) {
            return updatedParticipant.toJson();
          }
          return participant.toJson();
        }).toList();

        // Update the chatroom document
        await chatroomDoc.reference.update({
          'participants': updatedParticipants,
        });
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      } else {
        throw AppException(
            'update-chatroom-participant-error'); // Updated error code
      }
    }
  }

///////////////////////// MESSAGE COLLECTION /////////////////////////
}
