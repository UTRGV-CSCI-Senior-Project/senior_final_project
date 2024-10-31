import 'package:flutter/material.dart';
import 'package:folio/constants/theme_constants.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/views/home_screen.dart';
import 'package:folio/views/loading_screen.dart';
import 'package:folio/views/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main({bool useEmulator = false}) async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        title: 'Folio',
        theme: lightTheme,
        darkTheme: darkTheme,
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
                    error: (e, s) => const LoadingScreen(),
                    loading: () => const LoadingScreen(),
                  ) ??
                  const LoadingScreen();
            }));
  }
}
