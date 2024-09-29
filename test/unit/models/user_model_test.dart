import 'package:senior_final_project/models/user_model.dart';
import 'package:test/test.dart';

void main() {
  group("Valid User Models", () {

    test('Creates a valid user', () {
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

  group("Invalid User Models", () {
       test('UserModel should throw an error when uid is empty', () {
        //Expect a user with an empty UID to throw an argument error
      expect(() => UserModel(
        uid: '',
        username: 'testuser',
        email: 'test@example.com',
        isProfessional: true,
      ), throwsArgumentError);
    });

    test('UserModel should throw an error when username is empty', () {
      //Expect a user with an empty username to throw an argument error
      expect(() => UserModel(
        uid: '123',
        username: '',
        email: 'test@example.com',
        isProfessional: true,
      ), throwsArgumentError);
    });

    test('UserModel should throw an error when email is empty', () {
      //Expect a user with an empty email to throw an argument error
      expect(() => UserModel(
        uid: '123',
        username: 'testuser',
        email: '',
        isProfessional: true,
      ), throwsArgumentError);
    });


  });

}