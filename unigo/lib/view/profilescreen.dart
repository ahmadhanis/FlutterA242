import 'package:flutter/material.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/view/mainscreen.dart';
import 'package:unigo/view/useritemscreen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(),
      bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            // print("Tapped on index $index");
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MainScreen(user: widget.user)),
              );
            }
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserItemScreen(user: widget.user)),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user),
              label: "Your Items",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Profile",
            ),
          ]),
    );
  }
}
