import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class PatientProceduresScreen extends StatefulWidget {
  final String facilityId;

  const PatientProceduresScreen({Key? key, required this.facilityId}) : super(key: key);

  @override
  _PatientProceduresScreenState createState() => _PatientProceduresScreenState();
}

class _PatientProceduresScreenState extends State<PatientProceduresScreen> {
  bool isLoading = true;
  String error = "";
  List<dynamic> procedures = [];

  @override
  void initState() {
    super.initState();
    fetchFacilityProcedures();
  }

  Future<void> fetchFacilityProcedures() async {
    final url = Uri.parse('http://10.0.2.2:8000/facilities/${widget.facilityId}/procedures');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          procedures = data is List ? data : data["data"] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Failed to load procedures: ${response.body}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
      });
    }
  }

  Widget buildResultList(List<dynamic> results) {
    final t = context.watch<TranslationProvider>().t;
    return Column(
      children: results.map((item) {
        final flag = item['flag'] == true;
        return ListTile(
          leading: Icon(Icons.bloodtype, color: flag ? Colors.red : Colors.green),
          title: Text("${item['item'] ?? t('unknown')}: ${item['value'] ?? '--'} ${item['unit'] ?? ''}"),
          subtitle: flag ? Text(t("abnormal")) : null,
        );
      }).toList(),
    );
  }

  Widget buildRecordItem(Map<String, dynamic> record) {
    final t = context.watch<TranslationProvider>().t;
    final widgets = <Widget>[];

    if (record.containsKey("image_url")) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Image.network(
            record["image_url"],
            height: 200,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Text(t("imageLoadFailed")),
          ),
        ),
      );
    }

    if (record.containsKey("results") && record["results"] is List) {
      widgets.add(buildResultList(record["results"]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget buildProcedureCard(Map<String, dynamic> item) {
    final t = context.watch<TranslationProvider>().t;
    final String patientId = item["patient_id"];
    final Map<String, dynamic> proceduresMap = item["procedures"];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      child: ExpansionTile(
        title: Text("🧍 ${t("patientId")}: $patientId"),
        children: proceduresMap.entries.map((entry) {
          final String type = entry.key;
          final List<dynamic> records = entry.value;

          return Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("📂 $type", style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ...records.map((r) => buildRecordItem(r)).toList(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TranslationProvider>().t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("facilityPatientsProcedures")),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Switch Language',
            onPressed: () => context.read<TranslationProvider>().toggleLanguage(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
          ? Center(child: Text(error))
          : procedures.isEmpty
          ? Center(child: Text(t("noProceduresFound")))
          : ListView.builder(
        itemCount: procedures.length,
        itemBuilder: (context, index) => buildProcedureCard(procedures[index]),
      ),
    );
  }
}
