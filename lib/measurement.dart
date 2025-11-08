import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class MyMeasurementsOnlyScreen extends StatefulWidget {
  final String token;
  final String userId;
  final String facilityId;
  final String facilityType;
  final bool isFacility;
  final bool isdoctor;

  const MyMeasurementsOnlyScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.facilityId,
    required this.facilityType,
    required this.isFacility,
    required this.isdoctor,
  }) : super(key: key);

  @override
  State<MyMeasurementsOnlyScreen> createState() => _MyMeasurementsOnlyScreenState();
}

class _MyMeasurementsOnlyScreenState extends State<MyMeasurementsOnlyScreen> {
  double height = 0;
  double weight = 0;
  double bmi = 0;
  bool loading = true;

  final String baseUrl = "http://10.0.2.2:8000";

  bool get _canEdit => true;

  @override
  void initState() {
    super.initState();
    _fetchHeightWeight();
  }

  Future<void> _fetchHeightWeight() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/measurements/body/${widget.userId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          height = (data['height'] ?? 0).toDouble();
          weight = (data['weight'] ?? 0).toDouble();
          bmi = (data['bmi'] ?? 0).toDouble();
          loading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _updateHeightWeight(double newWeight, double newHeight) async {
    final t = context.read<TranslationProvider>().t;
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/measurements/body/${widget.userId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "height": newHeight,
          "weight": newWeight,
          "added_by": widget.facilityId,
        }),
      );

      if (response.statusCode == 200) {
        _fetchHeightWeight();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("updateSuccess"))));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? t("error"));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showEditDialog() {
    final heightCtrl = TextEditingController(text: height.toStringAsFixed(1));
    final weightCtrl = TextEditingController(text: weight.toStringAsFixed(1));
    final t = context.read<TranslationProvider>().t;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("editRecord")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightCtrl,
              decoration: InputDecoration(labelText: t("weightLabel")),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: heightCtrl,
              decoration: InputDecoration(labelText: t("heightLabel")),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newW = double.tryParse(weightCtrl.text) ?? weight;
              final newH = double.tryParse(heightCtrl.text) ?? height;
              _updateHeightWeight(newW, newH);
              Navigator.pop(context);
            },
            child: Text(t("save")),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t("cancel")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const darkBlue = Color(0xFF021229);
    final t = context.read<TranslationProvider>().t;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Show back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(t("myMeasurements"), style: const TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              final provider = context.read<TranslationProvider>();
              final newLang = provider.currentLanguage == 'en' ? 'ar' : 'en';
              provider.load(newLang);
            },
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Card(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: Text(
                t("heightWeight"),
                style: const TextStyle(fontWeight: FontWeight.bold, color: darkBlue),
              ),
              trailing: _canEdit
                  ? IconButton(
                icon: const Icon(Icons.edit, color: darkBlue),
                onPressed: _showEditDialog,
              )
                  : null,
            ),
            ListTile(
              title: Text("${t("height")}: ${height.toStringAsFixed(1)} cm",
                  style: const TextStyle(color: darkBlue)),
            ),
            ListTile(
              title: Text("${t("weight")}: ${weight.toStringAsFixed(1)} kg",
                  style: const TextStyle(color: darkBlue)),
            ),
            ListTile(
              title: Text("${t("bmi")}: ${bmi.toStringAsFixed(1)}",
                  style: const TextStyle(color: darkBlue)),
            ),
          ],
        ),
      ),
    );
  }
}
