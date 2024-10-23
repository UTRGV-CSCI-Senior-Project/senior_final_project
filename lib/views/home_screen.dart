import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/tabs/edit_profile.dart';
import 'package:folio/views/loading_screen.dart';
import 'package:folio/views/onboarding_screen.dart';
import 'package:folio/views/tabs/discover_tab.dart';
import 'package:folio/views/tabs/home_tab.dart';
import 'package:folio/views/welcome_screen.dart';

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
                  return 'Welcome,\  ${userModel.fullName}!';
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
                backgroundColor: Colors.white,
                centerTitle: false,
                title: Text(getTitle(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    )),
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
                backgroundColor: Colors.grey.shade50,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  // Update the selected index when a destination is tapped
                  ref.read(selectedIndexProvider.notifier).state = index;
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    selectedIcon: Icon(
                      Icons.home,
                      color: Color.fromRGBO(0, 111, 253, 100),
                    ),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.explore),
                    selectedIcon: Icon(
                      Icons.explore,
                      color: Color.fromRGBO(0, 111, 253, 100),
                    ),
                    label: 'Discover',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bookmark_border),
                    enabled: false,
                    selectedIcon: Icon(
                      Icons.bookmark_border,
                      color: Color.fromRGBO(0, 111, 253, 100),
                    ),
                    label: 'Inbox',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person),
                    selectedIcon: Icon(
                      Icons.person,
                      color: Color.fromRGBO(0, 111, 253, 100),
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
        error: (s, p) => const LoadingScreen(),
        loading: () => const LoadingScreen());
  }
}