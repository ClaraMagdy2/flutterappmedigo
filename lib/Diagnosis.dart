import 'package:flutter/material.dart';

class Diagnosis {
  final String diseaseName;
  final String notes;
  final bool chronic;

  Diagnosis({
    required this.diseaseName,
    required this.notes,
    required this.chronic,
  });
}

class DiagnosisScreen extends StatelessWidget {
  final List<Diagnosis> diagnosisList = [
    Diagnosis(
      diseaseName: "Diabetes",
      notes: "Patient has been diagnosed with type 2 diabetes.",
      chronic: true,
    ),
    Diagnosis(
      diseaseName: "Migraine",
      notes: "Chronic migraines reported since teenage years.",
      chronic: true,
    ),
    Diagnosis(
      diseaseName: "Flu",
      notes: "Common seasonal flu with mild symptoms.",
      chronic: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Diagnosis", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF02597A),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
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
          itemCount: diagnosisList.length,
          itemBuilder: (context, index) {
            return DiagnosisCard(
              diagnosis: diagnosisList[index],
            );
          },
        ),
      ),
    );
  }
}

class DiagnosisCard extends StatelessWidget {
  final Diagnosis diagnosis;

  DiagnosisCard({required this.diagnosis});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF043459),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            diagnosis.diseaseName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF02597A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text(
                    "Chronic: ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    diagnosis.chronic ? Icons.check_box : Icons.check_box_outline_blank,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF043459),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Notes: ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      diagnosis.notes,
                      style: const TextStyle(color: Colors.white),
                      maxLines: null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
