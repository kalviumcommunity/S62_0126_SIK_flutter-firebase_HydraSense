import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/landing_pager.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'state/risk_state_provider.dart';
import 'services/risk_firestore_service.dart';
import 'state/demo_state_provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🧪 DEMO: main() started');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RiskStateProvider(RiskFirestoreService()),
        ),
        ChangeNotifierProvider(
          create: (_) {
            print('🧪 DEMO: DemoStateProvider initialized');
            return DemoStateProvider();
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<DemoStateProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HydraSense',
      home: SplashScreen(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasData) {
              return const HomeScreen();
            }

            return const LandingPager();
          },
        ),
      ),
    );
  }
}
