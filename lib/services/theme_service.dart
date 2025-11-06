import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { light, dark, system }

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'bezoni_app_theme';
  AppTheme _currentTheme = AppTheme.system;
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  AppTheme get currentTheme => _currentTheme;
  bool get isInitialized => _initialized;
  
  // Get the actual theme mode based on current selection
  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  // Initialize theme service
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadTheme();
      _initialized = true;
      _updateSystemUIOverlay();
      notifyListeners();
    } catch (e) {
      debugPrint('ThemeService initialization failed: $e');
      _initialized = true;
      _currentTheme = AppTheme.system;
      notifyListeners();
    }
  }

  // Load saved theme from shared preferences
  Future<void> _loadTheme() async {
    try {
      if (_prefs != null) {
        final themeIndex = _prefs!.getInt(_themeKey) ?? AppTheme.system.index;
        if (themeIndex >= 0 && themeIndex < AppTheme.values.length) {
          _currentTheme = AppTheme.values[themeIndex];
        } else {
          _currentTheme = AppTheme.system;
        }
      }
    } catch (e) {
      debugPrint('Failed to load theme: $e');
      _currentTheme = AppTheme.system;
    }
  }

  // Save theme to shared preferences
  Future<void> _saveTheme() async {
    try {
      if (_prefs != null) {
        await _prefs!.setInt(_themeKey, _currentTheme.index);
        debugPrint('Theme saved: ${_currentTheme.name}');
      }
    } catch (e) {
      debugPrint('Failed to save theme: $e');
    }
  }

  // Change theme
  Future<void> setTheme(AppTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      await _saveTheme();
      _updateSystemUIOverlay();
      notifyListeners();
      debugPrint('Theme changed to: ${theme.name}');
    }
  }

  // Update system UI overlay (status bar, navigation bar)
  void _updateSystemUIOverlay() {
    try {
      final brightness = _getCurrentBrightness();
      
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: brightness == Brightness.dark 
            ? Brightness.light 
            : Brightness.dark,
        systemNavigationBarColor: brightness == Brightness.dark
            ? const Color(0xFF0F172A) // Dark navy for dark theme
            : Colors.white,
        systemNavigationBarIconBrightness: brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ));
    } catch (e) {
      debugPrint('Failed to update system UI overlay: $e');
    }
  }

  // Get current brightness
  Brightness _getCurrentBrightness() {
    try {
      switch (_currentTheme) {
        case AppTheme.light:
          return Brightness.light;
        case AppTheme.dark:
          return Brightness.dark;
        case AppTheme.system:
          return WidgetsBinding.instance.platformDispatcher.platformBrightness;
      }
    } catch (e) {
      debugPrint('Failed to get current brightness: $e');
      return Brightness.light;
    }
  }

  // Check if current theme is dark
  bool isDarkMode(BuildContext context) {
    try {
      switch (_currentTheme) {
        case AppTheme.light:
          return false;
        case AppTheme.dark:
          return true;
        case AppTheme.system:
          return MediaQuery.of(context).platformBrightness == Brightness.dark;
      }
    } catch (e) {
      debugPrint('Failed to determine dark mode: $e');
      return false;
    }
  }

  // Get theme name for display
  String get themeName {
    switch (_currentTheme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

  // Get theme icon
  IconData get themeIcon {
    switch (_currentTheme) {
      case AppTheme.light:
        return Icons.light_mode;
      case AppTheme.dark:
        return Icons.dark_mode;
      case AppTheme.system:
        return Icons.auto_mode;
    }
  }

  // Get theme description
  String get themeDescription {
    switch (_currentTheme) {
      case AppTheme.light:
        return 'Clean and bright';
      case AppTheme.dark:
        return 'Easy on the eyes';
      case AppTheme.system:
        return 'Follow device settings';
    }
  }

  // Toggle between light and dark (useful for quick switching)
  Future<void> toggleTheme() async {
    final newTheme = _currentTheme == AppTheme.light 
        ? AppTheme.dark 
        : AppTheme.light;
    await setTheme(newTheme);
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    await setTheme(AppTheme.system);
  }

  // Clear saved preferences
  Future<void> clearThemePreference() async {
    try {
      if (_prefs != null) {
        await _prefs!.remove(_themeKey);
        _currentTheme = AppTheme.system;
        _updateSystemUIOverlay();
        notifyListeners();
        debugPrint('Theme preference cleared');
      }
    } catch (e) {
      debugPrint('Failed to clear theme preference: $e');
    }
  }
}