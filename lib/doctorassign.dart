import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'Home.dart';
import 'PendingApprovalsScreen.dart';
import 'translation_provider.dart';

class DoctorPatientScreen extends StatefulWidget {
  final String doctorEmail;
  final String token;
  final String doctorid;
  final bool isfacility;
  final bool isdoctor;

  const DoctorPatientScreen({
    Key? key,
    required this.doctorEmail,
    required this.token,
    required this.isfacility,
    required this.isdoctor,
    required this.doctorid,
  }) : super(key: key);

  @override
  _DoctorPatientScreenState createState() => _DoctorPatientScreenState();
}

class _DoctorPatientScreenState extends State<DoctorPatientScreen> {
  List<Map<String, dynamic>> assignedPatients = [];
  List<Map<String, dynamic>> pendingApprovals = [];
  bool isLoading = true;
  String searchQuery = "";
  List<Map<String, dynamic>> filteredPatients = [];

  final String baseUrl = "http://10.0.2.2:8000";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await Future.wait([
      fetchAssignedPatients(),
      fetchPendingApprovals(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchAssignedPatients() async {
    try {
      final res = await http.get(Uri.parse(
          "$baseUrl/doctor-assignments/${Uri.encodeComponent(widget.doctorEmail)}/patients"));
      if (res.statusCode == 200) {
        final List<dynamic> assignments = json.decode(res.body);
        List<Map<String, dynamic>> enriched = [];

        for (var p in assignments) {
          final nationalId = p['patient_national_id'];
          final fullName = p['full_name'];
          if (fullName != null) {
            enriched.add({
              "full_name": fullName,
              "national_id": nationalId,
            });
          } else {
            final userRes = await http.get(Uri.parse("$baseUrl/users/$nationalId"));
            if (userRes.statusCode == 200) {
              final userData = json.decode(userRes.body);
              enriched.add({
                "full_name": userData["full_name"] ?? "Unknown",
                "national_id": nationalId,
              });
            } else {
              enriched.add({
                "full_name": "Unknown",
                "national_id": nationalId,
              });
            }
          }
        }

        setState(() {
          assignedPatients = enriched;
          filteredPatients = enriched;
        });
      }
    } catch (e) {
      print("Error fetching assigned patients: $e");
    }
  }

  Future<void> fetchPendingApprovals() async {
    try {
      if (widget.doctorEmail.isNotEmpty) {
        final res = await http.get(
            Uri.parse("$baseUrl/pending/reviewer/${Uri.encodeComponent(widget.doctorEmail)}"));
        if (res.statusCode == 200) {
          final decoded = json.decode(res.body);
          pendingApprovals = List<Map<String, dynamic>>.from(decoded["pending"] ?? []);
        }
      }
    } catch (e) {
      print("Error fetching pending: $e");
    }
  }

  void filterPatients(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredPatients = assignedPatients.where((p) {
        final name = (p["full_name"] ?? "").toLowerCase();
        final id = (p["national_id"] ?? "").toLowerCase();
        return name.contains(q) || id.contains(q);
      }).toList();
    });
  }

  Widget buildUserCard(Map<String, dynamic> user) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(user["full_name"] ?? t("unknown")),
        subtitle: Text("${t("national_id")}: ${user["national_id"]}"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                token: widget.token,
                userId: user["national_id"],
                isfacility: widget.isfacility,
                facilityid: '',
                facilityType: '',
                doctorEmail: widget.doctorEmail,
                isdoctor: widget.isdoctor,
                doctorid: widget.doctorid,
              ),
            ),
          );
        },
      ),
    );
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
          title: Text(t("doctor_dashboard")),
          backgroundColor: Colors.blue.shade800,
          actions: [
            Row(
              children: [
                const Text("EN", style: TextStyle(color: Colors.white)),
                Switch(
                  value: isArabic,
                  onChanged: (val) {
                    provider.load(val ? "ar" : "en");
                  },
                  activeColor: Colors.white,
                ),
                const Text("عربي", style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
              ],
            ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PendingApprovalsScreen(
                          reviewerId: widget.doctorEmail,
                          reviewerName: widget.doctorEmail,
                        ),
                      ),
                    );
                  },
                ),
                if (pendingApprovals.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: CircleAvatar(
                      radius: 10,
                      backgroundColor: Colors.red,
                      child: Text(
                        pendingApprovals.length.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: t("search_by_name_or_id"),
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (val) {
                  searchQuery = val;
                  filterPatients(val);
                },
              ),
            ),
            Expanded(
              child: filteredPatients.isEmpty
                  ? Center(child: Text(t("no_assigned_patients")))
                  : ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (_, i) => buildUserCard(filteredPatients[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
