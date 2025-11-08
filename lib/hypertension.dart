import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class HypertensionScreen extends StatefulWidget {
  final String token;
  final String userId;
  final String facilityType;
  final String facilityId;
  final bool isFacility;
  final bool isdoctor;
  final String doctorid;

  const HypertensionScreen({
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
  State<HypertensionScreen> createState() => _HypertensionScreenState();
}

class _HypertensionScreenState extends State<HypertensionScreen> {
  List<Map<String, dynamic>> bpRecords = [];

  bool get _canAddOrEdit => true;

  String get _currentEditorId {
    if (widget.isFacility) return widget.facilityId;
    if (widget.isdoctor) return widget.doctorid;
    return widget.userId;
  }

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:8000/hypertension/${widget.userId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          bpRecords = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        throw Exception("Failed to load records");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _addRecord(String systolic, String diastolic) async {
    final t = context.read<TranslationProvider>().t;
    try {
      final body = {
        "sys_value": int.parse(systolic),
        "dia_value": int.parse(diastolic),
        "added_by": _currentEditorId,
      };
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/hypertension/${widget.userId}"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        _fetchRecords();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("add_success"))));
      } else {
        throw Exception("Failed to add record");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _updateRecord(String recordId, String systolic, String diastolic) async {
    try {
      final t = context.read<TranslationProvider>().t;
      final body = {
        "sys_value": int.parse(systolic),
        "dia_value": int.parse(diastolic),
        "added_by": _currentEditorId,
      };
      final response = await http.put(
        Uri.parse("http://10.0.2.2:8000/hypertension/${widget.userId}/$recordId"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        _fetchRecords();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("update_success"))));
      } else {
        throw Exception("Failed to update record");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _deleteRecord(String recordId, String addedBy) async {
    try {
      final t = context.read<TranslationProvider>().t;
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:8000/hypertension/${widget.userId}/$recordId?added_by=$addedBy"),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );
      if (response.statusCode == 200) {
        _fetchRecords();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("delete_success"))));
      } else {
        throw Exception("Failed to delete record");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _showAddDialog() {
    final t = context.read<TranslationProvider>().t;
    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("add_record3")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              decoration: InputDecoration(labelText: t("systolicLabel")),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: diastolicController,
              decoration: InputDecoration(labelText: t("diastolicLabel")),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _addRecord(systolicController.text, diastolicController.text);
              Navigator.of(context).pop();
            },
            child: Text(t("save")),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t("cancel")),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    final t = context.read<TranslationProvider>().t;
    final systolicController = TextEditingController(text: item['sys_value'].toString());
    final diastolicController = TextEditingController(text: item['dia_value'].toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("edit_record3")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: systolicController,
              decoration: InputDecoration(labelText: t("systolicLabel")),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: diastolicController,
              decoration: InputDecoration(labelText: t("diastolicLabel")),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(t("cancel"))),
          ElevatedButton(
            onPressed: () {
              _updateRecord(item['id'], systolicController.text, diastolicController.text);
              Navigator.of(context).pop();
            },
            child: Text(t("update")),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String recordId, String addedBy) {
    final t = context.read<TranslationProvider>().t;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t("delete")),
        content: Text(t("deleteConfirm")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t("cancel"))),
          ElevatedButton(
            onPressed: () {
              _deleteRecord(recordId, addedBy);
              Navigator.pop(context);
            },
            child: Text(t("delete")),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<TranslationProvider>().t;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Show back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(t("screenTitle1"), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF021229),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: "Switch Language",
            onPressed: () => context.read<TranslationProvider>().toggleLanguage(),
          )
        ],
      ),
      body: bpRecords.isEmpty
          ? Center(child: Text(t("noRecords")))
          : ListView.builder(
        itemCount: bpRecords.length,
        itemBuilder: (context, index) {
          final item = bpRecords[index];
          final isOwnRecord = item['added_by'] == _currentEditorId;
          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              title: Text(
                "${t("systolicLabel")}: ${item['sys_value']}  |  ${t("diastolicLabel")}: ${item['dia_value']}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${t("date")}: ${item['timestamp']}"),
              trailing: isOwnRecord
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditDialog(item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(item['id'], item['added_by']),
                  ),
                ],
              )
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: _canAddOrEdit
          ? FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFF021229),
        child: const Icon(Icons.add,color: Colors.white),
      )
          : null,
    );
  }
}
