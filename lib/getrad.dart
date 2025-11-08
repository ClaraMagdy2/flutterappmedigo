import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'translation_provider.dart';
import 'radiologylab.dart'; // Upload screen

class RadiologyTestScreen extends StatefulWidget {
  final String token;
  final String userId;
  final String facilityId;
  final String doctorId;
  final bool isFacility;
  final bool isDoctor;

  const RadiologyTestScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.facilityId,
    required this.doctorId,
    required this.isFacility,
    required this.isDoctor,
  }) : super(key: key);

  @override
  State<RadiologyTestScreen> createState() => _RadiologyTestScreenState();
}

class _RadiologyTestScreenState extends State<RadiologyTestScreen> {
  late Future<List<dynamic>> _futureRecords;

  String t(String key) => Provider.of<TranslationProvider>(context, listen: true).t(key);

  Future<List<dynamic>> _fetchRecords() async {
    final url = Uri.parse('http://10.0.2.2:8000/radiology/${widget.userId}');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load records');
    }
  }

  @override
  void initState() {
    super.initState();
    _futureRecords = _fetchRecords();
  }

  void _refresh() {
    setState(() {
      _futureRecords = _fetchRecords();
    });
  }

  void _switchLanguage(BuildContext context) async {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    final newLang = provider.currentLanguage == 'en' ? 'ar' : 'en';
    await provider.load(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF021229);
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Show back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(t('radiology_tests'), style: const TextStyle(color: Colors.white)),
        backgroundColor: darkBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => _switchLanguage(context),
            tooltip: provider.currentLanguage == 'en' ? "العربية" : "English",
          )
        ],
      ),
      backgroundColor: Colors.blue[50],
      body: FutureBuilder<List<dynamic>>(
        future: _futureRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text(t('error_loading_records')));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return Center(child: Text(t('no_records_found')));

          final records = snapshot.data!;
          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(record['radiology_name'] ?? t('no_name')),
                  subtitle: Text('${t('date')}: ${record['date']}'),
                  trailing: record['image_url'] != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(record['image_url'], width: 60, fit: BoxFit.cover),
                  )
                      : null,
                  onTap: () {
                    if (record['image_url'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullImageScreen(
                            imageUrl: record['image_url'],
                            title: record['radiology_name'] ?? t('radiology_image'),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: darkBlue,
        child: const Icon(Icons.add,color: Colors.white,),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RadiologyUploadScreen(
                token: widget.token,
                userId: widget.userId,
                facilityId: widget.facilityId,
                doctorId: widget.doctorId,
                isFacility: widget.isFacility,
                isDoctor: widget.isDoctor,
              ),
            ),
          );
          if (result == true) _refresh();
        },
      ),
    );
  }
}

class FullImageScreen extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullImageScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF021229);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // ✅ Show back arrow
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(title),
        backgroundColor: darkBlue,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
