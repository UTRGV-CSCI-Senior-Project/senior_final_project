import 'package:flutter/material.dart';
import 'package:folio/constants/theme_constants.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/auth_onboarding_welcome/state_screens.dart';
import 'package:folio/views/home/home_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/loading_screen.dart';
import 'package:folio/views/auth_onboarding_welcome/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main({bool useEmulator = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  setupEmulators(useEmulators: useEmulator);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  final Duration duration;
  const MyApp({super.key, this.duration = const Duration(seconds: 3)});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Folio',
        theme: lightTheme,
        darkTheme: darkTheme,
        initialRoute: '/',
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/home': (context) => const HomeScreen(),
        },
        home: FutureBuilder(
            future: Future.delayed(duration, () {
              return ref.watch(authStateProvider);
            }),
            builder: (context, snapshot) {
              return snapshot.data?.when(
                    data: (user) {
                      if (user != null) {
                        return const HomeScreen();
                      } else {
                        return const WelcomeScreen();
                      }
                    },
                    error: (e, s) {
                      return const Scaffold(
                        body: ErrorView(
                            bigText: 'There was an error!',
                            smallText:
                                'Please check your connection, or restart the app!'),
                      );
                    },
                    loading: () => const LoadingScreen(),
                  ) ??
                  const LoadingScreen();
            }));
  }
}
