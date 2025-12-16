import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();

    // 1. Start animation after a small delay
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isVisible = true; // Triggers the fade-in
      });
    });

    // 2. Navigate to Login after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Center Content (Logo + Text)
            Expanded(
              child: AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(seconds: 2), // Smooth 2s fade-in
                curve: Curves.easeOut,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shadow for depth
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'My Wallet',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        fontFamily: 'Roboto', // Default nicely legible font
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Smart way to manage finance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Loader
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.9),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}