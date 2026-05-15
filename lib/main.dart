import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/create_account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/new_scan_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final startLoggedIn = FirebaseAuth.instance.currentUser != null;
  runApp(CassavaGuardApp(startLoggedIn: startLoggedIn));
}

class CassavaGuardApp extends StatelessWidget {
  const CassavaGuardApp({super.key, required this.startLoggedIn});

  final bool startLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CassavaGuard',
      debugShowCheckedModeBanner: false,
      theme: buildCassavaTheme(),
      initialRoute: startLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/create-account': (_) => const CreateAccountScreen(),
        '/dashboard': (_) => const DashboardScreen(),
        '/new-scan': (_) => const NewScanScreen(),
        '/history': (_) => const HistoryScreen(),
      },
    );
  }
}
