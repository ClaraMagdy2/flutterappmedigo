import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

// ----------------------- MODEL -----------------------
class Diagnosis {
  final String id;
  final String userId;
  final String diseaseName;
  final DateTime diagnosisDate;
  final String diagnosedBy;
  final bool isChronic;
  final String detailedNotes;
  final String addedBy;

  Diagnosis({
    required this.id,
    required this.userId,
    required this.diseaseName,
    required this.diagnosisDate,
    required this.diagnosedBy,
    required this.isChronic,
    required this.detailedNotes,
    required this.addedBy,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      diseaseName: json['disease_name'] ?? '',
      diagnosisDate: DateTime.parse(json['diagnosis_date']),
      diagnosedBy: json['diagnosed_by'] ?? '',
      isChronic: json['is_chronic'] ?? false,
      detailedNotes: json['detailed_notes'] ?? '',
      addedBy: json['added_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'disease_name': diseaseName,
      'diagnosis_date': diagnosisDate.toIso8601String().split('T')[0],
      'diagnosed_by': diagnosedBy,
      'is_chronic': isChronic,
      'detailed_notes': detailedNotes,
      'added_by': addedBy,
    };
  }
}

// ----------------------- SERVICE -----------------------
class DiagnosisApiService {
  final String baseUrl = "http://10.0.2.2:8000";
  final String token;

  DiagnosisApiService({required this.token});

  Future<List<Diagnosis>> fetchDiagnoses(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/diagnoses/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Diagnosis.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load diagnoses: ${response.body}");
    }
  }

  Future<String> addDiagnosis(String userId, Diagnosis diagnosis) async {
    final response = await http.post(
      Uri.parse("$baseUrl/diagnoses/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(diagnosis.toJson()),

    );
    print("🔵 Response body: ${response.body}");
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Failed to add diagnosis: ${response.body}");
    }
  }

  Future<void> updateDiagnosis(String userId, String recordId, Diagnosis diagnosis) async {
    final response = await http.put(
      Uri.parse("$baseUrl/diagnoses/$userId/$recordId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(diagnosis.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update diagnosis: ${response.body}");
    }
  }

  Future<void> deleteDiagnosis(String userId, String recordId, String addedBy) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/diagnoses/$userId/$recordId?added_by=$addedBy"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete diagnosis: ${response.body}");
    }
  }
}

// ----------------------- UI SCREEN -----------------------
class DiagnosisScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isFacility;
  final String facilityId;
  final String facilityType;
  final bool isdoctor;
  final String doctorid;

  const DiagnosisScreen({
    required this.token,
    required this.userId,
    required this.isFacility,
    required this.facilityId,
    required this.facilityType,
    required this.isdoctor,
    required this.doctorid,
  });

  @override
  State<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends State<DiagnosisScreen> {
  late Future<List<Diagnosis>> diagnosisFuture;
  late DiagnosisApiService apiService;

  @override
  void initState() {
    super.initState();
    apiService = DiagnosisApiService(token: widget.token);
    _load();
  }

  void _load() {
    setState(() {
      diagnosisFuture = apiService.fetchDiagnoses(widget.userId);
    });
  }

  bool get _canAdd =>
      (widget.isFacility &&
          (widget.facilityType.toLowerCase() == 'hospital' || widget.facilityType.toLowerCase() == 'clinic')) ||
          widget.isdoctor;

  void _showForm({Diagnosis? item}) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    final editing = item != null;
    final nameCtrl = TextEditingController(text: item?.diseaseName ?? "");
    final byCtrl = TextEditingController(text: item?.diagnosedBy ?? "");
    final notesCtrl = TextEditingController(text: item?.detailedNotes ?? "");
    bool isChronic = item?.isChronic ?? false;
    DateTime selectedDate = item?.diagnosisDate ?? DateTime.now();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (ctx, update) {
        return AlertDialog(
          title: Text(editing ? t("edit_diagnosis") : t("add_diagnosis")),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: nameCtrl, decoration: InputDecoration(labelText: t("disease"))),
                TextField(controller: byCtrl, decoration: InputDecoration(labelText: t("diagnosed_by"))),
                TextField(controller: notesCtrl, decoration: InputDecoration(labelText: t("notes"))),
                Row(
                  children: [
                    Text(t("chronic")),
                    Switch(value: isChronic, onChanged: (v) => update(() => isChronic = v)),
                  ],
                ),
                Text("${t("date")}: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) update(() => selectedDate = picked);
                  },
                  child: Text(t("select_date")),
                )
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t("cancel"))),
            ElevatedButton(
              onPressed: () async {
                final addedBy = widget.isFacility ? widget.facilityId : (widget.isdoctor ? widget.doctorid : '');
                final diagnosis = Diagnosis(
                  id: item?.id ?? "",
                  userId: widget.userId,
                  diseaseName: nameCtrl.text,
                  diagnosisDate: selectedDate,
                  diagnosedBy: byCtrl.text,
                  isChronic: isChronic,
                  detailedNotes: notesCtrl.text,
                  addedBy: addedBy,
                );
                if (editing) {
                  await apiService.updateDiagnosis(widget.userId, item!.id, diagnosis);
                } else {
                  await apiService.addDiagnosis(widget.userId, diagnosis);
                }
                Navigator.pop(ctx);
                _load();
              },
              child: Text(t("save")),
            )
          ],
        );
      }),
    );
  }

  void _confirmDelete(String id, String addedBy) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("delete_diagnosis")),
        content: Text(t("confirm_delete")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t("cancel"))),
          ElevatedButton(
            onPressed: () async {
              await apiService.deleteDiagnosis(widget.userId, id, addedBy);
              Navigator.pop(context);
              _load();
            },
            child: Text(t("delete")),
          )
        ],
      ),
    );
  }

  Widget _card(Diagnosis d) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    final canEdit = (widget.isFacility && d.addedBy == widget.facilityId) ||
        (widget.isdoctor && d.addedBy == widget.doctorid);

    return Card(
      color: Colors.blue[50],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(d.diseaseName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${t("diagnosed_by")}: ${d.diagnosedBy}"),
            Text("${t("date")}: ${d.diagnosisDate.toLocal().toString().split(' ')[0]}"),
            Text("${t("chronic")}: ${d.isChronic ? t("yes") : t("no")}"),
            Text("${t("notes")}: ${d.detailedNotes}"),
          ],
        ),
        trailing: canEdit
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showForm(item: d)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _confirmDelete(d.id, d.addedBy)),
          ],
        )
            : null,
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
      child: Theme(
        data: ThemeData(primarySwatch: Colors.blue),
        child: Scaffold(
          appBar: AppBar(
            title: Text(t("diagnosis_history")),
            actions: [
              Row(
                children: [
                  const Text("EN", style: TextStyle(color: Colors.white)),
                  Switch(
                    value: isArabic,
                    onChanged: (val) => provider.load(val ? "ar" : "en"),
                    activeColor: Colors.white,
                  ),
                  const Text("عربي", style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                ],
              )
            ],
          ),
          floatingActionButton: _canAdd
              ? FloatingActionButton(
            backgroundColor: Colors.blue,
            onPressed: () => _showForm(),
            child: const Icon(Icons.add),
          )
              : null,
          body: FutureBuilder<List<Diagnosis>>(
            future: diagnosisFuture,
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("${t("error")}: ${snapshot.error}"));
              }
              final data = snapshot.data ?? [];
              return ListView(children: data.map(_card).toList());
            },
          ),
        ),
      ),
    );
  }
}
