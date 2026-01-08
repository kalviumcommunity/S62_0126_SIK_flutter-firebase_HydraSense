import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isAlertOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isAlertOn
          ? const Color.fromARGB(255, 255, 0, 25)
          : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAlertOn ? 'Alert Mode ON 🚨' : 'Welcome to HydraSense',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isAlertOn ? const Color.fromARGB(255, 0, 0, 0) : Colors.black,
              ),
            ),

            const Icon(Icons.water, size: 80, color: Colors.blue),
            const SizedBox(height: 30),

            // 🔔 Your existing alert toggle
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isAlertOn = !isAlertOn;
                });
              },
              child: const Text('Toggle Alert'),
            ),

            const SizedBox(height: 30),

            // 🔐 Auth buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Login'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                );
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
