import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:unigo/model/user.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/shared/mydrawer.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String name, phone, address;
  File? _image;
  Uint8List? webImageBytes;

  @override
  void initState() {
    super.initState();
    name = widget.user.userName ?? '-';
    phone = widget.user.userPhone ?? '-';
    address = widget.user.userAddress ?? '-';
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.amber.shade900,
      ),
      drawer: MyDrawer(user: user),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _changeProfileImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null
                        ? FileImage(_image!)
                        : NetworkImage(
                            "${MyConfig.myurl}unigo/assets/images/profiles/${user.userId}.png",
                          ) as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  user.userUniversity ?? 'No University',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Divider(height: 30, thickness: 1),
                _editableTile(
                    Icons.email, "Email", user.userEmail ?? '-', null),
                _editableTile(Icons.phone, "Phone", phone, () {
                  _editField("Phone Number", phone,
                      (val) => setState(() => phone = val));
                }),
                _editableTile(Icons.home, "Address", address, () {
                  _editField("Address", address,
                      (val) => setState(() => address = val));
                }),
                _editableTile(Icons.person, "Name", name, () {
                  _editField(
                      "Full Name", name, (val) => setState(() => name = val));
                }),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text("Date Registered"),
                  subtitle: Text(_formatDate(user.userDatereg)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _editableTile(
      IconData icon, String title, String subtitle, VoidCallback? onEdit) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: onEdit != null
          ? IconButton(icon: const Icon(Icons.edit), onPressed: onEdit)
          : null,
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';
    try {
      DateTime localDate = DateTime.parse(dateString).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(localDate);
    } catch (_) {
      return '-';
    }
  }

  void _editField(String label, String initialValue, Function(String) onSave) {
    TextEditingController controller =
        TextEditingController(text: initialValue);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit $label"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter $label"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onSave(controller.text.trim());
              updateProfile();
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  void _changeProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      maxHeight: 600,
      maxWidth: 600,
    );

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      if (kIsWeb) webImageBytes = await pickedFile.readAsBytes();

      setState(() {});
      updateProfile();
    }
  }

  void updateProfile() async {
    String base64Image = "NA";

    if (_image != null) {
      base64Image = base64Encode(_image!.readAsBytesSync());
    }

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/unigo/php/update_profile.php"),
      body: {
        "userid": widget.user.userId,
        "name": name,
        "phone": phone,
        "address": address,
        "image": base64Image,
      },
    );

    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      if (jsonData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile updated successfully"),
          backgroundColor: Colors.green,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Update failed. Please try again."),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Server error. Please try later."),
        backgroundColor: Colors.red,
      ));
    }
  }
}
