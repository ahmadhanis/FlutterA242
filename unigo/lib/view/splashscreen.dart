import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/view/mainscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String statusMessage = "Checking credentials...";

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), loadUserCredentials);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.amber.shade900,
              Colors.purple.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/unigo.png", scale: 3.5),
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
              const SizedBox(height: 20),
              Text(
                statusMessage,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserCredentials() async {
    setState(() {
      statusMessage = "Loading saved user data...";
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('pass') ?? '';
    bool remember = prefs.getBool('remember') ?? false;

    if (remember && email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        statusMessage = "Logging in...";
      });

      try {
        final response = await http.post(
          Uri.parse("${MyConfig.myurl}/unigo/php/login_user.php"),
          body: {'email': email, 'password': password},
        );

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            User user = User.fromJson(jsondata['data'][0]);
            _navigateToMain(user);
            return;
          }
        }
      } catch (e) {
        debugPrint("Login error: $e");
      }
    }

    // Fallback to guest user
    User guestUser = User(
      userId: "0",
      userName: "Guest",
      userEmail: "",
      userPhone: "",
      userUniversity: "",
      userAddress: "",
      userPassword: "",
    );
    _navigateToMain(guestUser);
  }

  void _navigateToMain(User user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(user: user)),
    );
  }
}
