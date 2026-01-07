import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/biometric_service.dart';
import 'screens/biometric_lock_screen.dart'; // 🔹 Added Import

// 1. Global Theme Notifier to manage state
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔹 LOAD SAVED THEME
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Nova',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8F9FD),
            cardColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black87),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.black87),
              bodyMedium: TextStyle(color: Colors.black87),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.indigo,
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            dividerColor: Colors.grey[800],
            iconTheme: const IconThemeData(color: Colors.white70),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
            ),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
              backgroundColor: Color(0xFF1E1E1E),
              selectedItemColor: Color(0xFF2575FC),
              unselectedItemColor: Colors.grey,
            ),
          ),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

// 🔹 UPDATED: Handles Biometric Lock Logic with new UI
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLocked = false;
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSettings();
  }

  /// 🔹 Check if user has enabled biometric lock
  Future<void> _checkBiometricSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    // Only lock if user is actually logged in
    if (user != null) {
      final isEnabled = await BiometricService.isEnabled();
      if (isEnabled) {
        setState(() {
          _isLocked = true;
          _isLoading = false;
        });
        _authenticate(); // Auto-trigger face/fingerprint scan
        return;
      }
    }
    
    setState(() {
      _isLocked = false;
      _isLoading = false;
    });
  }

  /// 🔹 Trigger the native authentication prompt
  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    
    setState(() => _isAuthenticating = true);
    
    // Slight delay to ensure UI builds before auth dialog pops up
    await Future.delayed(const Duration(milliseconds: 200));

    final success = await BiometricService.authenticate();
    
    if (mounted) {
      setState(() {
        _isAuthenticating = false;
        if (success) {
          _isLocked = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SplashScreen();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        final user = snapshot.data;

        if (user != null && user.emailVerified) {
          // 🔹 SHOW NEW LOCK SCREEN IF ENABLED
          if (_isLocked) {
            return BiometricLockScreen(
              onUnlock: _authenticate,
              isAuthenticating: _isAuthenticating,
            );
          }
          return const MainScreen();
        }
        return const LoginScreen();
      },
    );
  }
}