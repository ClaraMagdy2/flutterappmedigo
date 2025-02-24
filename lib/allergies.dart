import 'package:flutter/material.dart';

class Allergy {
  final String allergyName;
  final String reactionType;
  final String severity;
  final String notes;

  Allergy({
    required this.allergyName,
    required this.reactionType,
    required this.severity,
    required this.notes,
  });
}

class AllergyScreen extends StatelessWidget {
  final List<Allergy> allergyList = [
    Allergy(
      allergyName: "Peanuts",
      reactionType: "Hives",
      severity: "Severe",
      notes: "Patient experiences hives after consuming peanuts.",
    ),
    Allergy(
      allergyName: "Dust",
      reactionType: "Sneezing",
      severity: "Mild",
      notes: "Patient sneezes after exposure to dust.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Allergic History", style: TextStyle(color: Colors.white)),
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
          itemCount: allergyList.length,
          itemBuilder: (context, index) {
            return AllergyCard(allergy: allergyList[index]);
          },
        ),
      ),
    );
  }
}

class AllergyCard extends StatelessWidget {
  final Allergy allergy;

  AllergyCard({required this.allergy});

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
            allergy.allergyName,
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
                        "Reaction Type: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(allergy.reactionType, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Severity: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(allergy.severity, style: TextStyle(color: Colors.white)),
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
                      allergy.notes,
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
