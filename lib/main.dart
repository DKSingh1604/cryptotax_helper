import 'package:cryptotax_helper/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cryptotax_helper/theme.dart';
import 'package:cryptotax_helper/screens/auth/auth_wrapper.dart';
import 'package:cryptotax_helper/utils/constants.dart';
import 'package:cryptotax_helper/firebase_options.dart';
import 'package:cryptotax_helper/services/crypto_repository.dart';
import 'package:cryptotax_helper/models/user_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CryptoTaxHelperApp());
}

class CryptoTaxHelperApp extends StatelessWidget {
  const CryptoTaxHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = CryptoRepository();
    // First listen to auth; only subscribe to settings when authenticated.
    return StreamBuilder(
      stream: repo.authStateChanges,
      builder: (context, authSnap) {
        final isLoggedIn = authSnap.data != null;
        if (!isLoggedIn) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeMode.dark,
            home: const SplashScreen(),
          );
        }

        return StreamBuilder<UserSettings?>(
          stream: repo.getUserSettings(),
          builder: (context, settingsSnap) {
            final isDark = settingsSnap.data?.isDarkMode ?? true;
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
              home: const AuthWrapper(),
            );
          },
        );
      },
    );
  }
}
