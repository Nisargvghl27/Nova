import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; // Ensure this file exists

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Optional: define a color scheme for a modern look
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo).copyWith(
          secondary: Colors.amber,
        ),
        useMaterial3: true,
      ),
      
      home: const SplashScreen(), 
      
      debugShowCheckedModeBanner: false,
    );
  }
}