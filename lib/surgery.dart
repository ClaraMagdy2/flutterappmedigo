import 'package:flutter/material.dart';

class Surgery {
  final String procedureName;
  final String surgeryDate;
  final String surgeonName;
  final String hospitalName;
  final String procedureNotes;

  Surgery({
    required this.procedureName,
    required this.surgeryDate,
    required this.surgeonName,
    required this.hospitalName,
    required this.procedureNotes,
  });
}

class SurgeryScreen extends StatelessWidget {
  final List<Surgery> surgeryList = [
    Surgery(
      procedureName: "Appendectomy",
      surgeryDate: "12-05-2021",
      surgeonName: "Dr. Ahmed Mahmoud",
      hospitalName: "Cairo General Hospital",
      procedureNotes: "Removed appendix due to acute appendicitis.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Surgery History", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF02597A),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF02597A),
              Color(0xFF043459),
              Color(0xFF021229),
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: surgeryList.length,
          itemBuilder: (context, index) {
            return SurgeryCard(
              surgery: surgeryList[index],
            );
          },
        ),
      ),
    );
  }
}

class SurgeryCard extends StatelessWidget {
  final Surgery surgery;

  SurgeryCard({
    required this.surgery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF043459),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            surgery.procedureName,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow("Surgery Date: ", surgery.surgeryDate),
            _buildInfoRow("Surgeon Name: ", surgery.surgeonName),
            _buildInfoRow("Hospital Name: ", surgery.hospitalName),
            _buildInfoRow("Procedure Notes: ", surgery.procedureNotes, wrap: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool wrap = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: wrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.black),
              softWrap: wrap,
            ),
          ),
        ],
      ),
    );
  }
}
