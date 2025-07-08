import 'package:elite_pathshala/src/features/auth/auth_service.dart';
import 'package:elite_pathshala/src/features/auth/presentation/login_page.dart';
import 'package:elite_pathshala/src/features/auth/presentation/signup_page.dart';
import 'package:elite_pathshala/src/features/bookings/presentation/bookings_page.dart';
import 'package:elite_pathshala/src/features/chat/presentation/chat_page.dart';
import 'package:elite_pathshala/src/features/free_exams/presentation/free_exams_page.dart';
import 'package:elite_pathshala/src/features/home/presentation/home_page.dart';
import 'package:elite_pathshala/src/features/home/presentation/main_scaffold.dart';
import 'package:elite_pathshala/src/features/notifications/presentation/notifications_page.dart';
import 'package:elite_pathshala/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:elite_pathshala/src/features/orientations/presentation/orientations_page.dart';
import 'package:elite_pathshala/src/features/privacy/presentation/privacy_policy_page.dart';
import 'package:elite_pathshala/src/features/profile/presentation/profile_page.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initializeAuth();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    AuthService.setNavigatorKey(navigatorKey);
    return MaterialApp(
      title: 'Elite Pathshala',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const AuthGuard(child: MainScaffold()),
        '/profile': (context) => const AuthGuard(child: ProfilePage()),
        '/bookings': (context) => const AuthGuard(child: BookingsPage()),
        '/notifications': (context) => const AuthGuard(child: NotificationsPage()),
        '/orientations': (context) => const AuthGuard(child: OrientationsPage()),
        '/free-exams': (context) => const AuthGuard(child: FreeExamsPage()),
        '/privacy': (context) => const PrivacyPolicyPage(),
      },
    );
  }
} 