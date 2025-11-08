import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import the qr_flutter package
import 'translation_provider.dart'; // Make sure you import your TranslationProvider

class GenerateQrScreen extends StatefulWidget {
  const GenerateQrScreen({Key? key}) : super(key: key);

  @override
  State<GenerateQrScreen> createState() => _GenerateQrScreenState();
}

class _GenerateQrScreenState extends State<GenerateQrScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController nationalIdController = TextEditingController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  String? pdfUrl;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    nationalIdController.dispose();
    super.dispose();
  }

  // Fetch the PDF URL from the server
  Future<void> _fetchPdfUrl() async {
    String nationalId = nationalIdController.text.trim();
    if (nationalId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('enter_national_id'))),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      pdfUrl = null;
      _hasError = false;
    });

    try {
      final uri = Uri.parse(
          'http://10.0.2.2:8000/pdf/$nationalId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          pdfUrl = data['pdf_url'];
          _hasError = pdfUrl == null || pdfUrl!.isEmpty;
        });
      } else {
        setState(() => _hasError = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${t("qr_not_found")}: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() => _hasError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('unexpected_error'))),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildQrView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_hasError) {
      return Column(
        children: [
          Text(t('qr_invalid'),
              style: const TextStyle(color: Colors.red, fontSize: 16)),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _fetchPdfUrl,
            icon: const Icon(Icons.refresh),
            label: Text(t('retry')),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    } else if (pdfUrl != null) {
      return QrImageView(
        data: pdfUrl!,
        size: 200.0,
        gapless: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      );
    } else {
      return Text(t('no_qr_loaded'), style: const TextStyle(fontSize: 18));
    }
  }

  String t(String key) =>
      Provider.of<TranslationProvider>(context, listen: true).t(key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final isArabic = provider.currentLanguage == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t('qr_screen_title')),
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Row(
              children: [
                const Text("EN", style: TextStyle(color: Colors.black)),
                Switch(
                  value: isArabic,
                  onChanged: (value) async {
                    final lang = value ? 'ar' : 'en';
                    await provider.load(lang);
                  },
                  activeColor: Colors.blue,
                ),
                const Text("عربي", style: TextStyle(color: Colors.black)),
              ],
            ),
          ],
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: Column(
                  children: <Widget>[
                    Text(
                      t('qr_instruction'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nationalIdController,
                      decoration: InputDecoration(
                        labelText: t('national_id'),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0288D1), width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF0288D1), width: 3),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _fetchPdfUrl,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF0288D1))
                          : Text(
                        t('get_qr'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0288D1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildQrView(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
