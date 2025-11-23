import 'package:bezoni/services/theme_service.dart';
import 'package:bezoni/services/socket_service.dart'; // Add this
import 'package:bezoni/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bezoni/core/api_client.dart';
import 'package:bezoni/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API client
  await ApiClient().initialize();
  
  // Initialize theme service
  final themeService = ThemeService();
  await themeService.init();
  
  // Initialize Socket.IO service (will connect when user logs in)
  final socketService = SocketService();
  
  runApp(BezoniApp(
    themeService: themeService,
    socketService: socketService,
  ));
}

class BezoniApp extends StatelessWidget {
  final ThemeService themeService;
  final SocketService socketService;
  
  const BezoniApp({
    Key? key,
    required this.themeService,
    required this.socketService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap with MultiProvider to provide both services
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeService>.value(value: themeService),
        Provider<SocketService>.value(value: socketService),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Bezoni',
            debugShowCheckedModeBanner: false,
            
            // Use the theme service to get current theme mode
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            
            // Routes
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            
            // This ensures the Provider is available throughout navigation
            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}