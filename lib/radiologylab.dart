import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class RadiologyUploadScreen extends StatefulWidget {
  final String token;
  final String userId;
  final String facilityId;
  final String doctorId;
  final bool isFacility;
  final bool isDoctor;

  const RadiologyUploadScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.facilityId,
    required this.doctorId,
    required this.isFacility,
    required this.isDoctor,
  }) : super(key: key);

  @override
  State<RadiologyUploadScreen> createState() => _RadiologyUploadScreenState();
}

class _RadiologyUploadScreenState extends State<RadiologyUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  File? _selectedImage;
  String? _base64Image;
  bool _isUploading = false;

  static const platform = MethodChannel('com.example.myapp/image_picker');

  String t(String key) => Provider.of<TranslationProvider>(context, listen: false).t(key);

  Future<void> _pickImage() async {
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      if (imagePath != null) {
        String realPath = imagePath.startsWith('content://')
            ? await platform.invokeMethod('getAbsolutePath', imagePath)
            : imagePath;

        final file = File(realPath);
        final bytes = await file.readAsBytes();
        final base64 = base64Encode(bytes);

        setState(() {
          _selectedImage = file;
          _base64Image = base64;
        });
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t("pickFail")}: ${e.message}')),
      );
    }
  }

  Future<void> _uploadRadiology() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("fillAllFields"))),
      );
      return;
    }

    setState(() => _isUploading = true);

    String addedBy = widget.isFacility
        ? widget.facilityId
        : widget.isDoctor
        ? widget.doctorId
        : widget.userId;

    final uri = Uri.parse("http://10.0.2.2:8000/radiology/${widget.userId}");
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer ${widget.token}';
    request.fields['radiology_name'] = _nameCtrl.text;
    request.fields['date_str'] = _dateCtrl.text;
    request.fields['report_notes'] = _notesCtrl.text;
    request.fields['added_by'] = addedBy;

    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    setState(() => _isUploading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("uploadSuccess"))));
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${t("uploadFail")}: ${response.statusCode}\n$respStr')),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final Color darkBlue = const Color(0xFF021229);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Show back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(t("uploadTitle"), style: const TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              provider.toggleLanguage();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image,color: Colors.white),
                label: Text(t("pickImage"),style: TextStyle(color: Colors.white),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              if (_selectedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Image.file(_selectedImage!, height: 200),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: t("testName")),
                validator: (v) => v!.isEmpty ? t("enterTestName") : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dateCtrl,
                decoration: InputDecoration(labelText: t("testDate")),
                validator: (v) {
                  final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
                  return regex.hasMatch(v ?? '') ? null : t("dateFormatError");
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: t("notes")),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                icon: const Icon(Icons.upload,color: Colors.white,),
                label: Text(t("uploadBtn"),style: TextStyle(color: Colors.white)),
                onPressed: _uploadRadiology,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
