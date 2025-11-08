import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class GenerateScreen extends StatefulWidget {
  final String nationalId;
  final String email;

  const GenerateScreen({required this.nationalId, required this.email, Key? key}) : super(key: key);

  @override
  State<GenerateScreen> createState() => _GenerateScreenState();
}

class _GenerateScreenState extends State<GenerateScreen> with SingleTickerProviderStateMixin {
  bool hasSaved = false;
  bool isLoading = false;
  Uint8List? qrPngBytes;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final GlobalKey repaintKey = GlobalKey();
  String? pdfUrl;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generateAndSaveQr());
  }

  Future<void> _generateAndSaveQr() async {
    if (hasSaved) return;
    setState(() => isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      pdfUrl = await _fetchPdfUrl();
      setState(() {}); // Rebuild with updated pdfUrl
      await Future.delayed(const Duration(milliseconds: 300));
      qrPngBytes = await _capturePng();
      if (qrPngBytes != null && pdfUrl != null) {
        await _saveQrCodeToBackend(qrPngBytes!, pdfUrl!);
        await _updateWidget(pdfUrl!);
        setState(() {
          hasSaved = true;
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("qrGenerated"))));
      }
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("❌ Exception: $e");
    }
  }

  Future<String> _fetchPdfUrl() async {
    final url = 'http://10.0.2.2:8000/pdf/${widget.nationalId}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['pdf_url'];
    } else {
      throw Exception("Failed to fetch PDF");
    }
  }

  Future<Uint8List?> _capturePng() async {
    try {
      RenderRepaintBoundary boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint("❌ Capture error: $e");
      return null;
    }
  }

  Future<void> _saveQrCodeToBackend(Uint8List pngBytes, String encodedData) async {
    final uri = Uri.parse("http://10.0.2.2:8000/qrcode/");
    final request = http.MultipartRequest('POST', uri)

      ..fields['user_id'] = widget.nationalId
      ..fields['last_accessed'] = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())
      ..fields['expiration_date'] = DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now().add(const Duration(days: 30)))
      ..fields['pdf_url'] = encodedData
      ..files.add(http.MultipartFile.fromBytes('qr_image', pngBytes, filename: '${widget.nationalId}_qrcode.png', contentType: MediaType('image', 'png')));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      debugPrint("❌ Upload failed: $body");
      throw Exception("Upload failed");
    }
  }

  Future<void> _updateWidget(String qrCodeData) async {
    try {
      const MethodChannel _channel = MethodChannel('com.example.myapp/widget');
      await _channel.invokeMethod('updateWidget', {'qrCode': qrCodeData});
      debugPrint("✅ Widget updated");
    } catch (e) {
      debugPrint("❌ Widget update failed: $e");
    }
  }

  Future<void> _sendEmail() async {
    try {
      if (qrPngBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("qrNotReady"))));
        return;
      }
      final uri = Uri.parse('http://10.0.2.2:3000/send-email');
      final request = http.MultipartRequest('POST', uri)
        ..fields['to'] = widget.email
        ..fields['subject'] = 'Your QR Code'
        ..fields['text'] = 'Attached is your generated QR code linking to your PDF.'
        ..fields['pdf_url'] = pdfUrl ?? '' // ✅ This sends the actual link
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          qrPngBytes!,
          filename: 'qr_code.png',
        ));

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("emailSent"))));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${t("emailFailed")}: $respStr")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${t("unexpectedError")}: $e")));
    }
  }

  String t(String key) => Provider.of<TranslationProvider>(context, listen: false).t(key);

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF78A0DA),
      appBar: AppBar(
        title: Text(t("qrTitle"), style: const TextStyle(color: Color(0xFF02142E))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF02142E)),
            onPressed: () {
              provider.toggleLanguage();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: RepaintBoundary(
                        key: repaintKey,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.all(12),
                          child: QrImageView(
                            data: pdfUrl ?? "",
                            version: 9,
                            size: 200.0,
                            gapless: false,
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (pdfUrl != null) _updateWidget(pdfUrl!);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF053477),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.save_alt, color: Colors.white),
                    label: Text(t("saveToWidget"), style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _sendEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF053477),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.email_outlined, color: Colors.white),
                    label: Text(t("sendEmail"), style: const TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text("Generating PDF...", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
