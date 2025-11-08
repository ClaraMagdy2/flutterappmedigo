import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class AdminApiService {
  final String baseUrl = "http://10.0.2.2:8000";
  final String token;
  final String adminId;

  AdminApiService({required this.token, required this.adminId});

  Future<void> registerEntity(Map<String, dynamic> data) async {
    final type = data['registration_type'];
    final endpoint = type == 'facility'
        ? '/facility/$adminId'
        : '/doctors/$adminId';

    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token"
      },
      body: jsonEncode(data),
    );
    if (response.statusCode >= 300) {
      throw Exception("Failed to register: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> searchEntities(String type, String query) async {
    final endpoint = type == 'Facility' ? '/facilities' : '/clinicians';
    final uri = Uri.parse("$baseUrl$endpoint").replace(queryParameters: {
      'name': query,
      'id': query
    });

    final response = await http.get(uri, headers: {
      "Authorization": "Bearer $token"
    });

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      } else {
        return [];
      }
    } else {
      throw Exception("Failed to search $type");
    }
  }

  Future<void> deleteEntity(String type, String documentId) async {
    final endpoint = type == 'Facility'
        ? '/facility/$documentId'
        : '/doctors/$documentId';

    final response = await http.delete(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to delete $type: ${response.body}");
    }
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await http.get(
      Uri.parse("$baseUrl/notifications"),
      headers: {"Authorization": "Bearer $token"},
    );

    final decoded = jsonDecode(response.body);
    if (decoded is Map && decoded.containsKey("notifications")) {
      return List<Map<String, dynamic>>.from(decoded['notifications']);
    } else {
      throw Exception("Invalid notification response format");
    }
  }
}

class AdminRegisterScreen extends StatefulWidget {
  final String token;
  final String adminId;

  const AdminRegisterScreen({super.key, required this.token, required this.adminId});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  late AdminApiService apiService;
  final searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> notifications = [];
  String? selectedType;

  @override
  void initState() {
    super.initState();
    apiService = AdminApiService(token: widget.token, adminId: widget.adminId);
    fetchNotifications();
    Timer.periodic(const Duration(minutes: 1), (_) => fetchNotifications());
  }

  Future<void> fetchNotifications() async {
    try {
      final result = await apiService.getNotifications();
      setState(() => notifications = result);
    } catch (e) {
      print("Notification fetch error: $e");
    }
  }

  void _showNotificationDialog() {
    final t = context.read<TranslationProvider>().t;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("doctor_assignment_notifications")),
        content: notifications.isEmpty
            ? Text(t("no_notifications"))
            : SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final timestamp = DateTime.tryParse(notif['timestamp'] ?? '');
              final readableTime = timestamp != null
                  ? timestamp.toLocal().toString().substring(0, 19)
                  : t("unknown");
              return ListTile(
                leading: const Icon(Icons.notification_important, color: Colors.red),
                title: Text(notif['message'] ?? ''),
                subtitle: Text("${t("time")}: $readableTime"),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t("close")))],
      ),
    );
  }

  Future<void> _searchEntities(String query) async {
    if (selectedType == null) return;
    try {
      final results = await apiService.searchEntities(selectedType!, query);
      setState(() => searchResults = results);
    } catch (e) {
      print("Search error: $e");
    }
  }

  void _showAddDialog() {
    final t = context.read<TranslationProvider>().t;
    final _formKey = GlobalKey<FormState>();
    final Map<String, TextEditingController> controllers = {
      'name': TextEditingController(),
      'type': TextEditingController(text: 'hospital'),
      'address': TextEditingController(),
      'city': TextEditingController(),
      'region': TextEditingController(text: 'Default'),
      'email': TextEditingController(),
      'phone': TextEditingController(),
      'password': TextEditingController(),
      'specialty': TextEditingController(),
      'license': TextEditingController(),
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("${t("add_new")} ${selectedType ?? ''}"),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (selectedType == 'Facility') ...[
                  _buildTextField(t("facility_name"), controllers['name']!, true),
                  _buildTextField(t("facility_type"), controllers['type']!),
                  _buildTextField(t("address"), controllers['address']!),
                  _buildTextField(t("city"), controllers['city']!),
                  _buildTextField(t("region"), controllers['region']!),
                ] else ...[
                  _buildTextField(t("full_name"), controllers['name']!, true),
                  _buildTextField(t("specialization"), controllers['specialty']!),
                  _buildTextField(t("license_number"), controllers['license']!),
                ],
                _buildTextField(t("email"), controllers['email']!, true),
                _buildTextField(t("phone_number"), controllers['phone']!, true),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: Text(t("save")),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final data = {
                  "registration_type": selectedType!.toLowerCase(),
                  "password": controllers['password']!.text,
                  "admin_id": widget.adminId,
                  "email": controllers['email']!.text,
                  "phone_number": controllers['phone']!.text,
                  if (selectedType == 'Facility') ...{
                    "facility_name": controllers['name']!.text,
                    "facility_type": controllers['type']!.text,
                    "address": controllers['address']!.text,
                    "city": controllers['city']!.text,
                    "region": controllers['region']!.text,
                    "role": controllers['type']!.text
                  } else ...{
                    "doctor_name": controllers['name']!.text,
                    "specialization": controllers['specialty']!.text,
                    "license_number": controllers['license']!.text,
                    "address": "Default",
                    "city": "Default",
                    "region": "Default"
                  }
                };

                try {
                  await apiService.registerEntity(data);
                  Navigator.pop(context);
                  _searchEntities(searchController.text);
                } catch (e) {
                  print("Registration failed: $e");
                }
              }
            },
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, [bool required = false, bool isPassword = false]) {
    final t = context.read<TranslationProvider>().t;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? t("required") : null : null,
      ),
    );
  }

  void _showDetailsPopup(Map<String, dynamic> entity) {
    final t = context.read<TranslationProvider>().t;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entity['facility_name'] ?? entity['doctor_name'] ?? t("details")),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: entity.entries.map((e) => Text("${e.key}: ${e.value}")).toList(),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t("close")))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<TranslationProvider>().t;
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(t("admin_panel")),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: "Switch Language",
            onPressed: () {
              context.read<TranslationProvider>().toggleLanguage();
            },
          ),
          Stack(
            children: [
              IconButton(icon: const Icon(Icons.notifications), onPressed: _showNotificationDialog),
              if (notifications.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text('${notifications.length}', style: const TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: t("choose_type"), border: const OutlineInputBorder()),
              value: selectedType,
              items: const ["Facility", "Clinician"]
                  .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                  searchResults.clear();
                  searchController.clear();
                });
              },
            ),
            const SizedBox(height: 10),
            if (selectedType != null) ...[
              TextField(
                controller: searchController,
                decoration: InputDecoration(labelText: t("search_hint"), border: const OutlineInputBorder()),
                onChanged: _searchEntities,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final entity = searchResults[index];
                    return Card(
                      child: ListTile(
                        title: Text(entity['facility_name'] ?? entity['doctor_name'] ?? ''),
                        subtitle: Text("ID: ${entity['facility_id'] ?? entity['doctor_id'] ?? ''}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await apiService.deleteEntity(
                              selectedType!,
                              entity['facility_id'] ?? entity['doctor_id'] ?? '',
                            );
                            _searchEntities(searchController.text);
                          },
                        ),
                        onTap: () => _showDetailsPopup(entity),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: Text(t("add_new")),
                onPressed: _showAddDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
