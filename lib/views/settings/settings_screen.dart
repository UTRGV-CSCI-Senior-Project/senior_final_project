import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/create_portfolio_tabs/create_portfolio_screen.dart';
import 'package:folio/views/settings/account_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/auth_onboarding_welcome/welcome_screen.dart';
import 'package:folio/widgets/settings_item_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(userDataStreamProvider).when(
        data: (userData) {
          if (userData?['user'] == null) {
            return const WelcomeScreen();
          }
          final user = userData?['user'];

          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Settings',
                style: GoogleFonts.inter(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            body: SafeArea(
                child: SingleChildScrollView(
                    child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GENERAL',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 15),
                    SettingsItem(
                      title: 'Account',
                      leading: const Icon(Icons.person_outline),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>  AccountScreen(user: user))),
                    ),
                    if (!user.isProfessional)
                      SettingsItem(
                        title: 'Become a professional',
                        leading: const Icon(Icons.create_new_folder_outlined),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CreatePortfolioScreen()));
                        },
                      ),
                    if (user.isProfessional)
                      SettingsItem(
                        title: 'Manage portfolio',
                        leading: const Icon(Icons.folder_open_outlined),
                        onTap: () {},
                      ),
                    SettingsItem(
                      title: 'Notifications',
                      leading: const Icon(Icons.notifications_none_outlined),
                      onTap: () {},
                    ),
                    SettingsItem(
                      title: 'Log Out',
                      leading:  Icon(Icons.logout_outlined, color: Theme.of(context).colorScheme.error,),
                      color: Theme.of(context).colorScheme.error,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  actionsAlignment: MainAxisAlignment.center,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.tertiary,
                                  title: Text(
                                    'Log out',
                                    style: GoogleFonts.poppins(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onTertiary),
                                  ),
                                  content: Text(
                                      "Are you sure you want to log out? You'll need to login again to use the app.",
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiary)),
                                  actions: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            style: TextButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              side: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 3),
                                            ),
                                            child: Text('Cancel',
                                                style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                          ),
                                        ),
                                        const SizedBox(width: 6,),
                                        Expanded(
                                          child: TextButton(
                                              onPressed: () {
                                                ref
                                                    .watch(
                                                        userRepositoryProvider)
                                                    .signOut();
                                                Navigator.pop(context);
                                              },
                                              child: Text('LOGOUT',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        )
                                      ],
                                    )
                                  ],
                                ));
                      },
                    ),
                    const SizedBox(height: 30),
                    Text('FEEDBACK',
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 15),
                    SettingsItem(
                      title: 'Report a bug',
                      leading: const Icon(Icons.bug_report_outlined),
                      onTap: () {},
                    ),
                    SettingsItem(
                      title: 'Send feedback',
                      leading: const Icon(Icons.feedback_outlined),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ))),
          );
        },
        error: (s, p) => const ErrorView(
              bigText: 'There was an error!',
              smallText: 'Please check your connection, or restart the app!',
            ),
        loading: () => const LoadingView());
  }
}


