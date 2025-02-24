import 'package:flutter/material.dart';

class MedicationHistory {
  final String medicationName;
  final String dosage;
  final String frequency;
  final DateTime startDate;
  final DateTime endDate;
  final String prescribedBy;
  final String prescriptionNotes;

  MedicationHistory({
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.prescribedBy,
    required this.prescriptionNotes,
  });
}

class MedicationHistoryScreen extends StatelessWidget {
  final List<MedicationHistory> medicationHistoryList = [
    MedicationHistory(
      medicationName: "Metformin",
      dosage: "500mg",
      frequency: "Twice a day",
      startDate: DateTime(2020, 1, 1),
      endDate: DateTime(2020, 12, 31),
      prescribedBy: "Dr. Smith",
      prescriptionNotes: "For type 2 diabetes management",
    ),
    MedicationHistory(
      medicationName: "Tamoxifen",
      dosage: "20mg",
      frequency: "Once a day",
      startDate: DateTime(2018, 5, 10),
      endDate: DateTime(2022, 5, 10),
      prescribedBy: "Dr. Lee",
      prescriptionNotes: "For breast cancer treatment",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Medication History", style: TextStyle(color: Colors.white)),
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
          itemCount: medicationHistoryList.length,
          itemBuilder: (context, index) {
            return MedicationHistoryCard(
              medicationHistory: medicationHistoryList[index],
            );
          },
        ),
      ),
    );
  }
}

class MedicationHistoryCard extends StatelessWidget {
  final MedicationHistory medicationHistory;

  MedicationHistoryCard({
    required this.medicationHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0xFF021229),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          medicationHistory.medicationName,
          style: TextStyle(color: Colors.white),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dosage: ${medicationHistory.dosage}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Prescribed by: ${medicationHistory.prescribedBy}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Start Date: ${medicationHistory.startDate.toLocal().toString().split(' ')[0]}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "End Date: ${medicationHistory.endDate.toLocal().toString().split(' ')[0]}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Frequency: ${medicationHistory.frequency}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Notes: ${medicationHistory.prescriptionNotes}",
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}