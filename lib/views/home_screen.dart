import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/home_screen_tabs/edit_profile.dart';
import 'package:folio/views/loading_screen.dart';
import 'package:folio/views/onboarding_screen.dart';
import 'package:folio/views/home_screen_tabs/discover_tab.dart';
import 'package:folio/views/home_screen_tabs/home_tab.dart';
import 'package:folio/views/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userStreamProvider).when(
        data: (userModel) {
          if (userModel == null) {
            return const WelcomeScreen();
          }
          if (userModel.completedOnboarding) {
            final selectedIndex = ref.watch(selectedIndexProvider);
            String getTitle() {
              switch (selectedIndex) {
                case 0:
                  return 'Welcome, ${userModel.fullName}!';
                case 1:
                  return 'Discover';
                case 2:
                  return 'Inbox';
                case 3:
                  return 'Profile';
                default:
                  return 'Folio';
              }
            }

            return Scaffold(
              appBar: AppBar(
                centerTitle: false,
                leading: null,
                automaticallyImplyLeading: false,
                title: Text(getTitle(),
                style: GoogleFonts.inter(
                  fontSize: 20, 
                  fontWeight: FontWeight.bold
                  
                ),
                    ),
                    actions: selectedIndex == 3 ? [IconButton(onPressed: (){
                      ref.watch(userRepositoryProvider).signOut();
                    }, icon: const Icon(Icons.settings))] : null,
              ),
              body: IndexedStack(
                index: selectedIndex,
                children: [
                  HomeTab(userModel: userModel),
                  const DiscoverTab(),
                  const EditProfile(),
                  const EditProfile(),

                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  // Update the selected index when a destination is tapped
                  ref.read(selectedIndexProvider.notifier).state = index;
                },
                destinations:  [
                  NavigationDestination(
                    key:  const Key('home-button'),
                    icon: const Icon(Icons.home, size: 25,),
                    selectedIcon: Icon(
                      Icons.home,
                      color: Theme.of(context).colorScheme.primary,size: 30
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    key:  const Key('discover-button'),
                    icon: const Icon(Icons.explore , size: 25),
                    selectedIcon: Icon(
                      Icons.explore,
                      color: Theme.of(context).colorScheme.primary,size: 30
                    ),
                    label: 'Discover',
                  ),
                  NavigationDestination(
                    key:  const Key('inbox-button'),
                    icon: const Icon(Icons.bookmark_border, size: 25),
                    enabled: false,
                    selectedIcon: Icon(
                      Icons.bookmark_border,
                      color: Theme.of(context).colorScheme.primary,size: 30
                    ),
                    label: 'Inbox',
                  ),
                  NavigationDestination(
                    key:  const Key('profile-button'),
                    icon: const Icon(Icons.person, size: 25),
                    selectedIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,size: 30
                    ),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          } else {
            return const OnboardingScreen();
          }
        },
        error: (s, p)  => const LoadingScreen(),
        loading: () => const LoadingScreen());
  }
}