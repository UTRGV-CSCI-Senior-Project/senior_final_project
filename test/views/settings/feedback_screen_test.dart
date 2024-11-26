

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/settings/feedback_screen.dart';
import 'package:mockito/mockito.dart';
import '../../mocks/feedback_screen_test.mocks.dart';


void main(){
  late MockFeedbackRepository mockFeedbackRepository;

  setUp((){
    mockFeedbackRepository = MockFeedbackRepository();
  });

   Widget createWidget({required String type, required String userId}) {
    return ProviderScope(
      overrides: [
        feedbackRepositoryProvider.overrideWithValue(mockFeedbackRepository),
      ],
      child: MaterialApp(
        home: FeedbackScreen(
          type: type,
          userId: userId,
        ),
      ),
    );
  }

  group('FeedbackScreen', () {
    testWidgets('renders bug report UI correctly', (tester) async {
      await tester.pumpWidget(createWidget(type: 'bug', userId: 'test-user'));

      // Verify app bar title
      expect(find.text('Report a Bug'), findsOneWidget);
      expect(find.text("Found something not working correctly?\nLet us know and we'll fix it!"), findsOneWidget);

      // Verify hint texts
      expect(find.text('Briefly describe the issue'), findsOneWidget);
      expect(
          find.text(
              'Please provide details about what happened and steps to reproduce the issue'),
          findsOneWidget);

      // Verify button text
      expect(find.text('Submit Bug Report'), findsOneWidget);
    });

    testWidgets('renders help UI correctly', (tester) async {
      await tester.pumpWidget(createWidget(type: 'help', userId: 'test-user'));

      // Verify app bar title
      expect(find.text('Get Help'), findsOneWidget);
      expect(find.text("Need assistance? We're here to help!"), findsOneWidget);

      // Verify hint texts
      expect(find.text('What do you need help with?'), findsOneWidget);
      expect(
          find.text('Please describe your question or concern in detail'),
          findsOneWidget);

      // Verify button text
      expect(find.text('Send'), findsOneWidget);
    });

    testWidgets('shows success message on successful submission',
        (tester) async {
      when(mockFeedbackRepository.sendFeedback(any, any, any, any))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidget(type: 'bug', userId: 'test-user'));

      // Fill in the form
      await tester.enterText(find.byKey(const Key('subject-field')), 'Test Bug');
      await tester.enterText(
          find.byKey(const Key('message-field')), 'Test Description');

      // Tap submit button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify success message
      verify(mockFeedbackRepository.sendFeedback(any, any, any, any)).called(1);
      expect(find.byType(SnackBar), findsNWidgets(1));
      expect(find.text('Thank you for reporting this bug!'), findsOneWidget);
    });

    testWidgets('shows success message on successful submission',
        (tester) async {
      when(mockFeedbackRepository.sendFeedback(any, any, any, any))
          .thenAnswer((_) async => {});

      await tester.pumpWidget(createWidget(type: 'help', userId: 'test-user'));

      // Fill in the form
      await tester.enterText(find.byKey(const Key('subject-field')), 'Getting Help');
      await tester.enterText(
          find.byKey(const Key('message-field')), 'Test Description');

      // Tap submit button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify success message
      verify(mockFeedbackRepository.sendFeedback(any, any, any, any)).called(1);
      expect(find.byType(SnackBar), findsNWidgets(1));
      expect(find.text('Your help request has been submitted!'), findsOneWidget);
    });


    testWidgets('shows error message on submission failure', (tester) async {
      when(mockFeedbackRepository.sendFeedback(any, any, any, any))
          .thenThrow(AppException('Failed to submit feedback'));

      await tester.pumpWidget(createWidget(type: 'bug', userId: 'test-user'));

      // Fill in the form
      await tester.enterText(find.byKey(const Key('subject-field')), 'Test Bug');
      await tester.enterText(
          find.byKey(const Key('message-field')), 'Test Description');

      // Tap submit button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify error message
      expect(find.byType(SnackBar), findsNWidgets(1));
    });

    testWidgets('validates form fields before submission', (tester) async {
      await tester.pumpWidget(createWidget(type: 'bug', userId: 'test-user'));

      // Tap submit button without filling form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify form validation messages
      expect(find.text('Please fill in all fields'), findsNWidgets(1));

      // Verify repository was not called
      verifyNever(mockFeedbackRepository.sendFeedback(any, any, any, any));
    });
  });
}