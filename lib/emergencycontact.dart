import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'translation_provider.dart'; // Make sure this file is created

class EmergencyContact {
  final String? id;
  final String userId;
  final String fullName;
  final String relationship;
  final String phoneNumber;

  EmergencyContact({
    this.id,
    required this.userId,
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'],
      userId: json['user_id'] ?? '',
      fullName: json['full_name'] ?? '',
      relationship: json['relationship'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'full_name': fullName,
    'relationship': relationship,
    'phone_number': phoneNumber,
  };
}

class EmergencyContactApiService {
  final String baseUrl = "http://10.0.2.2:8000";
  final String token;

  EmergencyContactApiService({required this.token});

  Map<String, String> _headers() => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<List<EmergencyContact>> fetchContacts(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/emergency-contacts/$userId"),
      headers: _headers(),
    );
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => EmergencyContact.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch: ${response.body}");
    }
  }

  Future<void> createContact(EmergencyContact c) async {
    final response = await http.post(
      Uri.parse("$baseUrl/emergency-contacts/${c.userId}"),
      headers: _headers(),
      body: jsonEncode(c.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to create: ${response.body}");
    }
  }

  Future<void> updateContact(EmergencyContact c) async {
    final response = await http.put(
      Uri.parse("$baseUrl/emergency-contacts/${c.userId}/${c.id}"),
      headers: _headers(),
      body: jsonEncode(c.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to update: ${response.body}");
    }
  }

  Future<void> deleteContact(String userId, String id) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/emergency-contacts/$userId/$id"),
      headers: _headers(),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to delete: ${response.body}");
    }
  }
}

class MyEmergencyContactScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isFacility;
  final String facilityId;
  final String facilityType;
  final bool isdoctor;

  const MyEmergencyContactScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.isFacility,
    required this.facilityId,
    required this.facilityType,
    required this.isdoctor,
  });

  @override
  State<MyEmergencyContactScreen> createState() => _MyEmergencyContactScreenState();
}

class _MyEmergencyContactScreenState extends State<MyEmergencyContactScreen> {
  late EmergencyContactApiService apiService;
  late Future<List<EmergencyContact>> contactsFuture;

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    apiService = EmergencyContactApiService(token: widget.token);
    _loadContacts();
  }

  void _loadContacts() {
    setState(() {
      contactsFuture = apiService.fetchContacts(widget.userId);
    });
  }

  void _showAddOrEditDialog({EmergencyContact? contact}) {
    final provider = Provider.of<TranslationProvider>(context, listen: false);
    final t = provider.t;
    final isEditing = contact != null;
    _fullNameController.text = contact?.fullName ?? '';
    _phoneController.text = contact?.phoneNumber ?? '';
    _relationshipController.text = contact?.relationship ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? t('edit_contact') : t('add_contact')),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: t('full_name')),
                validator: _required,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: t('phone')),
                validator: _required,
              ),
              TextFormField(
                controller: _relationshipController,
                decoration: InputDecoration(labelText: t('relationship')),
                validator: _required,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newC = EmergencyContact(
                  id: contact?.id,
                  userId: widget.userId,
                  fullName: _fullNameController.text,
                  phoneNumber: _phoneController.text,
                  relationship: _relationshipController.text,
                );
                isEditing
                    ? await apiService.updateContact(newC)
                    : await apiService.createContact(newC);
                Navigator.pop(context);
                _loadContacts();
              }
            },
            child: Text(t('save')),
          )
        ],
      ),
    );
  }

  String? _required(String? v) => v == null || v.isEmpty ? 'Required' : null;

  void _confirmDelete(EmergencyContact c) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t('delete_contact')),
        content: Text(t('delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await apiService.deleteContact(widget.userId, c.id!);
              Navigator.pop(context);
              _loadContacts();
            },
            child: Text(t('delete')),
          )
        ],
      ),
    );
  }

  Widget _buildCard(EmergencyContact c) {
    final t = Provider.of<TranslationProvider>(context).t;
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${t('phone')}: ${c.phoneNumber}"),
            Text("${t('relationship')}: ${c.relationship}"),
          ],
        ),
        trailing: (!widget.isFacility && !widget.isdoctor)
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showAddOrEditDialog(contact: c),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(c),
            ),
          ],
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);
    final t = provider.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("emergency_contacts")),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () async {
              String newLang = provider.currentLanguage == 'en' ? 'ar' : 'en';
              await provider.load(newLang);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<EmergencyContact>>(
        future: contactsFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return Center(child: Text(t("no_contacts")));
          }
          return ListView(children: data.map(_buildCard).toList());
        },
      ),
      floatingActionButton: (!widget.isFacility && !widget.isdoctor)
          ? FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
