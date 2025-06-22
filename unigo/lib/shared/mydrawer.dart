// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/animated_route.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/view/favscreen.dart';
import 'package:unigo/view/loginscreen.dart';
import 'package:unigo/view/mainscreen.dart';
import 'package:unigo/view/messagescreen.dart';
import 'package:unigo/view/profilescreen.dart';
import 'package:unigo/view/useritemscreen.dart';
import 'package:http/http.dart' as http;

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
              gradient: LinearGradient(
                colors: [Colors.amber.shade900, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: ClipOval(
                    child: FutureBuilder<bool>(
                      future: _checkNetworkImage(
                          "${MyConfig.myurl}unigo/assets/images/profiles/${widget.user.userId}.png"),
                      builder: (context, snapshot) {
                        if (widget.user.userId == "0") {
                          return Image.asset("assets/images/unigo.png",
                              fit: BoxFit.cover, width: 80, height: 80);
                        } else if (snapshot.connectionState ==
                                ConnectionState.done &&
                            snapshot.data == true) {
                          return Image.network(
                            "${MyConfig.myurl}unigo/assets/images/profiles/${widget.user.userId}.png",
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          );
                        } else {
                          return Image.asset("assets/images/unigo.png",
                              fit: BoxFit.cover, width: 80, height: 80);
                        }
                      },
                    ),
                  ),
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
            title: const Text("Market Place"),
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
                  AnimatedRoute.slideFromRight(const LoginScreen()),
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
            leading: const Icon(Icons.favorite),
            title: const Text("Your Favorites"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                AnimatedRoute.slideFromRight(FavScreen(user: widget.user)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Profile"),
            onTap: () {
              if (widget.user.userId == "0") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please register/login use this feature."),
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
              if (widget.user.userId == "0") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please register/login an account."),
                ));
                Navigator.push(
                  context,
                  AnimatedRoute.slideFromRight(const LoginScreen()),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Confirm Logout"),
                    content: const Text(
                        "Are you sure you want to logout? Your credentials will be cleared."),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context), // Cancel
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          // Clear SharedPreferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.remove('email');
                          await prefs.remove('pass');
                          await prefs.remove('remember');

                          // Close dialog
                          Navigator.pop(context);

                          // Navigate to LoginScreen
                          Navigator.pushAndRemoveUntil(
                            context,
                            AnimatedRoute.slideFromRight(const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text("Logout",
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
          )
        ],
      ),
    );
  }

  Future<bool> _checkNetworkImage(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
