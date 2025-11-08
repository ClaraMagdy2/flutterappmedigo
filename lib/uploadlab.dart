import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'LabtestScreen.dart'; // This should include your BiomarkerService
import 'translation_provider.dart';

class UploadBiomarkerScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isfacility;
  final String facilityId;
  final String facilityType;
  final String doctorid;
  final bool isdoctor;

  const UploadBiomarkerScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.isfacility,
    required this.facilityId,
    required this.facilityType,
    required this.doctorid,
    required this.isdoctor,
  }) : super(key: key);

  @override
  State<UploadBiomarkerScreen> createState() => _UploadBiomarkerScreenState();
}

class _UploadBiomarkerScreenState extends State<UploadBiomarkerScreen> {
  File? _selectedImage;
  bool _uploading = false;

  String t(String key) =>
      Provider.of<TranslationProvider>(context, listen: false).t(key);

  Future<void> _pickImage() async {
    try {
      final String? imagePath = await const MethodChannel('com.example.myapp/image_picker')
          .invokeMethod<String>('pickImage');

      if (imagePath != null && mounted) {
        setState(() {
          _selectedImage = File(imagePath);
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t("imageError")}: ${e.message}")),
      );
    }
  }

  Future<void> _submit() async {
    if (_selectedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("selectImageFirst"))),
      );
      return;
    }

    if (mounted) {
      setState(() => _uploading = true);
    }

    try {
      final service = BiomarkerService(token: widget.token);
      final addedBy = widget.isfacility
          ? widget.facilityId
          : widget.isdoctor
          ? widget.doctorid
          : widget.userId;

      final isPrivileged = widget.isfacility ||
          widget.isdoctor ||
          widget.facilityType.toLowerCase() == 'hospital' ||
          widget.facilityType.toLowerCase() == 'laboratory';

      final result = await service.uploadOCR(
        nationalId: widget.userId,
        addedBy: addedBy,
        image: _selectedImage!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isPrivileged ? t("uploadSuccess") : t("submittedForApproval")),
      ));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t("uploadFailed")}: $e")),
      );
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkBlue = const Color(0xFF021229);
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Show back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(t("uploadBiomarker")),
        backgroundColor: darkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: 'Switch Language',
            onPressed: () => provider.toggleLanguage(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 250)
                : Container(
              height: 250,
              color: Colors.grey[300],
              child: Center(child: Text(t("noImageSelected"))),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.image),
              label: Text(t("pickImage")),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: _uploading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(t("submit")),
              onPressed: _uploading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: darkBlue),
            ),
          ],
        ),
      ),
    );
  }
}
