import 'package:flutter/material.dart';

class FacilityScreen extends StatefulWidget {
  @override
  _FacilityScreenState createState() => _FacilityScreenState();
}

class _FacilityScreenState extends State<FacilityScreen> {
  late TextEditingController searchController;

  final List<String> examplePatients = [
    '12345678901234',
    '56789012345678',
    '98765432109876',
    '11223344556677',
    '22334455667788',
  ];

  List<String> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    filteredPatients = examplePatients;
  }

  void filterPatients(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPatients = examplePatients;
      } else {
        filteredPatients = examplePatients
            .where((patient) => patient.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7EFEF), // Light background color
      appBar: AppBar(
        title: Text('Facility Screen'),
        backgroundColor: Color(0xFF02597A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: filterPatients,
              decoration: InputDecoration(
                hintText: 'Search Patient by National ID',
                prefixIcon: Icon(Icons.search, color: Color(0xFF02597A)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Color(0xFF02597A)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  borderSide: BorderSide(color: Color(0xFF043459)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // List of Patients
            Expanded(
              child: Container(
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
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: ListView.builder(
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: ListTile(
                        leading: Icon(
                          Icons.person,
                          color: Color(0xFF02597A),
                        ),
                        title: Text(
                          filteredPatients[index],
                          style: TextStyle(
                            color: Color(0xFF043459),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
