import 'dart:convert';

import 'package:senior_final_project/models/user_model.dart';
import 'package:test/test.dart';

void main() {
  group("User model constructor", () {
    test('creates a valid user', () {
      //Create a valid user
      final user = UserModel(
        uid: '123',
        username: 'testuser',
        fullName: 'Test User',
        email: 'test@example.com',
        isProfessional: true,
      );

      //Expect the user to have all the correct information
      expect(user.uid, '123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.isProfessional, true);
      expect(user.fullName, 'Test User');
    });

    test('throws an error when uid is empty', () {
      //Expect a user with an empty UID to throw an argument error
      expect(
          () => UserModel(
                uid: '',
                username: 'testuser',
                email: 'test@example.com',
                isProfessional: true,
              ),
          throwsArgumentError);
    });

    test('throws an error when username is empty', () {
      //Expect a user with an empty username to throw an argument error
      expect(
          () => UserModel(
                uid: '123',
                username: '',
                email: 'test@example.com',
                isProfessional: true,
              ),
          throwsArgumentError);
    });

    test('throws an error when email is empty', () {
      //Expect a user with an empty email to throw an argument error
      expect(
          () => UserModel(
                uid: '123',
                username: 'testuser',
                email: '',
                isProfessional: true,
              ),
          throwsArgumentError);
    });
  });

  group("toJson", () {
    test('toJson should return a valid JSON representation', () {
      //Create a valid user
      final user = UserModel(
        uid: '123',
        username: 'testuser',
        fullName: 'Test User',
        email: 'test@example.com',
        isProfessional: true,
      );

      //Check that the toJson returns the correct JSON
      final json = user.toJson();
      expect(json['uid'], '123');
      expect(json['username'], 'testuser');
      expect(json['fullName'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['isProfessional'], true);
    });
  });

  group('fromJson', () {
    test('should return a valid user model without a fullName', () {
      final jsonUser = {
        'uid': 'testUid',
        'username': 'testUsername',
        'email': 'email@email.com',
        'isProfessional': true
      };

      final user = UserModel.fromJson(jsonUser);

      expect(user.uid, 'testUid');
      expect(user.username, 'testUsername');
      expect(user.fullName, null);
      expect(user.email, 'email@email.com');
      expect(user.isProfessional, true);
    });

    test('should return a valid user model with a fullName', () {
      final jsonUser = {
        'uid': 'testUid',
        'username': 'testUsername',
        'fullName': 'test name',
        'email': 'email@email.com',
        'isProfessional': true
      };

      final user = UserModel.fromJson(jsonUser);

      expect(user.uid, 'testUid');
      expect(user.username, 'testUsername');
      expect(user.fullName, 'test name');
      expect(user.email, 'email@email.com');
      expect(user.isProfessional, true);
    });

    test('should throw an error when uid is missing', () {
      expect(
          () => UserModel.fromJson({
                'username': 'testuser',
                'email': 'test@example.com',
                'isProfessional': true,
              }),
          throwsArgumentError);
    });
    test('should throw an error when username is missing', () {
      expect(
          () => UserModel.fromJson({
                'uid': '123',
                'email': 'test@example.com',
                'isProfessional': true,
              }),
          throwsArgumentError);
    });
    test('should throw an error when email is missing', () {
      expect(
          () => UserModel.fromJson({
                'uid': '123',
                'username': 'testuser',
                'isProfessional': true,
              }),
          throwsArgumentError);
    });
    test('should throw an error when isProfessional is missing', () {
      expect(
          () => UserModel.fromJson({
                'uid': '123',
                'username': 'testuser',
                'email': 'test@example.com',
              }),
          throwsArgumentError);
    });
  });
}
