import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const ParkoApp());
}

class ParkoApp extends StatelessWidget {
  const ParkoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parko',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}
