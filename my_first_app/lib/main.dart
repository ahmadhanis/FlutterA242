import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  TextEditingController mytextctrl = TextEditingController();
  TextEditingController numactrl = TextEditingController();
  TextEditingController numbctrl = TextEditingController();
  int result = 0;

  String mydata = "";
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My App'),
          backgroundColor: Colors.amber,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Welcome to My App"),
              const Text("Flutter is awesome"),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Hello"),
                  Text("World"),
                  Text("Flutter"),
                ],
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: mytextctrl,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    mydata = mytextctrl.text;
                    print(mydata);
                    setState(() {});
                  },
                  child: const Text("CLICK ME")),
              Text(mydata),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                      width: 100,
                      child: TextField(
                        controller: numactrl,
                      )),
                  SizedBox(
                      width: 100,
                      child: TextField(
                        controller: numbctrl,
                      )),
                  ElevatedButton(
                      onPressed: calculateMe, child: const Text("+")),
                  Text(result.toString())
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void calculateMe() {
    int num1 = int.parse(numactrl.text);
    int num2 = int.parse(numbctrl.text);
    result = num1 + num2;
    setState(() {});
  }
}
