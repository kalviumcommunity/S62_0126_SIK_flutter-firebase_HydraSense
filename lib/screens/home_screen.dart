import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcomescreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 8, 84, 117),
            Color.fromARGB(255, 31, 131, 194),
            Color.fromARGB(255, 1, 31, 43),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,

        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();

            if (!context.mounted) return;

            // ✅ THIS IS WHAT YOU WERE MISSING
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const WelcomeScreen(),
              ),
              (_) => false,
            );
          },
          child: const Icon(Icons.logout),
        ),

        body: Center(
          child: Text(
            'Welcome, ${user?.email}',
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
