import 'package:flutter/material.dart';

class FamilyHistory {
  final String diseaseName;
  final String relation;
  final String diagnosedBy;
  final int ageOfOnset;
  final String notes;

  FamilyHistory({
    required this.diseaseName,
    required this.relation,
    required this.diagnosedBy,
    required this.ageOfOnset,
    required this.notes,
  });
}

class FamilyHistoryScreen extends StatelessWidget {
  final List<FamilyHistory> familyHistoryList = [
    FamilyHistory(
      diseaseName: "Diabetes",
      relation: "Father",
      diagnosedBy: "Dr. Smith",
      ageOfOnset: 50,
      notes: "Patient's father has type 2 diabetes.",
    ),
    FamilyHistory(
      diseaseName: "Cancer",
      relation: "Mother",
      diagnosedBy: "Dr. Lee",
      ageOfOnset: 45,
      notes: "Patient's mother had breast cancer.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Family History", style: TextStyle(color: Colors.white)),
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
          itemCount: familyHistoryList.length,
          itemBuilder: (context, index) {
            return FamilyHistoryCard(
              familyHistory: familyHistoryList[index],
            );
          },
        ),
      ),
    );
  }
}

class FamilyHistoryCard extends StatelessWidget {
  final FamilyHistory familyHistory;

  FamilyHistoryCard({
    required this.familyHistory,
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
            familyHistory.diseaseName,
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
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Color(0xFF021229),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Relation: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(familyHistory.relation, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Diagnosed By: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(familyHistory.diagnosedBy, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Age of Onset: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("${familyHistory.ageOfOnset} years", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Color(0xFF02597A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Notes: ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      familyHistory.notes,
                      style: TextStyle(color: Colors.white),
                      softWrap: true,
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
