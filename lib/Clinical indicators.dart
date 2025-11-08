import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterappmedigo/getrad.dart';
import 'package:flutterappmedigo/hypertension.dart';
import 'package:flutterappmedigo/measurement.dart';
import 'package:flutterappmedigo/LabtestScreen.dart';
import 'package:flutterappmedigo/allergies.dart';
import 'translation_provider.dart';

class ClinicalIndicatorsScreen extends StatelessWidget {
  final String token;
  final String userId;
  final String facilityType;
  final String facilityId;
  final bool isFacility;
  final String doctorid;
  final bool isdoctor;

  const ClinicalIndicatorsScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.facilityType,
    required this.facilityId,
    required this.isFacility,
    required this.isdoctor,
    required this.doctorid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final t = provider.t;
    final isArabic = provider.currentLanguage == 'ar';
    const darkBlue = Color(0xFF021229);

    Widget _buildTile(String title, IconData icon, VoidCallback onTap) {
      return Card(
        child: ListTile(
          leading: Icon(icon, color: darkBlue),
          title: Text(title, style: const TextStyle(fontSize: 18, color: darkBlue)),
          trailing: const Icon(Icons.arrow_forward_ios, color: darkBlue, size: 18),
          onTap: onTap,
        ),
      );
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true, // ✅ Show back arrow
          iconTheme: const IconThemeData(color: Colors.white), // ✅ Make the arrow white
          title: Text(t("clinical_indicators"), style: const TextStyle(color: Colors.white)),
          backgroundColor: darkBlue,
          actions: [
            Row(
              children: [
                const Text('EN', style: TextStyle(color: Colors.white)),
                Switch(
                  value: isArabic,
                  onChanged: (val) => provider.load(val ? 'ar' : 'en'),
                  activeColor: Colors.white,
                ),
                const Text('عربي', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 10),
              ],
            )
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTile(t("my_measurements"), Icons.monitor_weight, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MyMeasurementsOnlyScreen(
                    token: token,
                    userId: userId,
                    facilityType: facilityType,
                    facilityId: facilityId,
                    isFacility: isFacility,
                    isdoctor: isdoctor,
                  ),
                ),
              );
            }),
            _buildTile(t("hypertension"), Icons.favorite, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HypertensionScreen(
                    token: token,
                    userId: userId,
                    facilityType: facilityType,
                    facilityId: facilityId,
                    isFacility: isFacility,
                    isdoctor: isdoctor,
                    doctorid: doctorid,
                  ),
                ),
              );
            }),
            _buildTile(t("blood_biomarkers"), Icons.bloodtype, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BiomarkerScreen(
                    token: token,
                    userId: userId,
                    isfacility: isFacility,
                    facilityId: facilityId,
                    facilityType: facilityType,
                    doctorid: doctorid,
                    isdoctor: isdoctor,
                  ),
                ),
              );
            }),
            _buildTile(t("radiology"), Icons.medical_information, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RadiologyTestScreen(
                    token: token,
                    userId: userId,
                    isFacility: isFacility,
                    facilityId: facilityId,
                    doctorId: doctorid,
                    isDoctor: isdoctor,
                  ),
                ),
              );
            }),
            _buildTile(t("allergic_history"), Icons.warning_amber, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AllergyScreen(
                    token: token,
                    userId: userId,
                    isFacility: isFacility,
                    facilityId: facilityId,
                    facilityType: facilityType,
                    isdoctor: isdoctor,
                    doctorid: doctorid,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
