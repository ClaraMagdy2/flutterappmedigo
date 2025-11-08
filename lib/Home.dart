import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

import 'assignDoctor.dart';
import 'Clinical indicators.dart';
import 'Diagnosis.dart';
import 'Family_history.dart';
import 'Risk managemnet.dart';
import 'emergencycontact.dart';
import 'measurement.dart';
import 'medication.dart';
import 'mydetails.dart';
import 'surgery.dart';
import 'SearchDoctorScreen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isfacility;
  final String facilityType;
  final String facilityid;
  final String doctorEmail;
  final bool isdoctor;
  final String doctorid;

  const HomeScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.isfacility,
    required this.facilityType,
    required this.facilityid,
    required this.doctorEmail,
    required this.isdoctor,
    required this.doctorid,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Color darkBlue = const Color(0xFF053477);
  String userName = "";
  String userNationalId = "";
  String userProfilePhoto = "";
  String? assignedDoctorName;
  String? assignedDoctorEmail;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
    fetchUserProfile();
    fetchAssignedDoctor();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/users/${widget.userId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userName = data['full_name'] ?? '';
          userNationalId = data['national_id'] ?? '';
          userProfilePhoto = data['profile_photo'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  Future<void> fetchAssignedDoctor() async {
    final url = Uri.parse("http://10.0.2.2:8000/doctor-assignments/check?patient_national_id=${widget.userId}");

    try {
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
      });

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          assignedDoctorName = result['name'];
          assignedDoctorEmail = result['email'];
        });
      } else {
        setState(() {
          assignedDoctorName = null;
          assignedDoctorEmail = null;
        });
      }
    } catch (e) {
      print("Error fetching assigned doctor: $e");
    }
  }

  ImageProvider getProfileImage(String imageString) {
    if (imageString.isEmpty) return const AssetImage('Images/man.jpg');
    if (imageString.startsWith("http")) return NetworkImage(imageString);
    if (imageString.startsWith("data:image")) {
      final parts = imageString.split(',');
      if (parts.length > 1) imageString = parts.last;
    }
    return MemoryImage(base64Decode(imageString));
  }

  void _showDoctorAssignDialog() {
    final t = context.read<TranslationProvider>().t;
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(t("choose_doctor_type")),
        children: [
          SimpleDialogOption(
            child: Text(t("search_existing_doctor")),
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(
                  builder: (_) => SearchDoctorScreen(
                    token: widget.token,
                    userId: widget.userId,
                  ),
                ),
              );
              if (result != null) {
                setState(() {
                  assignedDoctorName = result['name'];
                  assignedDoctorEmail = result['email'];
                });
              }
            },
          ),
          SimpleDialogOption(
            child: Text(t("assign_new_doctor")),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssignNewDoctorScreen(
                    token: widget.token,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _switchLanguage() async {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    final newLang = provider.currentLanguage == 'en' ? 'ar' : 'en';
    await provider.load(newLang);
    setState(() {}); // Force UI to rebuild
  }

  Widget _buildSectionButton(BuildContext context, String labelKey, IconData? icon, String? image, Function onPressed) {
    final t = context.watch<TranslationProvider>().t;
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              image != null
                  ? Image.asset(image, width: 28, height: 28)
                  : icon != null
                  ? Icon(icon, size: 28, color: darkBlue)
                  : const SizedBox.shrink(),
              const SizedBox(width: 10),
              Text(t(labelKey), style: TextStyle(fontSize: 18, color: darkBlue)),
            ],
          ),
          Icon(Icons.arrow_forward, color: darkBlue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TranslationProvider>().t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("home"), style: TextStyle(color: darkBlue)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: darkBlue),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: _switchLanguage,
            tooltip: "Switch Language",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: getProfileImage(userProfilePhoto),
                          backgroundColor: Colors.white,
                        ),
                        Text(
                          assignedDoctorName != null
                              ? "${t("doctor")}: $assignedDoctorName ($assignedDoctorEmail)"
                              : "${t("doctor")}: ${t("not_assigned")}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 6),
                        Text("${t("national_id")}: ${widget.userId}",
                            style: TextStyle(fontSize: 16, color: darkBlue)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  if (!widget.isfacility && !widget.isdoctor) ...[
                    _buildSectionButton(context, "assign_my_doctor", Icons.person_add, null, _showDoctorAssignDialog),
                    const SizedBox(height: 20),
                  ],

                  _buildSectionButton(context, "personal_info", Icons.info_outline, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MyDetailsScreen(
                        token: widget.token,
                        userId: widget.userId,
                        isfacility: widget.isfacility,
                        isdoctor: widget.isdoctor,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "clinical_indicators", Icons.monitor_heart, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ClinicalIndicatorsScreen(
                        token: widget.token,
                        userId: widget.userId,
                        facilityType: widget.facilityType,
                        facilityId: widget.facilityid,
                        isFacility: widget.isfacility,
                        isdoctor: widget.isdoctor,
                        doctorid: widget.doctorid,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "my_medication", Icons.medical_services, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MedicationHistoryScreen(
                        facilityId: widget.facilityid,
                        facilityType: widget.facilityType,
                        isFacility: widget.isfacility,
                        userId: widget.userId,
                        token: widget.token,
                        isdoctor: widget.isdoctor,
                        doctorid: widget.doctorid,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "diagnoses", Icons.healing, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DiagnosisScreen(
                        token: widget.token,
                        userId: widget.userId,
                        isFacility: widget.isfacility,
                        facilityType: widget.facilityType,
                        facilityId: widget.facilityid,
                        isdoctor: widget.isdoctor,
                        doctorid: widget.doctorid,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "family_history", Icons.family_restroom, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => FamilyHistoryScreen(
                        token: widget.token,
                        userId: widget.userId,
                        isFacility: widget.isfacility,
                        facilityType: widget.facilityType,
                        facilityId: widget.facilityid,
                        isdoctor: widget.isdoctor,
                        doctorid: widget.doctorid,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "my_surgery", Icons.safety_check, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SurgeryScreen(
                        token: widget.token,
                        userId: widget.userId,
                        isFacility: widget.isfacility,
                        facilityType: widget.facilityType,
                        facilityId: widget.facilityid,
                        isdoctor: widget.isdoctor,
                        doctorid: widget.doctorid,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "risk_assessment", null, 'Images/risk.png', () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => RiskFeaturesScreen(
                        token: widget.token,
                        userId: widget.userId,
                      ),
                    ));
                  }),
                  const SizedBox(height: 20),
                  _buildSectionButton(context, "emergency_contact", Icons.phone, null, () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => MyEmergencyContactScreen(
                        token: widget.token,
                        userId: widget.userId,
                        isFacility: widget.isfacility,
                        facilityId: widget.facilityid,
                        facilityType: widget.facilityType,
                        isdoctor: widget.isdoctor,
                      ),
                    ));
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
