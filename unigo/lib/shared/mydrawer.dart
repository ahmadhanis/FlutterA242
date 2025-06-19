import 'package:flutter/material.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/animated_route.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/view/loginscreen.dart';
import 'package:unigo/view/mainscreen.dart';
import 'package:unigo/view/messagescreen.dart';
import 'package:unigo/view/profilescreen.dart';
import 'package:unigo/view/registerscreen.dart';
import 'package:unigo/view/useritemscreen.dart';

class MyDrawer extends StatefulWidget {
  final User user;

  const MyDrawer({super.key, required this.user});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber.shade900,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: widget.user.userId == "0"
                      ? const AssetImage("assets/images/user.png")
                      : NetworkImage(
                          "${MyConfig.myurl}unigo/assets/images/profiles/${widget.user.userId}.png",
                        ) as ImageProvider<Object>,
                ),
                const SizedBox(height: 10),
                Text(
                  widget.user.userName ?? "Guest",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(MainScreen(user: widget.user)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text("Your Items"),
            onTap: () {
              Navigator.pop(context);
              if (widget.user.userId == "0") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please register an account to add items."),
                ));
                Navigator.push(
                  context,
                  AnimatedRoute.slideFromRight(const RegisterScreen()),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  AnimatedRoute.slideFromRight(
                      UserItemScreen(user: widget.user)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Profile"),
            onTap: () {
              if (widget.user.userId == "0") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text("Please register/login an account to add items."),
                ));
                Navigator.push(
                  context,
                  AnimatedRoute.slideFromRight(const LoginScreen()),
                );
              } else {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  AnimatedRoute.slideFromRight(
                      ProfileScreen(user: widget.user)),
                );
              }
            },
          ),
          ListTile(
              leading: const Icon(Icons.message),
              title: const Text("Messages"),
              onTap: () {
                if (widget.user.userId == "0") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                        "Please register/login an account to use this feature."),
                  ));
                  Navigator.push(
                    context,
                    AnimatedRoute.slideFromRight(const LoginScreen()),
                  );
                } else {
                  Navigator.pop(context); // Closes drawer
                  Navigator.push(
                    context,
                    AnimatedRoute.slideFromRight(MessageScreen(
                      user: widget.user,
                    )),
                  );
                }
              }),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            onTap: () {
              Navigator.push(
                context,
                AnimatedRoute.slideFromRight(const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
