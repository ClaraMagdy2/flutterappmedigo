import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'translation_provider.dart';

// ---------------- Allergy Model ----------------
class Allergy {
  String? id;
  String allergyName;
  String reactionType;
  String severity;
  String notes;
  String? addedBy;
  String? userId;

  Allergy({
    this.id,
    required this.allergyName,
    required this.reactionType,
    required this.severity,
    required this.notes,
    this.addedBy,
    this.userId,
  });

  factory Allergy.fromJson(Map<String, dynamic> json) {
    return Allergy(
      id: json["id"],
      allergyName: json["allergen_name"] ?? '',
      reactionType: json["reaction_type"] ?? '',
      severity: json["severity"] ?? '',
      notes: json["notes"] ?? '',
      addedBy: json["added_by"],
      userId: json["user_id"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "allergen_name": allergyName,
      "reaction_type": reactionType,
      "severity": severity,
      "notes": notes,
      "added_by": addedBy,
      "user_id": userId,
    };
  }
}

// --------------- API Service ---------------
class AllergyApiService {
  final String baseUrl = "http://10.0.2.2:8000";
  final String token;

  AllergyApiService({required this.token});

  Future<List<Allergy>> fetchAllergies(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/allergies/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Allergy.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load allergies: ${response.body}");
    }
  }

  Future<void> addAllergy(String userId, Allergy allergy) async {
    final response = await http.post(
      Uri.parse("$baseUrl/allergies/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(allergy.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to add allergy: ${response.body}");
    }
  }

  Future<void> updateAllergy(String userId, String recordId, Allergy allergy) async {
    final response = await http.put(
      Uri.parse("$baseUrl/allergies/$userId/$recordId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(allergy.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update allergy: ${response.body}");
    }
  }

  Future<void> deleteAllergy(String userId, String recordId, String addedBy) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/allergies/$userId/$recordId?added_by=$addedBy"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete allergy: ${response.body}");
    }
  }
}

// --------------- Allergy Screen ---------------
class AllergyScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isFacility;
  final String facilityId;
  final String facilityType;
  final bool isdoctor;
  final String doctorid;

  const AllergyScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.isFacility,
    required this.facilityId,
    required this.facilityType,
    required this.isdoctor,
    required this.doctorid,
  }) : super(key: key);

  @override
  State<AllergyScreen> createState() => _AllergyScreenState();
}

class _AllergyScreenState extends State<AllergyScreen> {
  late Future<List<Allergy>> allergyFuture;
  late AllergyApiService apiService;

  bool get canAdd =>
      (widget.isFacility && widget.facilityType.toLowerCase() == "hospital") || widget.isdoctor;

  bool canEditOrDelete(Allergy allergy) {
    return (widget.isFacility && allergy.addedBy == widget.facilityId) ||
        (widget.isdoctor && allergy.addedBy == widget.doctorid);
  }

  @override
  void initState() {
    super.initState();
    apiService = AllergyApiService(token: widget.token);
    _loadAllergies();
  }

  void _loadAllergies() {
    setState(() {
      allergyFuture = apiService.fetchAllergies(widget.userId);
    });
  }

  void _showForm({Allergy? allergy}) {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    final isEdit = allergy != null;
    final nameCtrl = TextEditingController(text: allergy?.allergyName ?? '');
    final reactionCtrl = TextEditingController(text: allergy?.reactionType ?? '');
    final severityCtrl = TextEditingController(text: allergy?.severity ?? '');
    final notesCtrl = TextEditingController(text: allergy?.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(provider.t(isEdit ? "edit_allergy" : "add_allergy")),
        content: SingleChildScrollView(
          child: Column(children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: provider.t("allergy_name"))),
            TextField(controller: reactionCtrl, decoration: InputDecoration(labelText: provider.t("reaction"))),
            TextField(controller: severityCtrl, decoration: InputDecoration(labelText: provider.t("severity"))),
            TextField(controller: notesCtrl, decoration: InputDecoration(labelText: provider.t("notes"))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(provider.t("cancel"))),
          ElevatedButton(
            onPressed: () async {
              final addedBy = widget.isFacility
                  ? widget.facilityId
                  : (widget.isdoctor ? widget.doctorid : '');

              final newAllergy = Allergy(
                allergyName: nameCtrl.text,
                reactionType: reactionCtrl.text,
                severity: severityCtrl.text,
                notes: notesCtrl.text,
                addedBy: addedBy,
                userId: widget.userId,
              );

              try {
                if (isEdit && allergy!.id != null) {
                  await apiService.updateAllergy(widget.userId, allergy.id!, newAllergy);
                } else {
                  await apiService.addAllergy(widget.userId, newAllergy);
                }
                _loadAllergies();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text(provider.t(isEdit ? "save" : "add")),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id, String addedBy) {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(provider.t("delete_allergy")),
        content: Text(provider.t("delete_confirm")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(provider.t("cancel"))),
          ElevatedButton(
            onPressed: () async {
              try {
                await apiService.deleteAllergy(widget.userId, id, addedBy);
                _loadAllergies();
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: Text(provider.t("delete")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isArabic = provider.currentLanguage == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(provider.t("allergic_history")),
          backgroundColor: const Color(0xFF02597A),
          actions: [
            Row(
              children: [
                const Text('EN', style: TextStyle(color: Colors.white)),
                Switch(
                  value: isArabic,
                  onChanged: (value) async {
                    final lang = value ? 'ar' : 'en';
                    await provider.load(lang);
                    setState(() {});
                  },
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey,
                ),
                const Text('عربي', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
        body: FutureBuilder<List<Allergy>>(
          future: allergyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
            final data = snapshot.data ?? [];
            if (data.isEmpty) return Center(child: Text(provider.t("no_records")));
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (_, i) {
                final item = data[i];
                return Card(
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(item.allergyName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${provider.t("reaction")}: ${item.reactionType}"),
                        Text("${provider.t("severity")}: ${item.severity}"),
                        Text("${provider.t("notes")}: ${item.notes}"),
                      ],
                    ),
                    trailing: canEditOrDelete(item)
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showForm(allergy: item)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _confirmDelete(item.id!, item.addedBy ?? '')),
                      ],
                    )
                        : null,
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: canAdd
            ? FloatingActionButton(
          child: const Icon(Icons.add),
          backgroundColor: const Color(0xFF02597A),
          onPressed: () => _showForm(),
        )
            : null,
      ),
    );
  }
}
