import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text('HydraSense'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isAlertOn ? 'Alert Mode ON 🚨' : 'Welcome to HydraSense',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isAlertOn ? Colors.red : Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Icon(
              Icons.water,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isAlertOn = !isAlertOn;
                });
              },
              child: const Text('Toggle Alert'),
            ),
          ],
        ),
      ),
    );
  }
}
