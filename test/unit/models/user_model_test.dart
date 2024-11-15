
import 'package:folio/models/user_model.dart';
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
        completedOnboarding: true,
        preferredServices: ['Barber', 'Nail Tech'],
        profilePictureUrl: 'imageurl.com'
      );

      //Expect the user to have all the correct information
      expect(user.uid, '123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.isProfessional, true);
      expect(user.fullName, 'Test User');
      expect(user.completedOnboarding, true);
      expect(user.preferredServices, ['Barber', 'Nail Tech']);
      expect(user.profilePictureUrl, 'imageurl.com');
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
        completedOnboarding: true
      );

      //Check that the toJson returns the correct JSON
      final json = user.toJson();
      expect(json['uid'], '123');
      expect(json['username'], 'testuser');
      expect(json['fullName'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['isProfessional'], true);
      expect(json['completedOnboarding'], true);
      expect(json['preferredServices'], []);
      expect(json['profilePictureUrl'], null);
      expect(json['isEmailVerified'], false);
      expect(json['phoneNumber'], null);
      expect(json['isPhoneVerified'], false);
    });
  });

  group('fromJson', () {
    test('should return a valid user model without a fullName', () {
      final jsonUser = {
        'uid': 'testUid',
        'username': 'testUsername',
        'email': 'email@email.com',
        'isProfessional': true,
        'completedOnboarding': false,
        'preferredServices': ['Barber'],
      };

      final user = UserModel.fromJson(jsonUser);

      expect(user.uid, 'testUid');
      expect(user.username, 'testUsername');
      expect(user.fullName, null);
      expect(user.email, 'email@email.com');
      expect(user.isProfessional, true);
      expect(user.completedOnboarding, false);
      expect(user.preferredServices, ['Barber']);
      expect(user.profilePictureUrl, null);
      expect(user.isEmailVerified, false);
      expect(user.phoneNumber, null);
      expect(user.isPhoneVerified, false);
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
      expect(user.completedOnboarding, false);
      expect(user.preferredServices, []);
      expect(user.profilePictureUrl, null);
      expect(user.isEmailVerified, false);
      expect(user.phoneNumber, null);
      expect(user.isPhoneVerified, false);
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
