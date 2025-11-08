import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterappmedigo/doctorassign.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'translation_provider.dart';
import 'home admin.dart';
import 'FacilityScreen.dart';
import 'Home.dart';
import 'SignUp.dart';
import 'emergencyQr.dart';
import 'doctorpendingloginscreen.dart';
import 'Components/textfield.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    setState(() => isLoading = true);

    final userId = idController.text.trim();
    final password = passwordController.text.trim();

    if (userId.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields.");
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("http://10.0.2.2:8000/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "password": password}),
      );

      final data = jsonDecode(response.body);
      print("Login: ${response.statusCode} | $data");

      if (response.statusCode == 200) {
        final role = data['role'];

        switch (role) {
          case 'admin':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AdminRegisterScreen(token: "admin-token", adminId: 'admin'),
              ),
            );
            break;

          case 'patient':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(
                  token: "patient-token",
                  userId: userId,
                  isfacility: false,
                  facilityType: '',
                  facilityid: '',
                  doctorEmail: data['doctor_email'] ?? '',
                  doctorid: '',
                  isdoctor: false,
                ),
              ),
            );
            break;

          case 'doctor':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DoctorPatientScreen(
                  token: "doctor-token",
                  doctorEmail: data['email'] ?? '',
                  isfacility: false,
                  isdoctor: true,
                  doctorid: data['doctor_id'] ?? '',
                ),
              ),
            );
            break;

          case 'facility':
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => FacilityScreen(
                  token: "facility-token",
                  facilityid: data['facility_id'],
                  isfacility: true,
                  userFullName: data['full_name'] ?? '',
                  facilityname: data['facility_name'] ?? '',
                  facilityType: data['facility_type'] ?? '',
                  isdoctor: false,
                ),
              ),
            );
            break;

          default:
            _showSnackBar("Unknown role.");
        }
      } else {
        _showSnackBar(data['detail'] ?? "Login failed.");
      }
    } catch (e) {
      _showSnackBar("Something went wrong.");
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<TranslationProvider>(context).t;
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(t("login_button"));

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Color(0xFF02597A)),
              onPressed: () async {
                final provider = Provider.of<TranslationProvider>(context, listen: false);
                final newLocale = isArabic ? 'en' : 'ar';
                await provider.load(newLocale);
                setState(() {});
              },
            )
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Color(0xFFFFFFFF)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset('Images/login.png'),
                  buildTextFormField(
                    prefix: Image.asset('Images/card.png', width: 20, height: 20),
                    hintText: t("login_id"),
                    keyboardType: TextInputType.text,
                    controller: idController,
                  ),
                  const SizedBox(height: 20),
                  buildTextFormField(
                    prefix: const Icon(Icons.lock),
                    hintText: t("login_password"),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [
                        Color(0xFF02597A),
                        Color(0xFF043459)
                      ]),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(400, 60),
                      ),
                      child: Text(
                        t("login_button"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: t("login_create_prompt") + " ",
                          style: const TextStyle(color: Colors.black54, fontSize: 17),
                        ),
                        TextSpan(
                          text: t("login_create_link"),
                          style: const TextStyle(
                            color: Color(0xFF02597A),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => GenerateQrScreen()));
                    },
                    child: Text(t("login_emergency"), style: const TextStyle(color: Color(0xFF02597A), fontSize: 20)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DoctorPendingLoginScreen(initialEmail: idController.text.trim()),
                        ),
                      );
                    },
                    child: Text(t("login_doctor_pending"), style: const TextStyle(color: Color(0xFF02597A), fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
