import 'package:flutter/material.dart';

class CounterApp extends StatefulWidget {
  const CounterApp({super.key});

  @override
  State<CounterApp> createState() => _CounterAppState();
}

class _CounterAppState extends State<CounterApp> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _decrement() {
    setState(() {
      _counter--;
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Позволяет прокручивать при нехватке места
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const Text(
                  'Counter',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Current Count:',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_counter',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  key: const Key('counterText'),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _decrement,
                      icon: const Icon(Icons.remove),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _increment,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
