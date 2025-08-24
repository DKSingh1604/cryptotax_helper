import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cryptotax_helper/screens/auth/login_screen.dart';
import 'package:cryptotax_helper/screens/dashboard/dashboard_screen.dart';
import 'package:cryptotax_helper/services/firebase_auth_service.dart';
import 'package:cryptotax_helper/services/firestore_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final firestoreService = FirestoreService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show error if any
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: \\${snapshot.error}'),
            ),
          );
        }
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // User not authenticated, show login screen
          return const LoginScreen();
        } else {
          // User authenticated, update login time and show dashboard
          firestoreService.updateLastLoginTime();
          return const DashboardScreen();
        }
      },
    );
  }
}
