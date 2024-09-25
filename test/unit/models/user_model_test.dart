import 'package:senior_final_project/models/user_model.dart';
import 'package:test/test.dart';

void main() {
  group("Valid User Models", () {

    test('Creates a valid user', () {
      final user = UserModel(
        uid: '123',
        username: 'testuser',
        fullName: 'Test User',
        email: 'test@example.com',
        isProfessional: true,
      );

      expect(user.uid, '123');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.isProfessional, true);
      expect(user.fullName, 'Test User');
    });

    test('toJson should return a valid JSON representation', () {
      final user = UserModel(
        uid: '123',
        username: 'testuser',
        fullName: 'Test User',
        email: 'test@example.com',
        isProfessional: true,
      );

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
      expect(() => UserModel(
        uid: '',
        username: 'testuser',
        email: 'test@example.com',
        isProfessional: true,
      ), throwsArgumentError);
    });

    test('UserModel should throw an error when username is empty', () {
      expect(() => UserModel(
        uid: '123',
        username: '',
        email: 'test@example.com',
        isProfessional: true,
      ), throwsArgumentError);
    });

    test('UserModel should throw an error when email is empty', () {
      expect(() => UserModel(
        uid: '123',
        username: 'testuser',
        email: '',
        isProfessional: true,
      ), throwsArgumentError);
    });


  });

}