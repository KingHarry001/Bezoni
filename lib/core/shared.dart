import 'package:flutter/material.dart';

/// Shared utility functions and widgets for the Bezoni app

/// Build a standard app bar for the app
PreferredSizeWidget buildAppBar({
  String? title,
  List<Widget>? actions,
  Widget? leading,
  bool automaticallyImplyLeading = true,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    leading: leading ??
        (automaticallyImplyLeading
            ? null
            : Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.apps, color: Colors.white),
              )),
    title: title != null
        ? Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          )
        : const Text(
            'Bezoni',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
    actions: actions,
    iconTheme: const IconThemeData(color: Colors.black),
  );
}

/// Show a loading dialog
void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2ECC40)),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Show a success dialog
void showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF2ECC40), size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismiss != null) onDismiss();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// Show an error dialog
void showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onDismiss,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismiss != null) onDismiss();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

/// Show a confirmation dialog
Future<bool?> showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2ECC40),
            ),
            child: Text(confirmText),
          ),
        ],
      );
    },
  );
}

/// Show a snackbar message
void showSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : const Color(0xFF2ECC40),
      behavior: SnackBarBehavior.floating,
      duration: duration,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

/// Format currency
String formatCurrency(double amount, {String symbol = '₦'}) {
  return '$symbol${amount.toStringAsFixed(2).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
}

/// Validate email
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Validate phone number
bool isValidPhone(String phone) {
  return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
}

/// Get greeting based on time of day
String getGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good Morning';
  } else if (hour < 17) {
    return 'Good Afternoon';
  } else {
    return 'Good Evening';
  }
}

/// Format date
String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

/// Format time
String formatTime(DateTime time) {
  final hour = time.hour > 12 ? time.hour - 12 : time.hour;
  final period = time.hour >= 12 ? 'PM' : 'AM';
  return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
}

/// Format date and time
String formatDateTime(DateTime dateTime) {
  return '${formatDate(dateTime)} at ${formatTime(dateTime)}';
}