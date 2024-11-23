import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/create_portfolio_tabs/create_portfolio_screen.dart';
import 'package:folio/views/settings/account_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/auth_onboarding_welcome/welcome_screen.dart';
import 'package:folio/views/settings/feedback_screen.dart';
import 'package:folio/views/settings/manage_portfolio_screen.dart';
import 'package:folio/widgets/logout_dialog.dart';
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
          final portfolio = userData?['portfolio'];
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                key: const Key('settings-back-button'),
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios,
                size: 24)),
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
                                       CreatePortfolioScreen(name: user.fullName ?? user.username)));
                        },
                      ),
                    if (user.isProfessional && portfolio != null)
                      SettingsItem(
                        title: 'Manage portfolio',
                        leading: const Icon(Icons.folder_open_outlined),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                       ManagePortfolioScreen(portfolioModel: portfolio,)));
                        },
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
                            builder: (BuildContext  context) => const LogoutDialog() );
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
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen(type: 'bug', userId: user.uid)));
                      },
                    ),
                    SettingsItem(
                      title: 'Get Help',
                      leading: const Icon(Icons.feedback_outlined),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => FeedbackScreen(type: 'help', userId: user.uid)));
                      },
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


