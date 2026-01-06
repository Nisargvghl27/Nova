// import 'package:local_auth/local_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class BiometricService {
//   static final LocalAuthentication _auth = LocalAuthentication();
//   static const String _key = 'isBiometricEnabled';

//   /// Check if hardware is available
//   static Future<bool> isAvailable() async {
//     try {
//       final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
//       return canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Authenticate User
//   static Future<bool> authenticate() async {
//     try {
//       return await _auth.authenticate(
//         localizedReason: 'Please authenticate to change security settings',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: false,
//           sensitiveTransaction: false,
//         ),
//       );
//     } catch (e) {
//       print("Biometric Error: $e");
//       return false;
//     }
//   }

//   /// Save Preference
//   static Future<void> setEnabled(bool value) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_key, value);
//   }

//   /// Load Preference
//   static Future<bool> isEnabled() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_key) ?? false;
//   }
// }
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _key = 'isBiometricEnabled';

  /// Check if hardware is available
  static Future<bool> isAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      return canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      print("Biometric Availability Error: $e");
      return false;
    }
  }

  /// Authenticate User
  static Future<bool> authenticate() async {
    try {
      // 1. Check availability first to avoid errors on unsupported devices
      final bool isAvailable = await _auth.isDeviceSupported(); 
      if (!isAvailable) return false;

      // 2. Trigger Authentication
      return await _auth.authenticate(
        localizedReason: 'Unlock to access Nova',
        options: const AuthenticationOptions(
          stickyAuth: true,
          // ⚠️ Set to false to allow PIN/Pattern as backup if biometric fails
          biometricOnly: false, 
          // ⚠️ CRITICAL: Set to false to allow Face Unlock (Class 2/Weak Security)
          sensitiveTransaction: false, 
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      print("Authentication Error: $e");
      return false;
    }
  }

  /// Save Preference
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }

  /// Load Preference
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }
}