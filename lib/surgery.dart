import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class Surgery {
  final String id;
  final String userId;
  final String procedureName;
  final String surgeryDate;
  final String surgeonName;
  final String procedureNotes;
  final String addedBy;

  Surgery({
    required this.id,
    required this.userId,
    required this.procedureName,
    required this.surgeryDate,
    required this.surgeonName,
    required this.procedureNotes,
    required this.addedBy,
  });

  factory Surgery.fromJson(Map<String, dynamic> json) {
    return Surgery(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      procedureName: json['procedure_name'] ?? '',
      surgeryDate: json['surgery_date'] ?? '',
      surgeonName: json['surgeon_name'] ?? '',
      procedureNotes: json['procedure_notes'] ?? '',
      addedBy: json['added_by'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'procedure_name': procedureName,
      'surgery_date': surgeryDate,
      'surgeon_name': surgeonName,
      'procedure_notes': procedureNotes,
      'added_by': addedBy,
    };
  }
}

class SurgeryScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isFacility;
  final String facilityType;
  final String facilityId;
  final bool isdoctor;
  final String doctorid;

  const SurgeryScreen({
    required this.token,
    required this.userId,
    required this.isFacility,
    required this.facilityType,
    required this.facilityId,
    required this.isdoctor,
    required this.doctorid,
  });

  @override
  State<SurgeryScreen> createState() => _SurgeryScreenState();
}

class _SurgeryScreenState extends State<SurgeryScreen> {
  late Future<List<Surgery>> surgeriesFuture;
  final _formKey = GlobalKey<FormState>();
  final _procedureNameController = TextEditingController();
  final _surgeryDateController = TextEditingController();
  final _surgeonController = TextEditingController();
  final _notesController = TextEditingController();
  String? editingId;

  bool get _canEdit =>
      (widget.isFacility && widget.facilityType.toLowerCase() == 'hospital') || widget.isdoctor;

  String t(String key) =>
      Provider.of<TranslationProvider>(context, listen: false).t(key);

  @override
  void initState() {
    super.initState();
    fetchSurgeries();
  }

  void fetchSurgeries() {
    setState(() {
      surgeriesFuture = _getSurgeries();
    });
  }

  Future<List<Surgery>> _getSurgeries() async {
    final url = Uri.parse("http://10.0.2.2:8000/surgeries/${widget.userId}");
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Surgery.fromJson(e)).toList();
    } else {
      throw Exception(t("fetchError"));
    }
  }

  Future<void> _submitSurgery() async {
    if (!_formKey.currentState!.validate()) return;

    final addedBy = widget.isFacility
        ? widget.facilityId
        : (widget.isdoctor ? widget.doctorid : '');

    final surgery = Surgery(
      id: editingId ?? '',
      userId: widget.userId,
      procedureName: _procedureNameController.text,
      surgeryDate: _surgeryDateController.text,
      surgeonName: _surgeonController.text,
      procedureNotes: _notesController.text,
      addedBy: addedBy,
    );

    final uri = editingId == null
        ? Uri.parse("http://10.0.2.2:8000/surgeries/${widget.userId}")
        : Uri.parse("http://10.0.2.2:8000/surgeries/${widget.userId}/${editingId!}");

    final method = editingId == null ? http.post : http.put;

    final response = await method(
      uri,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode(surgery.toJson()),
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      fetchSurgeries();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t("error")}: ${response.body}')),
      );
    }
  }

  void _deleteSurgery(String id, String addedBy) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("deleteSurgery")),
        content: Text(t("confirmDeleteSurgery")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t("cancel"))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t("delete")),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final url = Uri.parse("http://10.0.2.2:8000/surgeries/${widget.userId}/$id?added_by=$addedBy");
      final response = await http.delete(url, headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        fetchSurgeries();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t("deleteFailed")}: ${response.body}')),
        );
      }
    }
  }

  void _showForm({Surgery? surgery}) {
    editingId = surgery?.id;
    _procedureNameController.text = surgery?.procedureName ?? '';
    _surgeryDateController.text = surgery?.surgeryDate ?? '';
    _surgeonController.text = surgery?.surgeonName ?? '';
    _notesController.text = surgery?.procedureNotes ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(surgery == null ? t("addSurgery") : t("editSurgery")),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(controller: _procedureNameController, decoration: InputDecoration(labelText: t("procedureName")), validator: _required),
                TextFormField(controller: _surgeryDateController, decoration: InputDecoration(labelText: t("surgeryDate")), validator: _required),
                TextFormField(controller: _surgeonController, decoration: InputDecoration(labelText: t("surgeonName")), validator: _required),
                TextFormField(controller: _notesController, decoration: InputDecoration(labelText: t("notes"))),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t("cancel"))),
          ElevatedButton(onPressed: _submitSurgery, child: Text(t("save"))),
        ],
      ),
    );
  }

  String? _required(String? value) => (value == null || value.isEmpty) ? t("required") : null;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t("surgeryRecords")),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Switch Language',
            onPressed: () => provider.toggleLanguage(),
          )
        ],
      ),
      floatingActionButton: _canEdit
          ? FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      )
          : null,
      body: FutureBuilder<List<Surgery>>(
        future: surgeriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('${t("error")}: ${snapshot.error}'));
          final data = snapshot.data ?? [];
          if (data.isEmpty) return Center(child: Text(t("noSurgeryRecords")));

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (_, i) {
              final s = data[i];
              final canEdit = (widget.isFacility && s.addedBy == widget.facilityId) ||
                  (widget.isdoctor && s.addedBy == widget.doctorid);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                child: ListTile(
                  title: Text(s.procedureName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${t("date")}: ${s.surgeryDate}"),
                      Text("${t("surgeon")}: ${s.surgeonName}"),
                      Text("${t("notes")}: ${s.procedureNotes}"),
                    ],
                  ),
                  trailing: canEdit
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.green), onPressed: () => _showForm(surgery: s)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteSurgery(s.id, s.addedBy)),
                    ],
                  )
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
