import 'package:flutter/material.dart';
import 'dart:math';

class Facility {
  final String id;
  final String name;
  final String createdTime;
  final String type;
  final String address;
  final String city;
  final String phoneNumber;
  final String email;

  Facility({
    required this.id,
    required this.name,
    required this.createdTime,
    required this.type,
    required this.address,
    required this.city,
    required this.phoneNumber,
    required this.email,
  });
}

class FacilitiesScreen extends StatefulWidget {
  const FacilitiesScreen({Key? key}) : super(key: key);

  @override
  _FacilitiesScreenState createState() => _FacilitiesScreenState();
}

class _FacilitiesScreenState extends State<FacilitiesScreen> {
  TextEditingController searchController = TextEditingController();
  List<Facility> facilities = [
    Facility(
      id: '1',
      name: 'City Hospital',
      createdTime: '2023-01-10',
      type: 'Hospital',
      address: '123 City St.',
      city: 'Cairo',
      phoneNumber: '1234567890',
      email: 'cityhospital@example.com',
    ),
    Facility(
      id: '2',
      name: 'Radiology Center',
      createdTime: '2023-02-12',
      type: 'Radiology',
      address: '456 Radiology Rd.',
      city: 'Cairo',
      phoneNumber: '0987654321',
      email: 'radiologycenter@example.com',
    ),
    Facility(
      id: '3',
      name: 'Sun Pharmacy',
      createdTime: '2023-03-15',
      type: 'Pharmacy',
      address: '789 Sun Ave.',
      city: 'Alexandria',
      phoneNumber: '1122334455',
      email: 'sunpharmacy@example.com',
    ),
  ];
  List<Facility> filteredFacilities = [];
  Facility? selectedFacility;

  @override
  void initState() {
    super.initState();
    filteredFacilities = facilities;
  }

  void filterFacilities(String query) {
    setState(() {
      filteredFacilities = facilities
          .where((facility) =>
      facility.id.contains(query) ||
          facility.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void deleteFacility(String id) {
    setState(() {
      facilities.removeWhere((facility) => facility.id == id);
      filteredFacilities = facilities;
      selectedFacility = null;
    });
  }

  void addFacility(String name, String type, String address, String city,
      String phoneNumber, String email) {
    final randomId = Random().nextInt(9999).toString().padLeft(4, '0');
    setState(() {
      facilities.add(Facility(
        id: randomId,
        name: name,
        createdTime: DateTime.now().toIso8601String(),
        type: type,
        address: address,
        city: city,
        phoneNumber: phoneNumber,
        email: email,
      ));
      filteredFacilities = facilities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021229),
      appBar: AppBar(
        title: const Text(
          'Facilities Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF043459),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (query) {
                filterFacilities(query);
              },
              decoration: InputDecoration(
                hintText: 'Search by ID or Name',
                hintStyle: const TextStyle(color: Colors.white70),
                labelText: 'Search',
                labelStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                filled: true,
                fillColor: const Color(0xFF02597A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            if (selectedFacility != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${selectedFacility!.id}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Name: ${selectedFacility!.name}',
                    style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text('Type: ${selectedFacility!.type}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Address: ${selectedFacility!.address}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('City: ${selectedFacility!.city}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Phone: ${selectedFacility!.phoneNumber}',
                      style: const TextStyle(color: Colors.white70)),
                  Text('Email: ${selectedFacility!.email}',
                      style: const TextStyle(color: Colors.white70)),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => deleteFacility(selectedFacility!.id),
                  ),
                ],
              )
            else if (filteredFacilities.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: filteredFacilities.length,
                  itemBuilder: (context, index) {
                    final facility = filteredFacilities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      color: const Color(0xFF043459),
                      child: ListTile(
                        title: Text(facility.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            'Type: ${facility.type}, City: ${facility.city}',
                            style: const TextStyle(color: Colors.white70)),
                        onTap: () {
                          setState(() {
                            selectedFacility = facility;
                          });
                        },
                      ),
                    );
                  },
                ),
              )
            else
              const Expanded(
                child: Center(
                  child: Text(
                    'No facilities found',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showAddFacilityDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF02597A),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text('Add Facility',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFacilityDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String selectedType = 'Hospital';
    List<String> facilityTypes = [
      'Hospital',
      'Lab',
      'Radiology',
      'Pharmacy',
      'Clinic'
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF021229),
          title: const Text(
            'Add Facility',
            style:
            TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Facility Name',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF02597A),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF02597A),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF02597A),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF02597A),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white),
                  filled: true,
                  fillColor: Color(0xFF02597A),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              DropdownButton<String>(
                value: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value!;
                  });
                },
                dropdownColor: const Color(0xFF021229),
                items: facilityTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,
                        style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    cityController.text.isNotEmpty &&
                    phoneController.text.isNotEmpty &&
                    emailController.text.isNotEmpty) {
                  addFacility(
                    nameController.text,
                    selectedType,
                    addressController.text,
                    cityController.text,
                    phoneController.text,
                    emailController.text,
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                          'Please fill all fields',
                          style: TextStyle(color: Colors.white),
                        )),
                  );
                }
              },
              child: const Text('Add',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
