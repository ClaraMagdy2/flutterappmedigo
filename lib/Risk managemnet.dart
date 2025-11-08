import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class RiskFeaturesScreen extends StatefulWidget {
  final String token;
  final String userId;

  const RiskFeaturesScreen({
    Key? key,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  _RiskFeaturesScreenState createState() => _RiskFeaturesScreenState();
}

class _RiskFeaturesScreenState extends State<RiskFeaturesScreen> {
  double diabetesRisk = 0.0;
  double hypertensionRisk = 0.0;
  Map<String, dynamic> features = {};
  List<Map<String, dynamic>> topDiabetesFeatures = [];
  List<Map<String, dynamic>> topHypertensionFeatures = [];
  bool isLoading = true;
  String? errorMessage;

  String t(String key) => Provider.of<TranslationProvider>(context, listen: false).t(key);

  final Map<String, String> fullFeatureNames = {
    "male": "Male Gender",
    "age_group": "Age Group",
    "smoker_status": "Smoker Status",
    "male_smoker": "Male Smoker",
    "sysBP": "Systolic Blood Pressure",
    "diaBP": "Diastolic Blood Pressure",
    "bp_category": "Blood Pressure Category",
    "pulse_pressure": "Pulse Pressure",
    "heartRate": "Heart Rate",
    "BPMeds": "Blood Pressure Medications",
    "totChol": "Total Cholesterol",
    "glucose": "Glucose Level",
    "bmi": "Body Mass Index (BMI)",
    "bmi_category": "BMI Category",
    "is_obese": "Obesity",
    "prediabetes_indicator": "Prediabetes Indicator",
    "insulin_resistance": "Insulin Resistance",
    "metabolic_syndrome": "Metabolic Syndrome",
    "diabetes": "Diabetes Risk Input",
    "hypertension": "Hypertension Risk Input"
  };

  @override
  void initState() {
    super.initState();
    fetchRiskPrediction();
  }

  Future<void> fetchRiskPrediction() async {
    final url = Uri.parse("http://10.0.2.2:8000/risk/${widget.userId}");
    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          diabetesRisk = data["diabetes_risk"] ?? 0.0;
          hypertensionRisk = data["hypertension_risk"] ?? 0.0;
          features = Map<String, dynamic>.from(data["input_values"] ?? {});
          topDiabetesFeatures = List<Map<String, dynamic>>.from(data["top_diabetes_features"] ?? []);
          topHypertensionFeatures = List<Map<String, dynamic>>.from(data["top_hypertension_features"] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = "${t("loadFail")}: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "${t("loadError")}: $e";
        isLoading = false;
      });
    }
  }

  Widget buildRadialChart(String title, double value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        CircularPercentIndicator(
          radius: 70,
          lineWidth: 10,
          percent: (value / 100).clamp(0.0, 1.0),
          center: Text("${value.toStringAsFixed(1)}%"),
          progressColor: color,
          backgroundColor: color.withOpacity(0.2),
          animation: true,
          animationDuration: 800,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget buildTopFeatures(String title, List<Map<String, dynamic>> featuresList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...featuresList.map((item) => Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fullFeatureNames[item['feature_name']] ?? item['feature_name'],
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('${item['contribution_score']}%', style: const TextStyle(color: Colors.teal)),
            ],
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t("ciAndRisk"), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF02597A),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () => provider.toggleLanguage(),
            tooltip: "Switch Language",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildRadialChart(t("diabetesRisk"), diabetesRisk, Colors.blue),
            buildRadialChart(t("hypertensionRisk"), hypertensionRisk, Colors.red),
            buildTopFeatures(t("topDiabetesFactors"), topDiabetesFeatures),
            buildTopFeatures(t("topHypertensionFactors"), topHypertensionFeatures),
          ],
        ),
      ),
    );
  }
}
