import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unigo/model/user.dart';
import 'package:unigo/myconfig.dart';

class NewItemScreen extends StatefulWidget {
  final User user;
  const NewItemScreen({super.key, required this.user});

  @override
  State<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends State<NewItemScreen> {
  File? _image;
  Uint8List? webImageBytes;
  TextEditingController itemController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  String delivery = "Postage";
  var deliveryOptions = [
    'Postage',
    'Pickup',
  ];
  String dropdownvalue = 'New';
  var itemstatus = [
    'New',
    'Used',
    'Refurbished',
    'Damaged',
  ];
  String dropdownvalue2 = '1';
  var itemqty = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Item"),
        backgroundColor: Colors.amber.shade900,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Card(
                  child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showSelectionDialog();
                            },
                            child: Container(
                              height: 200,
                              width: 400,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: _image == null
                                    ? const AssetImage(
                                        "assets/images/camera.png")
                                    : _buildItemImage(),
                                fit: BoxFit.scaleDown,
                              )),
                            ),
                          ),
                          TextField(
                            controller: itemController,
                            decoration: const InputDecoration(
                              labelText: "Item Name",
                            ),
                            keyboardType: TextInputType.text,
                          ),
                          TextField(
                            controller: descController,
                            decoration: const InputDecoration(
                              labelText: "Item Description",
                            ),
                            keyboardType: TextInputType.text,
                            maxLines: 5,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Flexible(
                                  flex: 1,
                                  child: TextField(
                                    controller: priceController,
                                    decoration: const InputDecoration(
                                      labelText: "Item Price (MYR)",
                                    ),
                                    keyboardType: TextInputType.number,
                                  )),
                              const SizedBox(
                                width: 8,
                              ),
                              Flexible(
                                child: DropdownButton(
                                  itemHeight: 60,
                                  value: delivery,
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  items: deliveryOptions.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    delivery = newValue!;
                                    setState(() {});
                                  },
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Flexible(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Item Status"),
                                    DropdownButton(
                                      itemHeight: 60,
                                      value: dropdownvalue,
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: itemstatus.map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        dropdownvalue = newValue!;
                                        print(dropdownvalue);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Item Quantity"),
                                    DropdownButton(
                                      itemHeight: 60,
                                      value: dropdownvalue2,
                                      underline: const SizedBox(),
                                      isExpanded: true,
                                      icon:
                                          const Icon(Icons.keyboard_arrow_down),
                                      items: itemqty.map((String items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        dropdownvalue2 = newValue!;
                                        print(dropdownvalue2);
                                        setState(() {});
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber.shade900,
                                  padding: const EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Text("Add Item"),
                                onPressed: () {
                                  insertItemDialog();
                                }),
                          )
                        ],
                      )))),
        ),
      ),
    );
  }

  ImageProvider _buildItemImage() {
    if (_image != null) {
      if (kIsWeb) {
        // For web, use MemoryImage.
        return MemoryImage(webImageBytes!);
      } else {
        // For mobile, convert XFile to File.
        return FileImage(File(_image!.path));
      }
    }
    return const AssetImage('assets/images/camera.png');
  }

  void showSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: const Text(
              "Select from",
              style: TextStyle(),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectFromCamera();
                    },
                    child: const Text("From Camera")),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _selectfromGallery();
                    },
                    child: const Text("From Gallery"))
              ],
            ));
      },
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
      if (kIsWeb) {
        // Read image bytes for web.
        webImageBytes = await pickedFile.readAsBytes();
      }
      setState(() {});
    } else {
      print('No image selected.');
    }
  }

  Future<void> _selectfromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 800,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      setState(() {});
    }
  }

  void insertItemDialog() {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an image"),
        ),
      );
      return;
    }
    if (itemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter item name"),
        ),
      );
      return;
    }
    if (descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter item description"),
        ),
      );
      return;
    }
    if (priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter item price"),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are sure?"),
          content: const Text("Do you want to add this item?"),
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                registerItem();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void registerItem() {
    String itemName = itemController.text;
    String itemDesc = descController.text;
    String itemStatus = dropdownvalue;
    String itemQty = dropdownvalue2;
    String base64Image = base64Encode(_image!.readAsBytesSync());
    String userId = widget.user.userId.toString();
    String itemPrice = priceController.text;
    http.post(Uri.parse("${MyConfig.myurl}/unigo/php/insert_item.php"), body: {
      "name": itemName,
      "description": itemDesc,
      "status": itemStatus,
      "quantity": itemQty,
      "image": base64Image,
      "userid": userId,
      "delivery": delivery,
      "price": itemPrice,
    }).then((response) {
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Item added successfully"),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to add item"),
            ),
          );
        }
      }
    });
  }
}
