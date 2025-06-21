// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:unigo/shared/myconfig.dart';
import 'package:unigo/view/loginscreen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  bool isLocating = false;

  String university = "UUM";
  final List<String> unilist = [
    "UUM",
    "USM",
    "UIA",
    "UM",
    "UTM",
    "UPM",
    "UKM",
    "UITM",
    "UNIMAS",
    "UNIMAP",
    "UTHM",
    "UCSI",
    "MMU",
    "MSU",
    "INTI",
    "HELP",
    "TAYLORS",
    "SEGI",
    "KDU",
  ];

  File? _image;
  Uint8List? webImageBytes;
  bool obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text("Register"),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber.shade900, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                GestureDetector(
                  onTap: showSelectionDialog,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _image == null
                            ? null
                            : _buildProfileImage(), // Make sure this returns ImageProvider
                        child: _image == null
                            ? const Icon(Icons.camera_alt,
                                size: 40, color: Colors.white70)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildRegistrationForm(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRegistrationForm() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(nameController, "Full Name", TextInputType.name),
              _buildTextField(
                  emailController, "Email", TextInputType.emailAddress),
              _buildPasswordField(passwordController, "Password"),
              _buildPasswordField(confirmPasswordController, "Confirm Password",
                  confirm: true),
              _buildTextField(phoneController, "Phone", TextInputType.phone),
              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Address",
                  prefixIcon: const Icon(Icons.home),
                  suffixIcon: isLocating
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location),
                          tooltip: "Use Current Location",
                          onPressed: _getCurrentAddress,
                        ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Address is required"
                    : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: university,
                decoration: const InputDecoration(
                  labelText: "University",
                  border: OutlineInputBorder(),
                ),
                items: unilist.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => university = newValue!);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text("Register"),
                  onPressed: registerUserDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text("Already have an account? Login here"),
              ),
            ],
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

  Widget _buildPasswordField(TextEditingController controller, String label,
      {bool confirm = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscurePassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon:
                Icon(obscurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => obscurePassword = !obscurePassword),
          ),
        ),
        validator: (val) {
          if (val!.isEmpty) return "$label is required";
          if (confirm && val != passwordController.text) {
            return "Passwords do not match";
          }
          return null;
        },
      ),
    );
  }

  void registerUserDialog() {
    if (_image == null) {
      _showSnackbar("Please select an image");
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Registration"),
        content: const Text("Do you want to create this account?"),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                registerUser();
              },
              child: const Text("Yes")),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
        ],
      ),
    );
  }

  void registerUser() async {
    String base64Image = base64Encode(_image!.readAsBytesSync());

    final response = await http.post(
      Uri.parse("${MyConfig.myurl}/unigo/php/register_user.php"),
      body: {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
        "phone": phoneController.text,
        "university": university,
        "address": addressController.text,
        "image": base64Image,
      },
    );

    if (response.statusCode == 200) {
      var jsondata = json.decode(response.body);
      if (jsondata['status'] == 'success') {
        _showSnackbar("Registration successful!", color: Colors.green);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        _showSnackbar("Registration failed");
      }
    } else {
      _showSnackbar("Server error, try again later");
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
            ));
  }

  Future<void> _getCurrentAddress() async {
    addressController.clear();
    setState(() {
      isLocating = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")),
          );
          setState(() => isLocating = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Location permission permanently denied. Please enable it in settings."),
          ),
        );
        setState(() => isLocating = false);
        return;
      }

      // Get location
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks[0];
      addressController.text =
          "${place.street}, ${place.postalCode} ${place.locality}, ${place.administrativeArea}";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get location: $e")),
      );
    } finally {
      setState(() {
        isLocating = false;
      });
    }
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

  ImageProvider _buildProfileImage() {
    if (_image != null) {
      if (kIsWeb) {
        return MemoryImage(webImageBytes!);
      } else {
        return FileImage(_image!);
      }
    } else {
      return const AssetImage("assets/images/profile.png");
    }
  }
}
