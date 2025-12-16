import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Import the Login screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personalized Budget App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Optional: define a color scheme for a modern look
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      // Set the LoginScreen as the home screen
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}