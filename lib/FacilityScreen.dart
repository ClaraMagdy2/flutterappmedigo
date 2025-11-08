import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'Home.dart';
import 'PendingApprovalsScreen.dart';
import 'PatientProceduresScreen.dart';
import 'translation_provider.dart';

class FacilityScreen extends StatefulWidget {
  final String token;
  final String facilityid;
  final bool isfacility;
  final String userFullName;
  final String facilityname;
  final String facilityType;
  final bool isdoctor;

  const FacilityScreen({
    Key? key,
    required this.token,
    required this.facilityid,
    required this.isfacility,
    required this.userFullName,
    required this.facilityname,
    required this.facilityType,
    required this.isdoctor,
  }) : super(key: key);

  @override
  _FacilityScreenState createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  final String baseUrl = "http://10.0.2.2:8000";
  List<Map<String, dynamic>> allPatients = [];
  List<Map<String, dynamic>> filteredPatients = [];
  int pendingCount = 0;
  String searchQuery = "";
  bool isLoading = true;
  String error = "";

  @override
  void initState() {
    super.initState();
    fetchAllPatients();
    fetchPendingCount();
  }

  Future<void> fetchAllPatients() async {
    setState(() {
      isLoading = true;
      error = "";
    });

    try {
      final url = Uri.parse('$baseUrl/users/');
      final response = await http.get(url).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is List) {
          final List<Map<String, dynamic>> safeUsers = data.map<Map<String, dynamic>>((item) {
            if (item is Map<String, dynamic>) {
              return {
                "full_name": item["full_name"] ?? "Unknown",
                "national_id": item["national_id"]?.toString() ?? "",
                "doctoremail": item["doctoremail"]?.toString() ?? "",
                "age": item["age"] ?? "--",
              };
            }
            return {};
          }).toList();

          setState(() {
            allPatients = safeUsers;
            applyLocalFilter();
            isLoading = false;
          });
        } else {
          throw FormatException("Expected List but got ${data.runtimeType}");
        }
      } else {
        throw HttpException("HTTP ${response.statusCode}: ${response.body}");
      }
    } catch (e) {
      setState(() {
        error = "Error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  Future<void> fetchPendingCount() async {
    final url = Uri.parse('$baseUrl/pending/reviewer/${widget.facilityname}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          pendingCount = data.length;
        });
      }
    } catch (_) {
      print("⚠️ Could not fetch pending count.");
    }
  }

  void applyLocalFilter() {
    final query = searchQuery.toLowerCase();
    setState(() {
      filteredPatients = allPatients.where((patient) {
        final name = (patient['full_name'] ?? '').toLowerCase();
        final nationalId = (patient['national_id'] ?? '').toLowerCase();
        return name.contains(query) || nationalId.contains(query);
      }).toList();
    });
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query;
    });
    applyLocalFilter();
  }

  Widget buildPatientCard(Map<String, dynamic> patient) {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          patient["full_name"] ?? provider.t("unknown"),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("ID: ${patient["national_id"] ?? "--"}"),
            Text("Doctor Email: ${patient["doctoremail"] ?? "--"}"),
          ],
        ),
        trailing: Text("Age: ${patient["age"]?.toString() ?? '--'}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                token: widget.token,
                userId: patient["national_id"] ?? "",
                isfacility: widget.isfacility,
                facilityType: widget.facilityType,
                facilityid: widget.facilityid,
                doctorEmail: patient["doctoremail"] ?? "",
                isdoctor: widget.isdoctor,
                doctorid: '',
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

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Text(provider.t("facilityDashboard"), style: const TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: "Switch Language",
            onPressed: () => provider.toggleLanguage(),
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                tooltip: provider.t("pendingApprovals"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PendingApprovalsScreen(
                        reviewerId: widget.facilityid,
                        reviewerName: widget.facilityname,
                      ),
                    ),
                  );
                },
              ),
              if (pendingCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "$pendingCount",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : error.isNotEmpty
          ? Center(child: Text(error, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${provider.t("loggedInAs")}: ${widget.facilityname}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900)),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: provider.t("searchPatients"),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: updateSearch,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => updateSearch(""),
                    icon: const Icon(Icons.refresh),
                    label: Text(provider.t("reset")),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.folder_shared, color: Colors.white),
                    label: Text(provider.t("viewPatientProcedures"),
                        style: const TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PatientProceduresScreen(
                            facilityId: widget.facilityid,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (_, i) => buildPatientCard(filteredPatients[i]),
            ),
          ),
        ],
      ),
    );
  }
}
