import 'package:flutter/material.dart';

class AppThemes {
  // Light Theme - Modern Rider App Design
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme - Professional Delivery Theme
      colorScheme: const ColorScheme.light(
        // Primary: Deep Green for Delivery & Go
        primary: Color(0xFF1B5E20), // Deep Green
        onPrimary: Colors.white,
        
        // Secondary: Vibrant Orange for Action & Energy
        secondary: Color(0xFFFF6B35), // Vibrant Orange
        onSecondary: Colors.white,
        
        // Tertiary: Blue for Info & Navigation
        tertiary: Color(0xFF1565C0), // Deep Blue
        onTertiary: Colors.white,
        
        // Surfaces
        surface: Colors.white,
        onSurface: Color(0xFF1A1A1A),
        surfaceVariant: Color(0xFFF8FAFC),
        onSurfaceVariant: Color(0xFF64748B),
        
        // Background
        background: Color(0xFFF1F5F9), // Light Blue-Gray
        onBackground: Color(0xFF1A1A1A),
        
        // Error
        error: Color(0xFFDC2626),
        onError: Colors.white,
        
        // Additional colors for status
        outline: Color(0xFFE2E8F0),
        outlineVariant: Color(0xFFF1F5F9),
      ),

      // App Bar Theme - Clean & Professional
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x1A000000),
        titleTextStyle: TextStyle(
          color: Color(0xFF1A1A1A),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme - Modern with subtle shadows
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.04),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button Theme - Action-focused
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B5E20), // Primary green
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1B5E20),
          side: const BorderSide(color: Color(0xFF1B5E20), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF1B5E20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),

      // Input Decoration Theme - Clean & Modern
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFF6B35), // Orange for quick actions
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Chip Theme - For status indicators
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF1F5F9),
        deleteIconColor: const Color(0xFF64748B),
        disabledColor: const Color(0xFFE2E8F0),
        selectedColor: const Color(0xFF1565C0).withOpacity(0.12),
        secondarySelectedColor: const Color(0xFF1565C0).withOpacity(0.12),
        labelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
        secondaryLabelStyle: const TextStyle(color: Color(0xFF1A1A1A)),
        brightness: Brightness.light,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00BFA5); // Teal for online status
          }
          return const Color(0xFF94A3B8);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF00BFA5).withOpacity(0.3);
          }
          return const Color(0xFFE2E8F0);
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF1B5E20),
        linearTrackColor: Color(0xFFE2E8F0),
        circularTrackColor: Color(0xFFE2E8F0),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(color: Colors.white),
        actionTextColor: const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Dark Theme - Optimized for Night Riding
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color Scheme - Dark Mode for Night Deliveries
      colorScheme: const ColorScheme.dark(
        // Primary: Bright Green for visibility
        primary: Color(0xFF4CAF50), // Bright Green
        onPrimary: Color(0xFF0D1B2A),
        
        // Secondary: Warm Orange for contrast
        secondary: Color(0xFFFFAB40), // Amber Orange
        onSecondary: Color(0xFF0D1B2A),
        
        // Tertiary: Light Blue for info
        tertiary: Color(0xFF42A5F5), // Light Blue
        onTertiary: Color(0xFF0D1B2A),
        
        // Surfaces - Rich dark colors
        surface: Color.fromARGB(255, 9, 12, 17), // Dark Blue-Gray
        onSurface: Color(0xFFF8FAFC),
        surfaceVariant: Color(0xFF334155),
        onSurfaceVariant: Color(0xFF94A3B8),
        
        // Background
        background: Color.fromARGB(255, 1, 2, 3), // Very Dark Blue
        onBackground: Color(0xFFF8FAFC),
        
        // Error
        error: Color(0xFFEF4444),
        onError: Color(0xFF0D1B2A),
        
        // Outlines
        outline: Color(0xFF475569),
        outlineVariant: Color(0xFF334155),
      ),

      // App Bar Theme - Dark & Sleek
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x40000000),
        titleTextStyle: TextStyle(
          color: Color(0xFFF8FAFC),
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      // Card Theme - Dark with subtle elevation
      cardTheme: CardThemeData(
        color: const Color(0xFF1E293B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.black.withOpacity(0.3),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50), // Bright Green
          foregroundColor: const Color(0xFF0D1B2A),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4CAF50),
          side: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF334155),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF475569)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFAB40), // Amber for visibility
        foregroundColor: Color(0xFF0D1B2A),
        elevation: 6,
        shape: CircleBorder(),
      ),

      // Switch Theme - High contrast for night visibility
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF4CAF50); // Bright Green
          }
          return const Color(0xFF64748B);
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const Color(0xFF4CAF50).withOpacity(0.3);
          }
          return const Color(0xFF475569);
        }),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF4CAF50),
        linearTrackColor: Color(0xFF475569),
        circularTrackColor: Color(0xFF475569),
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF334155),
        contentTextStyle: const TextStyle(color: Color(0xFFF8FAFC)),
        actionTextColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Helper method to get status colors
  static Color getStatusColor(String status, {bool isDark = false}) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'available':
      case 'ready':
        return isDark ? const Color(0xFF26A69A) : const Color(0xFF00BFA5);
      case 'offline':
      case 'unavailable':
        return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
      case 'busy':
      case 'delivering':
        return isDark ? const Color(0xFFFFAB40) : const Color(0xFFFF6B35);
      case 'warning':
        return isDark ? const Color(0xFFFFC107) : const Color(0xFFFF9800);
      case 'error':
        return isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
      default:
        return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);
    }
  }

  // Payment method colors
  static Color getPaymentMethodColor(String method, {bool isDark = false}) {
    switch (method.toLowerCase()) {
      case 'cash':
        return isDark ? const Color(0xFFFFAB40) : const Color(0xFFFF8F00);
      case 'card':
        return isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);
      case 'transfer':
        return isDark ? const Color(0xFFAB47BC) : const Color(0xFF7B1FA2);
      default:
        return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    }
  }
}