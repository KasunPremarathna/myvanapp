import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/setup/privacy_policy_screen.dart';
import 'theme/app_theme.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Timezone for notifications
  tz.initializeTimeZones();

  // Local notifications init
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  // OneSignal Init
  OneSignal.Debug.setLogLevel(OSLogLevel.none);
  OneSignal.initialize("fd860c06-8fb5-420e-867f-1abb6a85f9c2");
  
  // Schedule/Reset 5-day re-engagement reminder
  await NotificationService.scheduleReEngagementReminder();

  // Check Privacy Acceptance
  final prefs = await SharedPreferences.getInstance();
  final bool isPrivacyAccepted = prefs.getBool('privacy_accepted') ?? false;

  runApp(MyVanApp(isPrivacyAccepted: isPrivacyAccepted));
}

class MyVanApp extends StatelessWidget {
  final bool isPrivacyAccepted;
  const MyVanApp({super.key, required this.isPrivacyAccepted});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'My Van',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: isPrivacyAccepted 
            ? const AuthWrapper() 
            : const PrivacyPolicyScreen(nextScreen: AuthWrapper()),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D7A6C),
            body: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
