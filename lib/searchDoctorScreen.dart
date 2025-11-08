import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class SearchDoctorScreen extends StatefulWidget {
  final String token;
  final String userId;

  const SearchDoctorScreen({
    Key? key,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  _SearchDoctorScreenState createState() => _SearchDoctorScreenState();
}

class _SearchDoctorScreenState extends State<SearchDoctorScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  String errorMessage = '';

  String t(String key) =>
      Provider.of<TranslationProvider>(context, listen: false).t(key);

  Future<void> searchDoctors(String emailQuery) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      results = [];
    });

    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/doctor-assignments/doctors?email=$emailQuery"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          results = jsonData.map((e) => e as Map<String, dynamic>).toList();
        });
      } else {
        setState(() {
          errorMessage = t("doctorNotFound");
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "${t("error")}: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> assignDoctor(String email, String name) async {
    final response = await http.post(
      Uri.parse("http://10.0.2.2:8000/doctor-assignments/"),
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

    final result = jsonDecode(response.body);
    if (response.statusCode == 200) {
      final msg = result["message"] ?? t("assignSuccess");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
      Navigator.pop(context);
    } else {
      final detail = result["detail"] ?? t("assignFailed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(detail)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(t("searchDoctor")),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: "Switch Language",
            onPressed: () => provider.toggleLanguage(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: t("enterDoctorEmail"),
                labelStyle: const TextStyle(color: Colors.blue),
                prefixIcon: const Icon(Icons.email, color: Colors.blue),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: Text(t("search")),
                onPressed: () => searchDoctors(searchController.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const CircularProgressIndicator()
            else if (errorMessage.isNotEmpty)
              Text(errorMessage, style: const TextStyle(color: Colors.red)),
            Expanded(
              child: results.isEmpty
                  ? Center(child: Text(t("noDoctorsFound")))
                  : ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final doc = results[index];
                  final name = doc["doctor_name"] ?? t("unnamed");
                  final email = doc["email"] ?? t("unknown");

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(email),
                      trailing: ElevatedButton(
                        onPressed: () => assignDoctor(email, name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(t("assign")),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
