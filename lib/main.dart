import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:raga_saarthi/screens/home_screen.dart';
import 'package:raga_saarthi/screens/login_screen.dart';
import 'package:raga_saarthi/services/auth_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const RaagSaarthiApp(),
    ),
  );
}

class RaagSaarthiApp extends StatelessWidget {
  const RaagSaarthiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Raag Saarthi',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          return FutureBuilder<bool>(
            future: authService.isLoggedIn(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final bool isLoggedIn = snapshot.data ?? false;
              return isLoggedIn ? const HomeScreen() : const LoginScreen();
            },
          );
        },
      ),
    );
  }
}