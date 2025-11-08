import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'Login.dart';
import 'qr.dart';
import 'Components/dropdown.dart';
import 'Components/textfield.dart';
import 'translation_provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nationalIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _cigsPerDayController = TextEditingController();
  final TextEditingController _doctorEmailController = TextEditingController();

  String _gender = '';
  String _maritalStatus = '';
  String _bloodGroup = '';
  bool _currentSmoker = false;
  File? _profileImage;

  static const platform = MethodChannel('com.example.myapp/image_picker');

  Future<void> _pickImage() async {
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      if (imagePath != null) {
        String realPath = imagePath.startsWith('content://')
            ? await platform.invokeMethod('getAbsolutePath', imagePath)
            : imagePath;
        setState(() {
          _profileImage = File(realPath);
        });
      }
    } on PlatformException catch (e) {
      _showSnackBar('Failed to pick image: ${e.message}');
    }
  }

  String formatDateForBackend(String inputDate) {
    try {
      final DateTime parsed = DateFormat('yyyy-MM-dd').parseStrict(inputDate);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (e) {
      throw FormatException("Invalid date format. Use yyyy-MM-dd.");
    }
  }

  String? requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> registerUser() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Please complete the form correctly.");
      return;
    }

    if (_gender.isEmpty || _bloodGroup.isEmpty || _maritalStatus.isEmpty) {
      _showSnackBar("Please select gender, blood group, and marital status.");
      return;
    }

    if (_currentSmoker) {
      final cigs = _cigsPerDayController.text.trim();
      if (cigs.isEmpty || int.tryParse(cigs) == null || int.parse(cigs) <= 0) {
        _showSnackBar("Please enter valid cigs per day for smokers.");
        return;
      }
    } else {
      _cigsPerDayController.text = "0";
    }

    String formattedDate;
    try {
      formattedDate = formatDateForBackend(_birthdayController.text);
    } catch (e) {
      _showSnackBar(e.toString());
      return;
    }

    // Prepare the body of the request
    final url = Uri.parse('http://10.0.2.2:8000/users/');
    final bytes = _profileImage != null ? await _profileImage!.readAsBytes() : null;
    final base64Image = bytes != null ? base64Encode(bytes) : null; // Send null if no image is provided

    final body = jsonEncode({
      "national_id": _nationalIdController.text,
      "full_name": _nameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "birthdate": formattedDate,
      "gender": _gender.toLowerCase(),
      "phone_number": _phoneController.text,
      "blood_group": _bloodGroup,
      "address": _addressController.text,
      "region": _regionController.text,
      "city": _cityController.text,
      "marital_status": _maritalStatus.toLowerCase(),
      "profile_photo": base64Image, // Send null or empty string if no image is selected
      "current_smoker": _currentSmoker,
      "cigs_per_day": int.parse(_cigsPerDayController.text),
      "doctoremail": _doctorEmailController.text.trim(),
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showSnackBar("Registration successful.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        _showSnackBar("Registration failed: ${response.body}");
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final t = provider.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("sign_up"), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF043459),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => provider.toggleLanguage(),
            tooltip: "Switch Language",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                  child: _profileImage == null
                      ? const Icon(Icons.add_a_photo, size: 40, color: Colors.white70)
                      : null,
                  backgroundColor: const Color(0xFF043459),
                ),
              ),
              const SizedBox(height: 20),
              buildTextFormField(controller: _nameController, hintText: t("full_name"), prefix: const Icon(Icons.person), validator: requiredValidator),
              buildTextFormField(controller: _nationalIdController, hintText: t("national_id"), prefix: const Icon(Icons.badge), validator: requiredValidator),
              buildTextFormField(controller: _emailController, hintText: t("email"), prefix: const Icon(Icons.email), validator: requiredValidator),
              buildTextFormField(controller: _passwordController, hintText: t("password"), obscureText: true, prefix: const Icon(Icons.lock), validator: requiredValidator),
              buildTextFormField(controller: _phoneController, hintText: t("phone_number"), prefix: const Icon(Icons.phone), validator: requiredValidator),
              buildTextFormField(
                controller: _birthdayController,
                hintText: t("birthday"),
                prefix: const Icon(Icons.cake),
                validator: requiredValidator,
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1800),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
                  }
                },
              ),
              buildTextFormField(controller: _regionController, hintText: t("region"), prefix: const Icon(Icons.map), validator: requiredValidator),
              buildTextFormField(controller: _addressController, hintText: t("address"), prefix: const Icon(Icons.home), validator: requiredValidator),
              buildTextFormField(controller: _cityController, hintText: t("city"), prefix: const Icon(Icons.location_city), validator: requiredValidator),

              buildDropdownField(
                value: _gender.isEmpty ? null : _gender,
                hintText: t("gender"),
                items: [t("male"), t("female")],
                prefixIcon: Icons.transgender,
                onChanged: (val) => setState(() => _gender = val ?? ''),
              ),
              buildDropdownField(
                value: _bloodGroup.isEmpty ? null : _bloodGroup,
                hintText: t("blood_group"),
                items: ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"],
                prefixIcon: Icons.water_drop,
                onChanged: (val) => setState(() => _bloodGroup = val ?? ''),
              ),
              buildDropdownField(
                value: _maritalStatus.isEmpty ? null : _maritalStatus,
                hintText: t("marital_status"),
                items: [t("single"), t("married"), t("divorced"), t("widowed")],
                prefixIcon: Icons.family_restroom,
                onChanged: (val) => setState(() => _maritalStatus = val ?? ''),
              ),

              SwitchListTile(
                title: Text(t("smoker")),
                value: _currentSmoker,
                onChanged: (val) => setState(() => _currentSmoker = val),
              ),

              if (_currentSmoker)
                buildTextFormField(
                  controller: _cigsPerDayController,
                  hintText: t("cigs_per_day"),
                  prefix: const Icon(Icons.smoking_rooms),
                  validator: requiredValidator,
                ),

              buildTextFormField(
                controller: _doctorEmailController,
                hintText: t("doctoremail"),
                prefix: const Icon(Icons.local_hospital),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty && !value.contains("@")) {
                    return "Enter a valid email";
                  }
                  return null; // valid or empty
                },
              ),

              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  final id = _nationalIdController.text.trim();
                  final email = _emailController.text.trim();
                  if (id.isEmpty || email.isEmpty) {
                    _showSnackBar("Please enter national ID and email to generate QR.");
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenerateScreen(
                          nationalId: id,
                          email: email,
                        ),
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF043459)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text("Generate QR", style: TextStyle(color: Color(0xFF021229))),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF043459),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(t("sign_up"), style: const TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
