import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: BackgroundRemovalScreen(),
    );
  }
}

class BackgroundRemovalScreen extends StatefulWidget {
  const BackgroundRemovalScreen({super.key});

  @override
  State<BackgroundRemovalScreen> createState() =>
      _BackgroundRemovalScreenState();
}

class _BackgroundRemovalScreenState extends State<BackgroundRemovalScreen> {
  File? _image;
  List? _output;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/DeepLabV3-Plus-MobileNet-Quantized.tflite",
    );
    print(res);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });

    runSegmentation(_image!);
  }

  Future<void> runSegmentation(File image) async {
    var result = await Tflite.runSegmentationOnImage(
      path: image.path,
      imageMean: 127.5,
      imageStd: 127.5,
      outputType: "png",
    );

    print("Segmentation result: $result");
    // You can use the result as a mask and overlay on original image
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Remove Background")),
      body: Center(
        child: _image == null
            ? const Text("Pick an image to remove background")
            : Image.file(_image!),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        child: const Icon(Icons.photo),
      ),
    );
  }
}
