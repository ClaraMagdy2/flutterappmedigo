import 'package:flutter/material.dart';
import 'package:flutterappmedigo/Diagnosis.dart';
import 'package:flutterappmedigo/Family_history.dart';
import 'package:flutterappmedigo/LabtestScreen.dart';
import 'package:flutterappmedigo/Risk%20managemnet.dart';
import 'package:flutterappmedigo/allergies.dart';
import 'package:flutterappmedigo/emergencycontact.dart';
import 'package:flutterappmedigo/measurement.dart';
import 'package:flutterappmedigo/medication.dart';
import 'package:flutterappmedigo/mydetails.dart';
import 'package:flutterappmedigo/radiologylab.dart';
import 'package:flutterappmedigo/surgery.dart';

class HomeScreen extends StatefulWidget {
  final String userName = "Tony Magdy"; // Example user name
  final String userNationalId = "12345678901234"; // Example national ID

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final Color darkBlue = const Color(0xFF053477);

  @override
  void initState() {
    super.initState();
    // Animation Controller for slide and fade animations.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Slide from slightly below to its final position.
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Fade from invisible to fully visible.
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to build a section button with dark blue text and icons.
  Widget _buildSectionButton(BuildContext context, String label, IconData? icon,
      String? image, Function onPressed) {
    return ElevatedButton(
      onPressed: () => onPressed(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white, // White button background.
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Use image if provided; otherwise, use icon.
              image != null
                  ? Image.asset(
                image,
                width: 28,
                height: 28,
              )
                  : icon != null
                  ? Icon(icon, size: 28, color: darkBlue)
                  : const SizedBox.shrink(),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(fontSize: 18, color: darkBlue),
              ),
            ],
          ),
          Icon(Icons.arrow_forward, color: darkBlue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Light AppBar with dark blue text.
      appBar: AppBar(
        title: Text("Home", style: TextStyle(color: darkBlue)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: darkBlue),
      ),
      body: Container(
        // Light gradient background.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light Blue
              Color(0xFFBBDEFB), // Soft Blue
              Colors.white,
            ],
          ),
        ),
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Details Section (Read Only)
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: const AssetImage('Images/man.png'),
                            backgroundColor: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.userName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: darkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "National ID: ${widget.userNationalId}",
                            style: TextStyle(
                              fontSize: 16,
                              color: darkBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Section Buttons:
                    _buildSectionButton(
                        context, "My Details", Icons.info_outline, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyDetails()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context, "Clinical Indicators", Icons.access_alarm, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyMeasurementScreen()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(context, "My Medication",
                        Icons.medical_services, null, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MedicationHistoryScreen()),
                          );
                        }),
                    const SizedBox(height: 20),
                    _buildSectionButton(context, "Allergic History",
                        Icons.all_inclusive, null, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AllergyScreen()),
                          );
                        }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context, "Blood Biomarkers", Icons.assignment, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LabTestResultScreen()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context,
                        "Diagnostic Radiology Biomarkers",
                        Icons.assignment,
                        null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RadiologyTestResultScreen()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context, "Diagnoses", Icons.healing, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DiagnosisScreen()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context, "Family History", Icons.family_restroom, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FamilyHistoryScreen()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context, "My Surgery", Icons.safety_check, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SurgeryScreen()),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionButton(context, "Risk Assessment", null,
                        'Images/risk.png', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RiskManagementScreen()),
                          );
                        }),
                    const SizedBox(height: 20),
                    _buildSectionButton(
                        context, "My Emergency Contact", Icons.phone, null, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MyEmergencyContactScreen()),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
