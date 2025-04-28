import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:unigo/model/user.dart';
import 'package:unigo/myconfig.dart';
import 'package:unigo/view/mainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unigo/view/registerscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isChecked = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
        backgroundColor: Colors.amber.shade900,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          Image.asset(
            "assets/images/unigo.png",
            height: 200,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: "Email",
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                      obscureText: true,
                    ),
                    Row(
                      children: [
                        const Text("Remember Me"),
                        Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                              String email = emailController.text;
                              String password = passwordController.text;
                              if (isChecked) {
                                if (email.isEmpty && password.isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Please fill all fields"),
                                    backgroundColor: Colors.red,
                                  ));
                                  isChecked = false;
                                  return;
                                }
                              }
                              storeCredentials(email, password, isChecked);
                            }),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () {
                          loginUser();
                        },
                        child: const Text("Login"))
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()),
                );
              },
              child: const Text("Register an account?")),
          const SizedBox(height: 10),
          GestureDetector(onTap: () {}, child: const Text("Forgot Password?")),
        ],
      )),
    );
  }

  void loginUser() {
    String email = emailController.text;
    String password = passwordController.text;

    if (email.isEmpty && password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ));
      return;
    }
    http.post(Uri.parse("${MyConfig.myurl}/unigo/php/login_user.php"), body: {
      "email": email,
      "password": password,
    }).then((response) {
      //  print(response.body);
      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          var userdata = jsondata['data'];
          User user = User.fromJson(userdata[0]);
          print(user.userName);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text("Welcome ${user.userName} from ${user.userUniversity}"),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MainScreen(
                      user: user,
                    )),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed!"),
            backgroundColor: Colors.red,
          ));
        }
      }
    });
  }

  Future<void> storeCredentials(
      String email, String password, bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      await prefs.setBool('remember', isChecked);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pref Stored Success!"),
        backgroundColor: Colors.green,
      ));
    } else {
      await prefs.remove('email');
      await prefs.remove('pass');
      await prefs.remove('remember');
      emailController.clear();
      passwordController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Pref Removed!"),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('pass');
    bool? isChecked = prefs.getBool('remember');
    if (email != null && password != null && isChecked != null) {
      emailController.text = email;
      passwordController.text = password;
      setState(() {
        this.isChecked = isChecked!;
      });
    } else {
      emailController.clear();
      passwordController.clear();
      isChecked = false;
      setState(() {});
    }
  }
}
