import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'translation_provider.dart';

class UserDetails {
  String nationalId;
  String password;
  String fullName;
  String? profilePhoto;
  String birthdate;
  String phoneNumber;
  String email;
  String gender;
  String bloodGroup;
  String maritalStatus;
  String address;
  String region;
  String city;
  bool currentSmoker;
  int cigsPerDay;
  int age;

  UserDetails({
    required this.nationalId,
    required this.password,
    required this.fullName,
    this.profilePhoto,
    required this.birthdate,
    required this.phoneNumber,
    required this.email,
    required this.gender,
    required this.bloodGroup,
    required this.maritalStatus,
    required this.address,
    required this.region,
    required this.city,
    required this.currentSmoker,
    required this.cigsPerDay,
    required this.age,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      nationalId: json['national_id'] ?? '',
      password: json['password'] ?? '',
      fullName: json['full_name'] ?? '',
      profilePhoto: json['profile_photo'],
      birthdate: json['birthdate'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      bloodGroup: json['blood_group'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      address: json['address'] ?? '',
      region: json['region'] ?? '',
      city: json['city'] ?? '',
      currentSmoker: json['current_smoker'] ?? false,
      cigsPerDay: json['cigs_per_day'] ?? 0,
      age: json['age'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'national_id': nationalId,
      'password': password,
      'full_name': fullName,
      'profile_photo': profilePhoto,
      'birthdate': birthdate,
      'phone_number': phoneNumber,
      'email': email,
      'gender': gender,
      'blood_group': bloodGroup,
      'marital_status': maritalStatus,
      'address': address,
      'region': region,
      'city': city,
      'current_smoker': currentSmoker,
      'cigs_per_day': cigsPerDay,
    };
  }
}

class UserApiService {
  final String baseUrl = "http://10.0.2.2:8000";
  final String token;

  UserApiService({required this.token});

  Future<UserDetails> fetchUserDetails(String userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    if (response.statusCode == 200) {
      return UserDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load user: ${response.body}");
    }
  }

  Future<UserDetails> updateUserDetails(String userId, Map<String, dynamic> updatedData) async {
    final response = await http.put(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      return UserDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Update failed: ${response.body}");
    }
  }
}

ImageProvider getProfileImage(String? imageString) {
  if (imageString == null || imageString.isEmpty) return const AssetImage('Images/man.jpg');
  if (imageString.startsWith("http")) return NetworkImage(imageString);
  if (imageString.startsWith("data:image")) imageString = imageString.split(',').last;
  return MemoryImage(base64Decode(imageString));
}

class MyDetailsScreen extends StatefulWidget {
  final String token;
  final String userId;
  final bool isfacility;
  final bool isdoctor;

  const MyDetailsScreen({
    Key? key,
    required this.token,
    required this.userId,
    required this.isfacility,
    required this.isdoctor,
  }) : super(key: key);

  @override
  _MyDetailsScreenState createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  late Future<UserDetails> userDetailsFuture;
  UserDetails? details;
  File? _newProfileImage;
  static const platform = MethodChannel('com.example.myapp/image_picker');

  @override
  void initState() {
    super.initState();
    userDetailsFuture = _fetchUserDetails();
  }

  Future<UserDetails> _fetchUserDetails() async {
    final apiService = UserApiService(token: widget.token);
    details = await apiService.fetchUserDetails(widget.userId);
    return details!;
  }

  Future<void> _pickNewImage() async {
    try {
      final String? imagePath = await platform.invokeMethod('pickImage');
      if (imagePath != null) {
        String realPath = imagePath.startsWith('content://')
            ? await platform.invokeMethod('getAbsolutePath', imagePath)
            : imagePath;
        setState(() {
          _newProfileImage = File(realPath);
        });
        await _uploadNewProfileImage();
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image picker failed: ${e.message}")));
    }
  }

  Future<void> _uploadNewProfileImage() async {
    if (_newProfileImage == null || details == null) return;

    final bytes = await _newProfileImage!.readAsBytes();
    final base64Image = base64Encode(bytes);

    Map<String, dynamic> updatedData = details!.toJson();
    updatedData['profile_photo'] = base64Image;

    try {
      final apiService = UserApiService(token: widget.token);
      details = await apiService.updateUserDetails(widget.userId, updatedData);
      setState(() {
        _newProfileImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile image updated")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update image: $e")));
    }
  }

  Future<void> _updateDetail(String apiKey, String newValue) async {
    final t = context.read<TranslationProvider>().t;
    if (details == null || widget.isfacility || widget.isdoctor || apiKey == "doctoremail" || apiKey == "age") return;

    Map<String, dynamic> updatedData = details!.toJson();
    updatedData[apiKey] = apiKey == 'current_smoker'
        ? (newValue.toLowerCase() == 'yes' || newValue == "نعم")
        : (apiKey == 'cigs_per_day' ? int.tryParse(newValue) ?? 0 : newValue);

    try {
      final apiService = UserApiService(token: widget.token);
      details = await apiService.updateUserDetails(widget.userId, updatedData);
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("update_failed"))));
    }
  }

  void _editDetail(String labelKey, String apiKey, String currentValue) {
    final t = context.read<TranslationProvider>().t;
    final controller = TextEditingController(text: apiKey == "password" ? "" : currentValue);
    final obscure = apiKey == "password";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("${t("edit")} ${t(apiKey)}"),
        content: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(labelText: t(apiKey)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(t("cancel"))),
          ElevatedButton(
            onPressed: () async {
              if (apiKey == "password" && controller.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t("password_empty"))));
                return;
              }
              await _updateDetail(apiKey, controller.text);
              Navigator.pop(context);
            },
            child: Text(t("save")),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDetailsList() {
    final t = context.watch<TranslationProvider>().t;

    final Map<String, String> translatedKeyToApiKey = {
      t("full_name"): "full_name",
      t("national_id"): "national_id",
      t("password"): "password",
      t("email"): "email",
      t("birthdate"): "birthdate",
      t("phone_number"): "phone_number",
      t("gender"): "gender",
      t("blood_group"): "blood_group",
      t("marital_status"): "marital_status",
      t("address"): "address",
      t("region"): "region",
      t("city"): "city",
      t("current_smoker"): "current_smoker",
      t("cigs_per_day"): "cigs_per_day",
    };

    return translatedKeyToApiKey.entries.map((entry) {
      String label = entry.key;
      String apiKey = entry.value;
      String value = details!.toJson()[apiKey]?.toString() ?? '';
      return _buildDetailCard(label, apiKey, value);
    }).toList()
      ..add(_buildDetailCard(t("age"), "age", details!.age.toString()));
  }

  Widget _buildDetailCard(String label, String apiKey, String value) {
    final canEdit = !(widget.isfacility || widget.isdoctor) && apiKey != "doctoremail" && apiKey != "age";

    return Card(
      elevation: 2,
      child: ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(apiKey == "password" ? "********" : value),
        trailing: canEdit
            ? IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () => _editDetail(label, apiKey, value),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<TranslationProvider>().t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t("personal_info")),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () async {
              final provider = Provider.of<TranslationProvider>(context, listen: false);
              final newLang = provider.currentLanguage == 'en' ? 'ar' : 'en';
              await provider.load(newLang);
              setState(() {});
            },
          )
        ],
      ),
      body: FutureBuilder<UserDetails>(
        future: userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return Center(child: Text(t("no_data")));

          details = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                GestureDetector(
                  onTap: widget.isfacility || widget.isdoctor ? null : _pickNewImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _newProfileImage != null
                        ? FileImage(_newProfileImage!)
                        : getProfileImage(details!.profilePhoto),
                    backgroundColor: Colors.white,
                    child: widget.isfacility || widget.isdoctor
                        ? null
                        : const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.edit, size: 24, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(details!.fullName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ..._buildDetailsList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
