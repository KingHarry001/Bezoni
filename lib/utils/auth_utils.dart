import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Authentication utility methods for managing saved credentials
class AuthUtils {
  // SharedPreferences keys
  static const String _keyRememberMe = 'remember_me';
  static const String _keySavedEmail = 'saved_email';
  static const String _keySavedPassword = 'saved_password';

  /// Clear saved credentials (for logout)
  static Future<void> clearSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRememberMe);
      await prefs.remove(_keySavedEmail);
      await prefs.remove(_keySavedPassword);
      debugPrint('✅ Remember me credentials cleared');
    } catch (e) {
      debugPrint('❌ Error clearing credentials: $e');
    }
  }

  /// Load saved credentials if "Remember Me" was previously enabled
  static Future<Map<String, dynamic>> loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
      
      if (rememberMe) {
        final savedEmail = prefs.getString(_keySavedEmail) ?? '';
        final savedPassword = prefs.getString(_keySavedPassword) ?? '';
        
        return {
          'rememberMe': rememberMe,
          'email': savedEmail,
          'password': savedPassword,
        };
      }
      
      return {
        'rememberMe': false,
        'email': '',
        'password': '',
      };
    } catch (e) {
      debugPrint('❌ Error loading saved credentials: $e');
      return {
        'rememberMe': false,
        'email': '',
        'password': '',
      };
    }
  }

  /// Save credentials if "Remember Me" is enabled
  static Future<void> saveCredentials({
    required bool rememberMe,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (rememberMe) {
        // Save credentials
        await prefs.setBool(_keyRememberMe, true);
        await prefs.setString(_keySavedEmail, email.trim());
        await prefs.setString(_keySavedPassword, password);
        debugPrint('✅ Credentials saved');
      } else {
        // Clear saved credentials
        await prefs.remove(_keyRememberMe);
        await prefs.remove(_keySavedEmail);
        await prefs.remove(_keySavedPassword);
        debugPrint('✅ Credentials cleared');
      }
    } catch (e) {
      debugPrint('❌ Error saving credentials: $e');
    }
  }
}