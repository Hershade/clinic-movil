import 'package:flutter/material.dart';

import '../../screens/home_screen.dart';
import '../../services/session_service.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionService = SessionService();

    return FutureBuilder<bool>(
      future: sessionService.hasSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final hasSession = snapshot.data ?? false;

        if (hasSession) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}