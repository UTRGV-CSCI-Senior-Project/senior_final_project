import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/home/inbox_tab.dart';
import 'package:folio/views/home/profile_tab.dart';
import 'package:folio/views/auth_onboarding_welcome/loading_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/onboarding_screen.dart';
import 'package:folio/views/home/discover_tab.dart';
import 'package:folio/views/home/home_tab.dart';
import 'package:folio/widgets/edit_profile_sheet.dart';
import 'package:folio/views/settings/settings_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/auth_onboarding_welcome/welcome_screen.dart';
import 'package:folio/widgets/email_verification_dialog.dart';
import 'package:folio/widgets/request_location_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);
final hasShownEmailDialogProvider = StateProvider<bool>((ref) => false);
final hasShownLocationPermissionDialog = StateProvider<bool>((ref) => false);
final discoverSearchProvider = StateProvider<String?>((ref) => null);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
    Timer? _emailCheckTimer;
    bool _isInitializingNotifications = false;

  @override
  void initState() {
    super.initState();
   WidgetsBinding.instance.addPostFrameCallback((_) async {
    try{
      _initializeMessaging();
    }catch(e){
    }
      _emailCheckTimer = Timer(const Duration(milliseconds: 100), () {
        if (mounted) {
          _checkAndShowEmailVerification();
        }
      });
    });
  }
 @override
  void dispose() {
    _emailCheckTimer?.cancel();
    super.dispose();
  }

void _checkAndShowEmailVerification() {
    final userData = ref.read(userDataStreamProvider).value;
    if (userData == null) return;

    final userModel = userData['user'];
    if (userModel == null) return;
    if (!userModel.completedOnboarding) return;

    // Force UI update to ensure consistent state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hasShownDialog = ref.read(hasShownEmailDialogProvider);
      if (!hasShownDialog && !userModel.isEmailVerified && mounted) {
        // Set flag before showing dialog
        ref.read(hasShownEmailDialogProvider.notifier).state = true;
        
        // Use root navigator and ensure dialog is modal
        showDialog(
          context: context,
          barrierDismissible: false,
          useRootNavigator: true,
          builder: (BuildContext dialogContext) => const PopScope(
            canPop: false,  // Prevent back button dismissal
            child: EmailVerificationDialog(),
          ),
        );
      }
    });
  }

  Future<void> _initializeMessaging() async {
    // Only initialize if not already in progress
    if (_isInitializingNotifications) return;
    _isInitializingNotifications = true;

    try {
      final messagingService = ref.read(cloudMessagingServicesProvider);
      await messagingService.initNotifications();
    } catch (e) {
      return;
    } finally {
      _isInitializingNotifications = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return ref.watch(userDataStreamProvider).when(
        data: (userData) {
          final userModel = userData?['user'];
          final userPortfolio = userData?['portfolio'];
          if (userModel == null) {
            return const WelcomeScreen();
          }

          if (userModel.completedOnboarding) {
            final hashShownLocationPermission =
                ref.watch(hasShownLocationPermissionDialog);
            if (!hashShownLocationPermission) {
              _checkLocationPermission(context, ref);
            }

            final selectedIndex = ref.watch(selectedIndexProvider);
            ref.listen(emailVerificationStreamProvider, (previous, next) {});

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
                actions: [
                  SpeedDial(
                    key: const Key('speeddial-button'),
                    direction: SpeedDialDirection.down,
                    overlayColor: Theme.of(context).colorScheme.tertiary,
                    overlayOpacity: 0.9,
                    spacing: 8,
                    spaceBetweenChildren: 8,
                    childMargin: const EdgeInsets.all(0),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    activeBackgroundColor:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                    activeForegroundColor:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.7),
                    activeChild: Icon(
                      Icons.clear_rounded,
                      size: 26,
                      color: Theme.of(context).colorScheme.onTertiary,
                    ),
                    visible: selectedIndex == 3,
                    children: [
                      SpeedDialChild(
                          key: const Key('editprofile-button'),
                          onTap: () => showEditProfileSheet(context, userModel),
                          label: 'Edit Profile',
                          labelBackgroundColor: Colors.transparent,
                          labelShadow: [],
                          labelStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                          elevation: 0,
                          child: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                          backgroundColor: Colors.transparent),
                      SpeedDialChild(
                          key: const Key('settings-button'),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const SettingsScreen())),
                          label: 'Settings',
                          labelBackgroundColor: Colors.transparent,
                          labelShadow: [],
                          labelStyle: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                          elevation: 0,
                          child: Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                          backgroundColor: Colors.transparent),
                      SpeedDialChild(
                          label: 'Share Profile',
                          labelBackgroundColor: Colors.transparent,
                          labelShadow: [],
                          labelStyle: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onTertiary),
                          elevation: 0,
                          child: Icon(
                            Icons.ios_share,
                            color: Theme.of(context).colorScheme.onTertiary,
                          ),
                          backgroundColor: Colors.transparent),
                    ],
                    child: Icon(
                      color: Theme.of(context).colorScheme.tertiary,
                      Icons.more_vert,
                      size: 26,
                    ),
                  ),
                ],
                automaticallyImplyLeading: false,
                title: Text(
                  getTitle(),
                  style: GoogleFonts.inter(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              body: IndexedStack(
                index: selectedIndex,
                children: [
                  HomeTab(userModel: userModel),
                  DiscoverTab(userModel: userModel,),
                  InboxTab(userModel: userModel),
                  EditProfile(
                      userModel: userModel, portfolioModel: userPortfolio),
                ],
              ),
              bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0 ? const SizedBox.shrink() :
              
              NavigationBar(
                height: MediaQuery.of(context).viewInsets.bottom + 50,
                selectedIndex: selectedIndex,
                onDestinationSelected: (index) {
                  // Update the selected index when a destination is tapped
                  ref.read(selectedIndexProvider.notifier).state = index;
                },
                destinations: [
                  NavigationDestination(
                    key: const Key('home-button'),
                    icon: const Icon(
                      Icons.home_outlined,
                      size: 25,
                    ),
                    selectedIcon: Icon(Icons.home,
                        color: Theme.of(context).colorScheme.primary, size: 30),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    key: const Key('discover-button'),
                    icon: const Icon(Icons.explore_outlined, size: 25),
                    selectedIcon: Icon(Icons.explore,
                        color: Theme.of(context).colorScheme.primary, size: 30),
                    label: 'Discover',
                  ),
                  NavigationDestination(
                    key: const Key('inbox-button'),
                    icon: const Icon(Icons.email_outlined, size: 25),
                    selectedIcon: Icon(Icons.email,
                        color: Theme.of(context).colorScheme.primary, size: 30),
                    label: 'Inbox',
                  ),
                  NavigationDestination(
                    key: const Key('profile-button'),
                    icon: const Icon(Icons.person_outline, size: 25),
                    selectedIcon: Icon(Icons.person,
                        color: Theme.of(context).colorScheme.primary, size: 30),
                    label: 'Profile',
                  ),
                ],
              ),
            );
          } else {
            return const OnboardingScreen();
          }
        },
        error: (e, s) {
          if (e is AppException && e.code == 'no-user-doc') {
            ref.read(userRepositoryProvider).signOut();
          } else if (e is AppException && e.code == 'no-user') {
            ref.read(userRepositoryProvider).signOut();
          }
          return const Scaffold(
            body: ErrorView(
                bigText: 'There was an error!',
                smallText: 'Please check your connection, or restart the app!'),
          );
        },
        loading: () => const LoadingScreen());
  }
}
void _checkLocationPermission(BuildContext context, WidgetRef ref) async {
  final locationService = ref.read(locationServiceProvider);

  try {
    bool hasPermission = await locationService.checkPermission();
    ref.read(positionListenerProvider);
    if (!hasPermission && context.mounted) {
      bool? shouldRequestPermission = await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) => const RequestLocationDialog());
      if (shouldRequestPermission ?? false) {
        await locationService.openLocationSettings();
      }
      ref.read(hasShownLocationPermissionDialog.notifier).state = true;
    }
  } catch (e) {
    return;
  }
}
