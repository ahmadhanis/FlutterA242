import 'package:flutter/material.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/view/loginscreen.dart';
import 'package:unigo/view/registerscreen.dart';

class MainScreen extends StatefulWidget {
  final User user;
  const MainScreen({super.key, required this.user});

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
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              icon: const Icon(Icons.login))
        ],
      ),
      body: Center(
        child: Text(
          "Welcome ${widget.user.userName}",
          style: TextStyle(fontSize: 24, color: Colors.purple.shade600),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.user.userId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          }else{
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Add new product screen later"),
          ));
          }
        },
        backgroundColor: Colors.amber.shade900,
        child: const Icon(Icons.add),
      ),
    );
  }
}
