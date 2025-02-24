import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutterappmedigo/FacilityScreen.dart';
import 'package:flutterappmedigo/Home.dart';
import 'package:flutterappmedigo/SignUp.dart';
import 'package:flutterappmedigo/emergencyQr.dart';
import 'package:flutterappmedigo/home%20admin.dart';
import 'Components/textfield.dart';

class LoginScreen extends StatefulWidget {
  final String text1; // Passed username from SignUpScreen

  const LoginScreen({
    Key? key,
    required this.text1,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController idController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    idController = TextEditingController(text: widget.text1);
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove the solid background color and use a gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFBBDEFB), // Soft blue
              Color(0xFFFFFFFF), // White
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Login image at the top
                Container(
                  width: double.infinity,
                  child: Image.asset('Images/login.png'),
                ),
                // ID Field with external padding
                buildTextFormField(
                  prefix: Image.asset(
                    'Images/card.png',
                    width: 20,
                    height: 20,
                  ),
                  hintText: 'ID',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your ID';
                    }
                    return null;
                  },
                  controller: idController,
                ),
                const SizedBox(height: 20),
                // Password Field with external padding
                buildTextFormField(
                  prefix: const Icon(Icons.lock),
                  hintText: 'Password',
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  controller: passwordController,
                ),
                const SizedBox(height: 20),
                // Log In Button with a blue gradient for contrast
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF02597A),
                        Color(0xFF043459),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      final id = idController.text;
                      if (id.isNotEmpty && passwordController.text.isNotEmpty) {
                        if (id == '11111') {
                          // Admin Screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacilitiesScreen(),
                            ),
                          );
                        } else if (RegExp(r'^\d{14}$').hasMatch(id)) {
                          // 14-digit ID goes to HomeScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        } else {
                          // Any other ID goes to FacilityScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacilityScreen(),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(400, 60),
                      padding: const EdgeInsets.all(15.0),
                      textStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text(
                      'Log in',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Sign Up Link
                RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Don't have an account?",
                        style: TextStyle(color: Colors.black54, fontSize: 17),
                      ),
                      TextSpan(
                        text: ' Create Account',
                        style: const TextStyle(
                          color: Color(0xFF02597A), // Beautiful blue link color
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Emergency QR Button
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmergencyQrScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Emergency',
                    style: TextStyle(
                      color: Color(0xFF02597A), // Beautiful blue
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
