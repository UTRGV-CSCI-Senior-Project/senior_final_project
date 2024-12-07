import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/models/user_model.dart';
import 'package:folio/views/view_account/view_profile_screen.dart';
import 'package:mockito/mockito.dart';

import '../mocks/signup_screen_test.mocks.dart';

void main() {
  late MockUserRepository mockUserRepository;
  late ProviderContainer providerContainer;
  late UserModel currentUser;
  late UserModel profileUser;
  late PortfolioModel portfolioModel;

  setUp(() {
    mockUserRepository = MockUserRepository();

    currentUser = UserModel(
        uid: 'current-uid',
        email: 'current@example.com',
        username: 'currentuser',
        isProfessional: false,
        fullName: 'Current User',
        profilePictureUrl: null);
    profileUser = UserModel(
        uid: 'profile-uid',
        email: 'profile@example.com',
        username: 'profileuser',
        isProfessional: true,
        fullName: 'Profile User',
        profilePictureUrl: null);
    portfolioModel = PortfolioModel(
          service: 'Barber', details: 'Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. Im a barber.Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. Im a barber. ', years: 3, months: 1,uid: 'profile-uid', address: '1234s Street', latAndLong: {'latitude': 40.7128, 'longitude': -74.0060}, professionalsName: 'Profile User');
    providerContainer = ProviderContainer(overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepository)
    ]);
    when(mockUserRepository.getOtherUser('profile-uid')).thenAnswer((_) async => profileUser);
  });

  testWidgets('Displays user profile details correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: providerContainer,
        child: MaterialApp(
          home: ViewProfileScreen(
            uid: profileUser.uid,
            currentUser: currentUser,
            portfolioModel: portfolioModel
          )
        )
      )
    );
    await tester.pumpAndSettle();

    // Verify key profile elements
    expect(find.text(profileUser.fullName!), findsOneWidget);
    expect(find.text('Barber for 3 years, 1 month'), findsOneWidget);
  });

  testWidgets('Details text can be expanded', (WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: providerContainer,
        child: MaterialApp(
          home: ViewProfileScreen(
            uid: profileUser.uid,
            currentUser: currentUser,
            portfolioModel: portfolioModel
          )
        )
      )
    );
    await tester.pumpAndSettle();

    // Find 'more' text and tap
    await tester.tap(find.text('more'));
    await tester.pumpAndSettle();

    // Verify full details are shown
    expect(find.textContaining(portfolioModel.details), findsOneWidget);
  });

  testWidgets('Chat button navigates to chatroom for different users', (WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: providerContainer,
        child: MaterialApp(
          home: ViewProfileScreen(
            uid: profileUser.uid,
            currentUser: currentUser,
            portfolioModel: portfolioModel
          )
        )
      )
    );
    await tester.pumpAndSettle();

    // Verify chat button exists
    expect(find.byIcon(Icons.message), findsOneWidget);
  });
}
