import 'package:flutter/material.dart';
import 'package:flutterappmedigo/Components/dropdown.dart';
import 'package:flutterappmedigo/Components/textfield.dart';
import 'dart:io'; // For file handling
import 'package:flutter/services.dart';
import 'package:flutterappmedigo/qr.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TextEditingControllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Dropdown values
  String? _gender;
  String? _maritalStatus;

  // Image variables
  File? _profileImage;

  // Define your custom colors
  final Color darkBlue = const Color(0xFF021229);
  final Color deepDarkBlue = const Color(0xFF043459);
  // For the background gradient, we use light blue shades
  static const Color lightBlueStart = Color(0xFFE3F2FD);
  static const Color lightBlueMid = Color(0xFFBBDEFB);
  static const Color lightBlueEnd = Color(0xFFFFFFFF);

  static const platform = MethodChannel('com.example.myapp/image_picker');

  Future<void> _pickImage() async {
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      if (imagePath != null) {
        setState(() {
          _profileImage = File(imagePath);
        });
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with gradient background remains the same
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: const Text("Sign Up", style: TextStyle(color: Colors.white,fontSize: 30),textAlign:TextAlign.center,),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF02597A),
                  Color(0xFF043459),
                  Color(0xFF021229),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        // Overall gradient background for the screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lightBlueStart,
              lightBlueMid,
              lightBlueEnd,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Wrap the form in a Card for a modern look
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image Upload Section
                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : null,
                          child: _profileImage == null
                              ? const Icon(Icons.add_a_photo,
                              size: 50, color: Colors.white70)
                              : null,
                          backgroundColor: deepDarkBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Other Form Fields
                      buildTextFormField(
                        controller: _nameController,
                        hintText: "Full Name",
                        prefix: const Icon(Icons.person),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      buildTextFormField(
                        controller: _nationalIdController,
                        hintText: "National ID",
                        prefix: const Icon(Icons.badge),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.length != 14
                            ? 'National ID must be 14 digits'
                            : null,
                      ),
                      buildTextFormField(
                        controller: _emailController,
                        hintText: "Email",
                        prefix: const Icon(Icons.email),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) =>
                        value!.contains('@') ? null : 'Enter a valid email',
                      ),
                      buildTextFormField(
                        controller: _passwordController,
                        hintText: "Password",
                        prefix: const Icon(Icons.lock),
                        obscureText: true,
                        validator: (value) => value!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      buildTextFormField(
                        controller: _phoneController,
                        hintText: "Phone Number",
                        prefix: const Icon(Icons.phone),
                        keyboardType: TextInputType.phone,
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter your phone' : null,
                      ),
                      buildTextFormField(
                        controller: _birthdayController,
                        hintText: "Birthday (DD/MM/YYYY)",
                        prefix: const Icon(Icons.cake),
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Birthday';
                          }
                          final RegExp dateRegex = RegExp(
                              r"^(0?[1-9]|[12][0-9]|3[01])/(0?[1-9]|1[0-2])/(19|20)\d{2}$");
                          if (!dateRegex.hasMatch(value)) {
                            return 'Enter date in DD/MM/YYYY format';
                          }
                          return null;
                        },
                      ),
                      buildDropdownField(
                        value: _gender,
                        hintText: "Gender",
                        prefixIcon: Icons.person_outline,
                        items: const ["Male", "Female"],
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                      buildTextFormField(
                        controller: _addressController,
                        hintText: "Address",
                        prefix: const Icon(Icons.home),
                        validator: (value) => value!.isEmpty
                            ? 'Please enter your Address'
                            : null,
                      ),
                      buildTextFormField(
                        controller: _cityController,
                        hintText: "City",
                        prefix: const Icon(Icons.location_city),
                        validator: (value) =>
                        value!.isEmpty ? 'Please enter your city' : null,
                      ),
                      buildDropdownField(
                        value: _maritalStatus,
                        hintText: "Marital Status",
                        prefixIcon: Icons.family_restroom,
                        items: const ["Single", "Married", "Divorced", "Widowed"],
                        onChanged: (value) {
                          setState(() {
                            _maritalStatus = value;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Generate QR Code Button as an outlined button
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: deepDarkBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                        ),
                        onPressed: () {
                          if (_nationalIdController.text.isEmpty ||
                              _emailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'National ID and Email are required!'),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenerateScreen(
                                  nationalId: _nationalIdController.text,
                                  email: _emailController.text,
                                ),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                  Text('Generate QR Code logic here!')),
                            );
                          }
                        },
                        child: Text(
                          "Generate QR Code",
                          style: TextStyle(color: darkBlue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Sign-Up Button
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showSnackBar('Registration Successful!');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: deepDarkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style:
                          TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
