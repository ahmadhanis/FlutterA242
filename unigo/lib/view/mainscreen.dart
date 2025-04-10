import 'package:flutter/material.dart';
import 'package:unigo/view/registerscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Main Screen"),
        backgroundColor: Colors.amber.shade900,
      ),
      body: Center(
        child: Text(
          "Welcome to the Main Screen",
          style: TextStyle(fontSize: 24, color: Colors.purple.shade600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        },
        backgroundColor: Colors.amber.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }
}
