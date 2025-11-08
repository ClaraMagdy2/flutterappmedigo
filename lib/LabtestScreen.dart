import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class BiomarkerService {
  final String baseUrl = "http://10.0.2.2:8000"; // Change to your backend URL
  final String token;

  BiomarkerService({required this.token});

  Future<List<dynamic>> getApprovedBiomarkers(String nationalId) async {
    final url = Uri.parse("$baseUrl/biomarkers/$nationalId");
    final response = await http.get(url, headers: {"Authorization": "Bearer $token"});
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception("Failed to load biomarkers: ${response.statusCode}");
  }

  Future<Map<String, dynamic>> uploadOCR({
    required String nationalId,
    required String addedBy,
    required File image,
  }) async {
    final uri = Uri.parse("$baseUrl/biomarkers/$nationalId/ocr");
    final request = http.MultipartRequest("POST", uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['added_by'] = addedBy
      ..files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 200 || response.statusCode == 202) return jsonDecode(responseBody);
    throw Exception("Upload failed: ${response.statusCode}\n$responseBody");
  }

  Future<void> addManualEntry({
    required String nationalId,
    required String addedBy,
    required String item,
    required String value,
    String unit = '',
    String referenceRange = '',
  }) async {
    final url = Uri.parse("$baseUrl/biomarkers/$nationalId/manual");
    final response = await http.post(
      url,
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode({
        "added_by": addedBy,
        "item": item,
        "value": value,
        "unit": unit,
        "reference_range": referenceRange,
      }),
    );
    if (response.statusCode != 200) throw Exception("Failed to add manual entry: ${response.statusCode}");
  }

  Future<void> updateManualEntry({
    required String nationalId,
    required String recordId,
    required List<Map<String, dynamic>> updatedResults,
  }) async {
    final url = Uri.parse("$baseUrl/biomarkers/$nationalId/edit");
    final response = await http.put(
      url,
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: jsonEncode({
        "timestamp_id": recordId,
        "updated_results": updatedResults,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update entry: ${response.statusCode}\n${response.body}");
    }
  }
}

class BiomarkerScreen extends StatefulWidget {
  final String token, userId, facilityId, facilityType, doctorid;
  final bool isfacility, isdoctor;

  const BiomarkerScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.isfacility,
    required this.facilityId,
    required this.facilityType,
    required this.doctorid,
    required this.isdoctor,
  });

  @override
  State<BiomarkerScreen> createState() => _BiomarkerScreenState();
}

class _BiomarkerScreenState extends State<BiomarkerScreen> {
  List<dynamic> biomarkers = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadBiomarkers();
  }

  Future<void> _loadBiomarkers() async {
    try {
      final service = BiomarkerService(token: widget.token);
      setState(() => loading = true);
      final data = await service.getApprovedBiomarkers(widget.userId);
      setState(() {
        biomarkers = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _pickImageAndUpload() async {
    final t = context.read<TranslationProvider>().t;
    try {
      final imagePath = await const MethodChannel('com.example.myapp/image_picker').invokeMethod('pickImage');
      if (imagePath == null) return;

      final imageFile = File(imagePath);
      final service = BiomarkerService(token: widget.token);
      final addedBy = widget.isfacility
          ? widget.facilityId
          : widget.isdoctor
          ? widget.doctorid
          : widget.userId;

      final result = await service.uploadOCR(
        nationalId: widget.userId,
        addedBy: addedBy,
        image: imageFile,
      );

      if (widget.isfacility || widget.isdoctor || ["hospital", "laboratory"].contains(widget.facilityType.toLowerCase())) {
        _loadBiomarkers();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("addSuccess"))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("submittedForApproval"))));
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image error: ${e.message}")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
    }
  }

  Widget _buildResultCard(Map<String, dynamic> record) {
    final t = context.read<TranslationProvider>().t;
    final date = record['extracted_date'] ?? 'No Date';
    final imageUrl = record['image_url'];
    final List<dynamic> results = record['results'] ?? [];
    final timestampId = record['id'];

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: ExpansionTile(
        title: Text("${t("testOn")}$date", style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: imageUrl != null
            ? GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text(t("viewImage"))),
                body: Center(child: Image.network(imageUrl)),
              ),
            ),
          ),
          child: Image.network(imageUrl, width: 40),
        )
            : null,
        children: [
          ...results.map<Widget>((r) {
            final isFlagged = r['flag'] == true;
            return ListTile(
              title: Text("${r['item']} - ${r['value']} ${r['unit'] ?? ''}"),
              subtitle: Text("${t("reference")}: ${r['reference_range'] ?? 'N/A'}"),
              trailing: Icon(
                isFlagged ? Icons.warning : Icons.check_circle,
                color: isFlagged ? Colors.red : Colors.green,
              ),
              onTap: (widget.isdoctor || widget.isfacility)
                  ? () async {
                final edited = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (_) => _ManualEntryDialog(
                    item: r['item'],
                    value: r['value'],
                    unit: r['unit'],
                    referenceRange: r['reference_range'],
                    isEdit: true,
                  ),
                );
                if (edited != null) {
                  final List<Map<String, dynamic>> updatedResults = results.map<Map<String, dynamic>>((entry) {
                    final isSame = entry['item'] == r['item'] && entry['value'] == r['value'];
                    return isSame
                        ? {
                      "item": edited['item'],
                      "value": edited['value'],
                      "unit": edited['unit'] ?? '',
                      "reference_range": edited['reference_range'] ?? '',
                      "flag": false,
                    }
                        : Map<String, dynamic>.from(entry);
                  }).toList();

                  try {
                    await BiomarkerService(token: widget.token).updateManualEntry(
                      nationalId: widget.userId,
                      recordId: timestampId,
                      updatedResults: updatedResults,
                    );
                    _loadBiomarkers();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${t("updateFailed")}: $e")),
                    );
                  }
                }
              }
                  : null, // Disable tap for patients
            );
          }),
          if (widget.isdoctor || widget.isfacility)
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(t("addManual")),
              onPressed: () async {
                final newItem = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (_) => const _ManualEntryDialog(),
                );
                if (newItem != null) {
                  final addedBy = widget.isfacility
                      ? widget.facilityId
                      : widget.isdoctor
                      ? widget.doctorid
                      : widget.userId;
                  try {
                    await BiomarkerService(token: widget.token).addManualEntry(
                      nationalId: widget.userId,
                      addedBy: addedBy,
                      item: newItem['item']!,
                      value: newItem['value']!,
                      unit: newItem['unit'] ?? '',
                      referenceRange: newItem['reference_range'] ?? '',
                    );
                    _loadBiomarkers();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("addSuccess"))));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${t("error")}: $e")));
                  }
                }
              },
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
        title: Text(t("screenTitle"), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF021229),
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
          : biomarkers.isEmpty
          ? Center(child: Text(t("noRecords")))
          : ListView(children: biomarkers.map((b) => _buildResultCard(b)).toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImageAndUpload,
        backgroundColor: const Color(0xFF021229),
        child: const Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}

class _ManualEntryDialog extends StatefulWidget {
  final String? item, value, unit, referenceRange;
  final bool isEdit;

  const _ManualEntryDialog({this.item, this.value, this.unit, this.referenceRange, this.isEdit = false});

  @override
  State<_ManualEntryDialog> createState() => _ManualEntryDialogState();
}

class _ManualEntryDialogState extends State<_ManualEntryDialog> {
  late TextEditingController _itemController;
  late TextEditingController _valueController;
  late TextEditingController _unitController;
  late TextEditingController _refRangeController;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.item);
    _valueController = TextEditingController(text: widget.value);
    _unitController = TextEditingController(text: widget.unit);
    _refRangeController = TextEditingController(text: widget.referenceRange);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<TranslationProvider>().t;
    return AlertDialog(
      title: Text(widget.isEdit ? t("edit_record1") : t("add_record1")),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: _itemController, decoration: InputDecoration(labelText: t("test_name"))),
            TextField(controller: _valueController, decoration: InputDecoration(labelText: t("value"))),
            TextField(controller: _unitController, decoration: InputDecoration(labelText: t("unit"))),
            TextField(controller: _refRangeController, decoration: InputDecoration(labelText: t("reference_range"))),
          ],
        ),
      ),
      actions: [
        TextButton(child: Text(t("cancel")), onPressed: () => Navigator.pop(context)),
        ElevatedButton(
          child: Text(widget.isEdit ? t("update") : t("add")),
          onPressed: () => Navigator.pop(context, {
            "item": _itemController.text,
            "value": _valueController.text,
            "unit": _unitController.text,
            "reference_range": _refRangeController.text,
          }),
        ),
      ],
    );
  }
}
