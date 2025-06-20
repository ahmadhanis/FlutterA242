// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/myconfig.dart';

class NewItemScreen extends StatefulWidget {
  final User user;
  const NewItemScreen({super.key, required this.user});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final itemController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();

  File? _image;
  Uint8List? webImageBytes;

  final deliveryOptions = ['Postage', 'Pickup'];
  String delivery = 'Postage';

  final itemStatusOptions = ['New', 'Used', 'Refurbished', 'Damaged'];
  String itemStatus = 'New';

  final qtyOptions = List.generate(10, (index) => '${index + 1}');
  String itemQty = '1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text("Add New Item"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade900, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: showSelectionDialog,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: _image == null
                              ? const AssetImage("assets/images/camera.png")
                              : _buildItemImage(),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                      itemController, "Item Name", TextInputType.text),
                  _buildTextField(
                      descController, "Item Description", TextInputType.text,
                      maxLines: 4),
                  _buildTextField(
                      priceController, "Price (MYR)", TextInputType.number),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: delivery,
                    decoration: const InputDecoration(
                      labelText: "Delivery Method",
                      border: OutlineInputBorder(),
                    ),
                    items: deliveryOptions.map((String value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (val) => setState(() => delivery = val!),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: itemStatus,
                          decoration: const InputDecoration(
                            labelText: "Item Status",
                            border: OutlineInputBorder(),
                          ),
                          items: itemStatusOptions.map((String value) {
                            return DropdownMenuItem(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (val) => setState(() => itemStatus = val!),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: itemQty,
                          decoration: const InputDecoration(
                            labelText: "Quantity",
                            border: OutlineInputBorder(),
                          ),
                          items: qtyOptions.map((String value) {
                            return DropdownMenuItem(
                                value: value, child: Text(value));
                          }).toList(),
                          onChanged: (val) => setState(() => itemQty = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_box),
                      label: const Text("Add Item"),
                      onPressed: insertItemDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, TextInputType type,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (val) => val!.isEmpty ? "$label is required" : null,
      ),
    );
  }

  void insertItemDialog() {
    if (_image == null) {
      _showSnackbar("Please select an image");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add this item?"),
        content: const Text("Are you sure you want to submit this item?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerItem();
            },
            child: const Text("Yes"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void registerItem() async {
    final base64Image = base64Encode(_image!.readAsBytesSync());

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/unigo/php/insert_item.php"),
      body: {
        "name": itemController.text,
        "description": descController.text,
        "status": itemStatus,
        "quantity": itemQty,
        "image": base64Image,
        "userid": widget.user.userId.toString(),
        "delivery": delivery,
        "price": priceController.text,
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        _showSnackbar("Item added successfully", color: Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackbar("Failed to add item");
      }
    } else {
      _showSnackbar("Server error. Please try again later.");
    }
  }

  void _showSnackbar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Image From"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectFromCamera();
              },
              child: const Text("Camera"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _selectFromGallery();
              },
              child: const Text("Gallery"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  Future<void> _selectFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();
      setState(() {});
    }
  }

  ImageProvider _buildItemImage() {
    return kIsWeb
        ? MemoryImage(webImageBytes!)
        : FileImage(_image!) as ImageProvider;
  }
}
