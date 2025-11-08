import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class DoctorPendingDashboard extends StatefulWidget {
  final String doctorEmail;

  const DoctorPendingDashboard({Key? key, required this.doctorEmail}) : super(key: key);

  @override
  _DoctorPendingDashboardState createState() => _DoctorPendingDashboardState();
}

class _DoctorPendingDashboardState extends State<DoctorPendingDashboard> {
  List<Map<String, dynamic>> pendingData = [];
  bool isLoading = true;
  Set<String> loadingDocIds = {};

  @override
  void initState() {
    super.initState();
    fetchPendingData();
  }

  Future<void> fetchPendingData() async {
    final url = Uri.parse("http://10.0.2.2:8000/pending/reviewer/${Uri.encodeComponent(widget.doctorEmail)}");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          pendingData = List<Map<String, dynamic>>.from(jsonData);
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> approveRecord(String docId) async {
    setState(() => loadingDocIds.add(docId));
    final url = Uri.parse(
        "http://10.0.2.2:8000/pending/approve/${Uri.encodeComponent(widget.doctorEmail)}/$docId?reviewer_name=${Uri.encodeComponent(widget.doctorEmail)}");

    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("record_approved"))));
        await fetchPendingData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${t("approval_failed")}: ${response.statusCode}")));
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => loadingDocIds.remove(docId));
    }
  }

  Future<void> rejectRecord(String docId) async {
    setState(() => loadingDocIds.add(docId));
    final url = Uri.parse(
        "http://10.0.2.2:8000/pending/reject/${Uri.encodeComponent(widget.doctorEmail)}/$docId?reviewer_name=${Uri.encodeComponent(widget.doctorEmail)}");

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("record_rejected"))));
        await fetchPendingData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${t("rejection_failed")}: ${response.statusCode}")));
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() => loadingDocIds.remove(docId));
    }
  }

  Widget buildBiomarkerCard(Map<String, dynamic> item) {
    final record = item["record"] ?? {};
    final imageUrl = record["image_url"];
    final results = List<Map<String, dynamic>>.from(record["results"] ?? []);
    final nationalId = item["national_id"] ?? "Unknown";
    final extractedDate = record["extracted_date"] ?? "Unknown";
    final docId = item["id"];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("👤 ${t("patient_id")}: $nationalId", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("📅 ${t("extracted_date")}: $extractedDate"),
            const SizedBox(height: 12),
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text("🧪 ${t("biomarker_results")}:",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            const Divider(),
            if (results.isEmpty)
              Text(t("no_biomarkers"), style: const TextStyle(color: Colors.grey)),
            ...results.map((result) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text("${result["test_name"] ?? result["item"] ?? "?"}: ${result["value"] ?? "?"} ${result["unit"] ?? ""}"),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
            if (loadingDocIds.contains(docId))
              const Center(child: CircularProgressIndicator())
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => approveRecord(docId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                    icon: const Icon(Icons.check,color: Colors.white),
                    label: Text(t("approve"),style: TextStyle(color: Colors.white),),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => rejectRecord(docId),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                    icon: const Icon(Icons.close,color: Colors.white),
                    label: Text(t("reject"),style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  String t(String key) {
    return Provider.of<TranslationProvider>(context, listen: true).t(key);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isArabic = provider.currentLanguage == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t("doctor_dashboard"),
                style: const TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  const Text('EN', style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isArabic,
                    onChanged: (value) async {
                      final newLang = value ? 'ar' : 'en';
                      await provider.load(newLang);
                      setState(() {});
                    },
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                  ),
                  const Text('عربي', style: TextStyle(color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pendingData.isEmpty
            ? Center(child: Text(t("no_pending_records")))
            : ListView.builder(
          itemCount: pendingData.length,
          itemBuilder: (context, index) =>
              buildBiomarkerCard(pendingData[index]),
        ),
      ),
    );
  }
}
