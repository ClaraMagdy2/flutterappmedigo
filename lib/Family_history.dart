import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class FamilyHistoryScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isFacility;
  final String facilityType;
  final String facilityId;
  final bool isdoctor;
  final String doctorid;

  const FamilyHistoryScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.isFacility,
    required this.facilityType,
    required this.facilityId,
    required this.isdoctor,
    required this.doctorid,
  }) : super(key: key);

  @override
  _FamilyHistoryScreenState createState() => _FamilyHistoryScreenState();
}

class _FamilyHistoryScreenState extends State<FamilyHistoryScreen> {
  late Future<List<dynamic>> _futureHistory;

  bool get canAddOrEdit =>
      (widget.isFacility && widget.facilityType.toLowerCase() == 'hospital') || widget.isdoctor;

  @override
  void initState() {
    super.initState();
    _futureHistory = fetchFamilyHistory();
  }

  Future<List<dynamic>> fetchFamilyHistory() async {
    final url = Uri.parse("http://10.0.2.2:8000/family-history/${widget.userId}");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      }
    } catch (_) {}
    return [];
  }

  void _showAddOrEditDialog(BuildContext context, {Map<String, dynamic>? record}) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    final diseaseController = TextEditingController(text: record?["disease_name"] ?? "");
    final relationController = TextEditingController(text: record?["relative_relationship"] ?? "");
    final ageController = TextEditingController(text: record?["age_of_onset"]?.toString() ?? "");
    final notesController = TextEditingController(text: record?["notes"] ?? "");

    final isEdit = record != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t(isEdit ? 'edit_family_history' : 'add_family_history')),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: diseaseController, decoration: InputDecoration(labelText: t('disease_name'))),
              TextField(controller: relationController, decoration: InputDecoration(labelText: t('relation'))),
              TextField(controller: ageController, decoration: InputDecoration(labelText: t('age_of_onset')), keyboardType: TextInputType.number),
              TextField(controller: notesController, decoration: InputDecoration(labelText: t('notes'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () async {
              final addedBy = widget.isFacility ? widget.facilityId : (widget.isdoctor ? widget.doctorid : '');
              final payload = {
                "disease_name": diseaseController.text,
                "relative_relationship": relationController.text,
                "age_of_onset": int.tryParse(ageController.text) ?? 0,
                "notes": notesController.text,
                "added_by": addedBy,
              };

              final uri = isEdit
                  ? Uri.parse("http://10.0.2.2:8000/family-history/${widget.userId}/${record!["id"]}")
                  : Uri.parse("http://10.0.2.2:8000/family-history/${widget.userId}");
              final method = isEdit ? http.put : http.post;

              final response = await method(
                uri,
                headers: {
                  'Authorization': 'Bearer ${widget.token}',
                  'Content-Type': 'application/json',
                },
                body: json.encode(payload),
              );

              if (response.statusCode == 200) {
                Navigator.pop(context);
                setState(() => _futureHistory = fetchFamilyHistory());
              }
            },
            child: Text(t(isEdit ? 'save' : 'add')),
          ),
        ],
      ),
    );
  }

  void _deleteRecord(Map<String, dynamic> record) async {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('delete_family_history')),
        content: Text(t('confirm_delete')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t('cancel'))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('delete')),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final addedBy = widget.isFacility ? widget.facilityId : (widget.isdoctor ? widget.doctorid : '');
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8000/family-history/${widget.userId}/${record["id"]}?added_by=$addedBy"),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() => _futureHistory = fetchFamilyHistory());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<TranslationProvider>(context).t;
    final lang = Provider.of<TranslationProvider>(context).currentLanguage;
    final isRtl = lang == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t("family_history"), style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF003366),
          actions: [
            Row(
              children: [
                const Text("EN", style: TextStyle(color: Colors.white)),
                Switch(
                  value: lang == 'ar',
                  onChanged: (val) async {
                    await Provider.of<TranslationProvider>(context, listen: false).load(val ? 'ar' : 'en');
                    setState(() {}); // To re-trigger Directionality
                  },
                ),
                const Text("عربي", style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE6F0FA),
        floatingActionButton: canAddOrEdit
            ? FloatingActionButton(
          onPressed: () => _showAddOrEditDialog(context),
          backgroundColor: const Color(0xFF003366),
          child: const Icon(Icons.add),
        )
            : null,
        body: FutureBuilder<List<dynamic>>(
          future: _futureHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());
            if (!snapshot.hasData || snapshot.data!.isEmpty)
              return Center(child: Text(t("no_records_found")));

            final records = snapshot.data!;
            return ListView.builder(
              itemCount: records.length,
              itemBuilder: (_, index) {
                final record = records[index] as Map<String, dynamic>;
                final canEdit = (widget.isFacility && record["added_by"] == widget.facilityId) ||
                    (widget.isdoctor && record["added_by"] == widget.doctorid);
                return Card(
                  margin: const EdgeInsets.all(12),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(record["disease_name"] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF003366))),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("${t("relation")}: ${record["relative_relationship"]}"),
                        Text("${t("age_of_onset")}: ${record["age_of_onset"]}"),
                        Text("${t("notes")}: ${record["notes"] ?? "-"}"),
                      ],
                    ),
                    trailing: canEdit
                        ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.green), onPressed: () => _showAddOrEditDialog(context, record: record)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteRecord(record)),
                      ],
                    )
                        : null,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
