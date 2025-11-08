import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class MedicationHistoryScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isFacility;
  final String facilityId;
  final String facilityType;
  final bool isdoctor;
  final String doctorid;

  const MedicationHistoryScreen({
    required this.token,
    required this.userId,
    required this.isFacility,
    required this.facilityId,
    required this.facilityType,
    required this.isdoctor,
    required this.doctorid,
  });

  @override
  State<MedicationHistoryScreen> createState() => _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  List<Map<String, dynamic>> medicationHistoryList = [];
  bool isLoading = true;

  bool get canAddOrEdit =>
      (widget.isFacility &&
          (widget.facilityType.toLowerCase() == 'pharmacy' ||
              widget.facilityType.toLowerCase() == 'hospital')) ||
          widget.isdoctor;

  @override
  void initState() {
    super.initState();
    fetchMedications();
  }

  Future<void> fetchMedications() async {
    try {
      final t = context.read<TranslationProvider>().t;
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/medications/${widget.userId}"),
        headers: {"Authorization": "Bearer ${widget.token}"},
      );
      print("🔵 Response body: ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          medicationHistoryList = List<Map<String, dynamic>>.from(jsonDecode(response.body));
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load medications");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching medications: $e");
    }
  }

  Future<void> deleteMedication(String docId) async {
    final t = context.read<TranslationProvider>().t;
    final addedBy = widget.isFacility
        ? widget.facilityId
        : (widget.isdoctor ? widget.doctorid : '');

    final url = "http://10.0.2.2:8000/medications/${widget.userId}/$docId?added_by=$addedBy";
    final response = await http.delete(
      Uri.parse(url),
      headers: {"Authorization": "Bearer ${widget.token}"},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("deleteSuccess"))));
      fetchMedications();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t("deleteFailed")}: ${response.body}")),
      );
    }
  }

  void _showMedicationDialog({Map<String, dynamic>? existing}) {
    final t = context.read<TranslationProvider>().t;

    final tradeNameCtrl = TextEditingController(text: existing?['trade_name'] ?? '');
    final scientificNameCtrl = TextEditingController(text: existing?['scientific_name'] ?? '');
    final dosageCtrl = TextEditingController(text: existing?['dosage'] ?? '');
    final frequencyCtrl = TextEditingController(text: existing?['frequency'] ?? '');
    final doctorCtrl = TextEditingController(text: existing?['prescribing_doctor'] ?? '');
    final notesCtrl = TextEditingController(text: existing?['notes'] ?? '');

    DateTime? startDate = existing?['start_date'] != null
        ? DateTime.tryParse(existing!['start_date'])
        : null;
    DateTime? endDate = existing?['end_date'] != null
        ? DateTime.tryParse(existing!['end_date'])
        : null;
    bool certainDuration = existing?['certain_duration'] ?? true;
    bool isCurrent = existing?['current'] ?? false;
    bool isBpMedication = existing?['bp_medication'] ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              scrollable: true,
              title: Text(existing == null ? t("add_record1") : t("edit_record1")),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(controller: tradeNameCtrl, decoration: InputDecoration(labelText: t("trade_name"))),
                    TextField(controller: scientificNameCtrl, decoration: InputDecoration(labelText: t("scientific_name"))),
                    TextField(controller: dosageCtrl, decoration: InputDecoration(labelText: t("dosage"))),
                    TextField(controller: frequencyCtrl, decoration: InputDecoration(labelText: t("frequency"))),
                    TextField(controller: doctorCtrl, decoration: InputDecoration(labelText: t("prescribing_doctor"))),
                    TextField(controller: notesCtrl, decoration: InputDecoration(labelText: t("notes"))),
                    SwitchListTile(
                      title: Text(t("certain_duration")),
                      value: certainDuration,
                      onChanged: (v) => setDialogState(() => certainDuration = v),
                    ),
                    if (certainDuration || isCurrent)
                      Row(
                        children: [
                          Text("${t("start")}: ${startDate != null ? startDate!.toLocal().toString().split(' ')[0] : t("not_selected")}"),
                          Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setDialogState(() => startDate = picked);
                            },
                            child: Text(t("pick_start")),
                          ),
                        ],
                      ),
                    if (certainDuration)
                      Row(
                        children: [
                          Text("${t("end")}: ${endDate != null ? endDate!.toLocal().toString().split(' ')[0] : t("not_selected")}"),
                          Spacer(),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setDialogState(() => endDate = picked);
                            },
                            child: Text(t("pick_end")),
                          ),
                        ],
                      ),
                    SwitchListTile(
                      title: Text(t("current")),
                      value: isCurrent,
                      onChanged: (v) => setDialogState(() => isCurrent = v),
                    ),
                    SwitchListTile(
                      title: Text(t("bp_medication")),
                      value: isBpMedication,
                      onChanged: (v) => setDialogState(() => isBpMedication = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: Text(t("cancel"))),
                ElevatedButton(
                  onPressed: () async {
                    if ((isCurrent || certainDuration) && startDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(t("select_start_date"))),
                      );
                      return;
                    }

                    final addedBy = widget.isFacility
                        ? widget.facilityId
                        : (widget.isdoctor ? widget.doctorid : '');

                    final body = {
                      "trade_name": tradeNameCtrl.text.trim(),
                      "scientific_name": scientificNameCtrl.text.trim(),
                      "dosage": dosageCtrl.text.trim(),
                      "frequency": frequencyCtrl.text.trim(),
                      "certain_duration": certainDuration,
                      "current": isCurrent,
                      "prescribing_doctor": doctorCtrl.text.trim(),
                      "notes": notesCtrl.text.trim(),
                      "added_by": addedBy,
                      "bp_medication": isBpMedication,
                    };

                    if ((certainDuration || isCurrent) && startDate != null) {
                      body["start_date"] = startDate!.toIso8601String().split('T')[0];
                    }
                    if (certainDuration && endDate != null) {
                      body["end_date"] = endDate!.toIso8601String().split('T')[0];
                    }

                    body.removeWhere((key, value) => value == null || (value is String && value.trim().isEmpty));

                    final url = existing == null
                        ? "http://10.0.2.2:8000/medications/${widget.userId}"
                        : "http://10.0.2.2:8000/medications/${widget.userId}/${existing['doc_id']}";

                    final response = existing == null
                        ? await http.post(Uri.parse(url),
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer ${widget.token}"
                        },
                        body: jsonEncode(body))
                        : await http.put(Uri.parse(url),
                        headers: {
                          "Content-Type": "application/json",
                          "Authorization": "Bearer ${widget.token}"
                        },
                        body: jsonEncode(body));

                    if (response.statusCode == 200) {
                      Navigator.pop(context);
                      fetchMedications();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(existing == null ? t("addSuccess") : t("updateSuccess"))),
                      );
                    } else {
                      final error = jsonDecode(response.body);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${t("error")}: ${error['detail'] ?? response.body}")),
                      );
                    }
                  },
                  child: Text(existing == null ? t("add") : t("update")),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildMedicationCard(Map<String, dynamic> item) {
    final t = context.read<TranslationProvider>().t;

    final addedBy = item['added_by'] ?? '';
    final isOwner = addedBy == widget.facilityId || addedBy == widget.doctorid;
    final canEditThis = canAddOrEdit && isOwner;

    return Card(
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['trade_name'] ?? t("unknown"),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900])),
            SizedBox(height: 8),
            Text("${t("scientific_name")}: ${item['scientific_name'] ?? ''}"),
            Text("${t("dosage")}: ${item['dosage'] ?? ''}"),
            Text("${t("frequency")}: ${item['frequency'] ?? ''}"),
            Text("${t("current")}: ${item['current'] == true ? t("yes") : t("no")}"),
            if (item['start_date'] != null) Text("${t("start_date")}: ${item['start_date']}\ "),
            if (item['end_date'] != null) Text("${t("end_date")}: ${item['end_date']}\ "),
            if (item['prescribing_doctor'] != null) Text("${t("prescribing_doctor")}: ${item['prescribing_doctor']}"),
            if (item['bp_medication'] == true) Text(t("bp_medication")),
            if (item['notes'] != null && item['notes'].toString().isNotEmpty) Text("${t("notes")}: ${item['notes']}"),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: canEditThis
                  ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _showMedicationDialog(existing: item);
                  if (value == 'delete') deleteMedication(item['doc_id']);
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(value: 'edit', child: Text(t("edit"))),
                  PopupMenuItem(value: 'delete', child: Text(t("delete"))),
                ],
              )
                  : Tooltip(
                message: t("cannot_edit"),
                child: Icon(Icons.lock_outline, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<TranslationProvider>().t;

    return Scaffold(
      backgroundColor: Colors.blue[100],
      appBar: AppBar(
        title: Text(t("medication_history")),
        backgroundColor: Colors.blue[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : medicationHistoryList.isEmpty
          ? Center(child: Text(t("no_records"), style: TextStyle(color: Colors.blue[900])))
          : ListView(
        children: medicationHistoryList.map((item) => buildMedicationCard(item)).toList(),
      ),
      floatingActionButton: canAddOrEdit
          ? FloatingActionButton(
        onPressed: () => _showMedicationDialog(),
        backgroundColor: Colors.blue[800],
        child: Icon(Icons.add),
      )
          : null,
    );
  }
}