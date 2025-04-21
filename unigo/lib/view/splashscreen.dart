import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/myconfig.dart';
import 'package:unigo/view/mainscreen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadUserCredentials();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const MainScreen()),
    //   );
    // });
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
              const CircularProgressIndicator(
                backgroundColor: Colors.white,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadUserCredentials() async {
    print("HELLOOO");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String password = (prefs.getString('pass')) ?? '';
    bool rem = (prefs.getBool('remember')) ?? false;

    print("EMAIL: $email");
    print("PASSWORD: $password");
    print("ISCHECKED: $rem");
    if (rem == true) {
      http.post(Uri.parse("${MyConfig.myurl}/unigo/php/login_user.php"), body: {
        "email": email,
        "password": password,
      }).then((response) {
        print(response.body);
        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            var userdata = jsondata['data'];
            User user = User.fromJson(userdata[0]);
            print(user.userName);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          } else {
            User user = User(
              userId: "0",
              userName: "Guest",
              userEmail: "",
              userPhone: "",
              userUniversity: "",
              userAddress: "",
              userPassword: "",
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(user: user)),
            );
          }
        }
      });
    } else {
      User user = User(
        userId: "0",
        userName: "Guest",
        userEmail: "",
        userPhone: "",
        userUniversity: "",
        userAddress: "",
        userPassword: "",
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(user: user)),
      );
    }
  }
}
