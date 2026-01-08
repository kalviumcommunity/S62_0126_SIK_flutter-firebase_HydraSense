import 'package:flutter/material.dart';

// --------------------
// Stateless Widget (Screen + Header)
// --------------------
class StatelessStatefulDemo extends StatelessWidget {
  const StatelessStatefulDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Color Change Demo',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ColorChanger(), // Stateful widget used here
          ],
        ),
      ),
    );
  }
}

// --------------------
// Stateful Widget (Color Change Logic)
// --------------------
class ColorChanger extends StatefulWidget {
  const ColorChanger({super.key});

  @override
  State<ColorChanger> createState() => _ColorChangerState();
}

class _ColorChangerState extends State<ColorChanger> {
  Color boxColor = Colors.blue;

  void changeColor() {
    setState(() {
      boxColor = boxColor == Colors.blue
          ? const Color.fromARGB(255, 255, 0, 0)
          : Colors.blue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 120, width: 120, color: boxColor),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: changeColor,
          child: const Text('Change Color'),
        ),
      ],
    );
  }
}
