import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:ui' as ui;

class GenerateScreen extends StatelessWidget {
  final String nationalId;
  final String email;
  final MethodChannel _channel = const MethodChannel('com.example.myapp/widget');

  GenerateScreen({required this.nationalId, required this.email});

  Future<void> _updateWidget(String qrCodeData, BuildContext context) async {
    try {
      await _channel.invokeMethod('updateWidget', {'qrCode': qrCodeData});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Widget updated with QR code!")),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update widget: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    }
  }

  Future<void> _sendEmail(String email, BuildContext context) async {
    try {
      final pngBytes = await _generatePngBytes(nationalId);
      if (pngBytes != null) {
        final uri = Uri.parse('http://10.0.2.2:3000/send-email'); // Replace with your backend URL

        final request = http.MultipartRequest('POST', uri)
          ..fields['to'] = email
          ..fields['subject'] = 'Your QR Code'
          ..fields['text'] = 'Here is your QR code attached.'
          ..files.add(http.MultipartFile.fromBytes(
            'image',
            pngBytes,
            filename: 'qr_code.png', // Backend will detect file type from extension
          ));

        final response = await request.send();

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email sent successfully!')),
          );
        } else {
          final respStr = await response.stream.bytesToString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send email: $respStr')),
          );
        }
      } else {
        throw Exception("Failed to generate QR code PNG");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $e")),
      );
    }
  }

  Future<Uint8List?> _generatePngBytes(String data) async {
    try {
      final qrPainter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
      );

      final ui.Picture picture = qrPainter.toPicture(200);
      final ui.Image image = await picture.toImage(400, 400);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        return byteData.buffer.asUint8List();
      } else {
        throw Exception("Failed to convert QR code to byte data");
      }
    } catch (e) {
      debugPrint("Error generating QR code PNG: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator',style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF02597A), // Light muted blue
                Color(0xFF043459), // Medium muted blue
                Color(0xFF021229), // Dark muted blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF02597A), // Light muted blue
              Color(0xFF043459), // Medium muted blue
              Color(0xFF021229), // Dark muted blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: QrImageView(
                data: nationalId,
                size: 300.0,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateWidget(nationalId, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF02597A), // Light muted blue
              ),
              child: const Text('Save to Widget in Home',style: TextStyle(color: Colors.white))
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _sendEmail(email, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF043459), // Medium muted blue
              ),
              child: const Text('Send QR Code via Email',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}