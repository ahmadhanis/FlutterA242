import 'package:flutter/material.dart';
import 'package:volume_converter/lengthconvscreen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  TextEditingController lengthController = TextEditingController();
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  double result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Calculator",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "Length (cm)",
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "Width (cm)",
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: widthController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text(
                "Height (cm)",
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "${result.toStringAsFixed(2)} cm3",
            style: TextStyle(fontSize: 32),
          ),
          const Text("cm Cubed"),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: onPressed, child: const Text("Calculate")),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LengthConvScreen()));
              },
              child: const Text("Length Conversion"))
        ],
      )),
    );
  }

  void onPressed() {
    if (lengthController.text.isEmpty ||
        widthController.text.isEmpty ||
        heightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter all the values"),
        ),
      );
      return;
    }

    if (!isNumeric(lengthController.text) ||
        !isNumeric(widthController.text) ||
        !isNumeric(heightController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter numeric values"),
        ),
      );
      return;
    }

    double length = double.parse(lengthController.text);
    double width = double.parse(widthController.text);
    double height = double.parse(heightController.text);
    result = length * width * height;
    setState(() {});
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }
}
