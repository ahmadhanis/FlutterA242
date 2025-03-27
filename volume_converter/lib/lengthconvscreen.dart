import 'package:flutter/material.dart';

class LengthConvScreen extends StatefulWidget {
  const LengthConvScreen({super.key});

  @override
  State<LengthConvScreen> createState() => _LengthConvScreenState();
}

class _LengthConvScreenState extends State<LengthConvScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text("Length Converter")),
    );
  }
}
