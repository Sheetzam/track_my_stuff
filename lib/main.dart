import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hello World',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Track My Stuff'),
        ),
        body: Center(
          // Wrapped in Semantics with identifier as per our AGENT_RULES.md
          child: Semantics(
            identifier: 'hello_world_text',
            child: const Text(
              'Hello World!',
              style: TextStyle(fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}
