import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cryptotax_helper/theme.dart';
import 'package:cryptotax_helper/screens/auth/auth_wrapper.dart';
import 'package:cryptotax_helper/utils/constants.dart';
import 'package:cryptotax_helper/firebase_options.dart';

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
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode as requested
      home: const AuthWrapper(),
    );
  }
}
