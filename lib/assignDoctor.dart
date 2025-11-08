import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class AssignNewDoctorScreen extends StatefulWidget {
  final String token;
  final String userId;

  const AssignNewDoctorScreen({
    Key? key,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  _AssignNewDoctorScreenState createState() => _AssignNewDoctorScreenState();
}

class _AssignNewDoctorScreenState extends State<AssignNewDoctorScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool isSubmitting = false;

  Future<void> assignDoctorManually(String email, String name) async {
    setState(() {
      isSubmitting = true;
    });

    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000 /doctor-assignments/"),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "doctor_email": email,
        "doctor_name": name,
        "patient_national_id": widget.userId,
      }),
    );

    setState(() {
      isSubmitting = false;
    });

    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final msg = result["admin_alert"] ?? t("assign_success");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("assign_failed"))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final t = provider.t;
    final isArabic = provider.currentLanguage == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t("assign_doctor")),
          backgroundColor: const Color(0xFF1976D2),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Row(
              children: [
                const Text('EN', style: TextStyle(color: Colors.white)),
                Switch(
                  value: isArabic,
                  onChanged: (value) async {
                    await provider.load(value ? 'ar' : 'en');
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                ),
                const Text('عربي', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE3F2FD),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFFBBDEFB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person_add_alt_1, size: 50, color: Color(0xFF1976D2)),
                      const SizedBox(height: 16),
                      Text(
                        t("assign_new_doctor_title"),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: t("doctor_name"),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: t("doctor_email"),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      isSubmitting
                          ? const CircularProgressIndicator()
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle_outline,color:Colors.white,),
                          label: Text(t("assign_button")),
                          onPressed: () {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();

                            if (name.isEmpty || email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(t("fill_all_fields"))),
                              );
                              return;
                            }

                            assignDoctorManually(email, name);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
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
}
