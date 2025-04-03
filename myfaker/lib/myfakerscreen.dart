import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyFakerScreen extends StatefulWidget {
  const MyFakerScreen({super.key});

  @override
  State<MyFakerScreen> createState() => _MyFakerScreenState();
}

class _MyFakerScreenState extends State<MyFakerScreen> {
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('MyFaker'),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(onPressed: onPressed, child: const Text("Load Data")),
          SizedBox(
            width: 300,
            child: TextField(
              maxLines: 6,
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Result',
              ),
            ),
          )
        ],
      )),
    );
  }

  Future<void> onPressed() async {
    var response =
        await http.get(Uri.parse('https://slumberjer.com/myfaker/myfaker.php'));
    // log(response.statusCode.toString());
    print(response.body.toString());
    if (response.statusCode == 200) {
      var resparr = json.decode(response.body);
      print(resparr['status']);
      print(resparr['data'][0]['name']);
      print(resparr['data'][0]['email']);
      print(resparr['data'][0]['phone']);
      print(resparr['data'][0]['address']);
      controller.text = resparr['data'][0]['name'] +
          "\n" +
          resparr['data'][0]['email'] +
          "\n" +
          resparr['data'][0]['phone'] +
          "\n" +
          resparr['data'][0]['address'];
      setState(() {});
    } else {
      controller.text = "Error";
      setState(() {});
    }
  }
}
