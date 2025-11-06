import 'package:flutter/material.dart';

// Extension for easy access to theme colors
extension ThemeExtensions on BuildContext {
  // Quick access to theme
  ThemeData get theme => Theme.of(this);
  
  // Quick access to color scheme
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  // Quick access to text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Check if current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  // Common colors with theme awareness
  Color get primaryColor => colors.primary;
  Color get backgroundColor => colors.background;
  Color get surfaceColor => colors.surface;
  Color get cardColor => isDarkMode ? const Color(0xFF1E293B) : Colors.white;
  Color get textColor => colors.onSurface;
  Color get subtitleColor => colors.onSurface.withOpacity(0.6);
  Color get dividerColor => isDarkMode ? const Color(0xFF475569) : const Color(0xFFE2E8F0);
  Color get shadowColor => isDarkMode 
      ? Colors.black.withOpacity(0.3) 
      : Colors.black.withOpacity(0.1);
  
  // Status colors that work in both themes
  Color get successColor => isDarkMode ? const Color(0xFF4CAF50) : const Color(0xFF1B5E20);
  Color get errorColor => isDarkMode ? const Color(0xFFEF4444) : const Color(0xFFDC2626);
  Color get warningColor => isDarkMode ? const Color(0xFFFFAB40) : const Color(0xFFFF9800);
  Color get infoColor => isDarkMode ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);
}

// Custom theme-aware widgets
class ThemeAwareCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? elevation;
  final BorderRadius? borderRadius;

  const ThemeAwareCard({
    Key? key,
    required this.child,
    this.padding,
    this.onTap,
    this.elevation,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: context.shadowColor,
            blurRadius: elevation ?? 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: cardChild,
        ),
      );
    }

    return cardChild;
  }
}

class ThemeAwareButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  final bool isOutlined;
  final EdgeInsetsGeometry? padding;

  const ThemeAwareButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isOutlined = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? context.primaryColor;
    final fgColor = textColor ?? (context.isDarkMode ? Colors.black : Colors.white);

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, color: bgColor) : const SizedBox.shrink(),
        label: Text(
          text,
          style: TextStyle(color: bgColor, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: bgColor),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: fgColor),
        label: Text(text, style: TextStyle(color: fgColor, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        text,
        style: TextStyle(color: fgColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Theme-aware status indicator
class StatusIndicator extends StatelessWidget {
  final bool isOnline;
  final String label;
  final double size;

  const StatusIndicator({
    Key? key,
    required this.isOnline,
    required this.label,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isOnline ? context.successColor : Colors.grey,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: context.textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Theme-aware section header
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    Key? key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textColor,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.subtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// Helper methods for consistent theming
class ThemeUtils {
  // Get appropriate icon color based on state
  static Color getIconColor(BuildContext context, {bool isActive = false, Color? activeColor}) {
    if (isActive) {
      return activeColor ?? context.primaryColor;
    }
    return context.isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;
  }

  // Get appropriate button elevation based on theme
  static double getButtonElevation(BuildContext context) {
    return context.isDarkMode ? 4 : 2;
  }

  // Get appropriate card elevation based on theme
  static double getCardElevation(BuildContext context) {
    return context.isDarkMode ? 8 : 4;
  }

  // Create theme-aware gradient
  static Gradient createGradient(BuildContext context, Color primaryColor) {
    if (context.isDarkMode) {
      return LinearGradient(
        colors: [
          primaryColor.withOpacity(0.8),
          primaryColor.withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    
    return LinearGradient(
      colors: [primaryColor, primaryColor.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Create theme-aware shadow
  static List<BoxShadow> createShadow(BuildContext context, {double elevation = 4}) {
    return [
      BoxShadow(
        color: context.shadowColor,
        blurRadius: elevation * 2,
        offset: Offset(0, elevation / 2),
      ),
    ];
  }
}