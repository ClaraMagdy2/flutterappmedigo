import 'package:flutter/material.dart';

class RadiologyTest {
  final String testName;
  final String testDate;
  final String? imageUrl; // Make imageUrl nullable
  final String reportNotes;
  final String performedBy;

  RadiologyTest({
    required this.testName,
    required this.testDate,
    this.imageUrl, // Now optional
    required this.reportNotes,
    required this.performedBy,
  });
}

class RadiologyTestResultScreen extends StatelessWidget {
  final List<RadiologyTest> radiologyTests = [
    RadiologyTest(
      testName: "Chest X-Ray",
      testDate: "2024-12-01",
      imageUrl: null, // Image URL is now optional
      reportNotes: "No abnormalities detected.",
      performedBy: "Dr. Brown",
    ),
    RadiologyTest(
      testName: "MRI Brain Scan",
      testDate: "2024-11-15",
      imageUrl: "https://th.bing.com/th/id/R.1ad1c88633f117e87c6c9611b12585f5?rik=mYL95wANtuZ%2bbg&pid=ImgRaw&r=0",
      reportNotes: "No significant findings.",
      performedBy: "Dr. Smith",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(" Diagnostic Radiology Bio Markers", style: TextStyle(color: Colors.white)),
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
          itemCount: radiologyTests.length,
          itemBuilder: (context, index) {
            return RadiologyTestCard(
              radiologyTest: radiologyTests[index],
            );
          },
        ),
      ),
    );
  }
}

class RadiologyTestCard extends StatelessWidget {
  final RadiologyTest radiologyTest;

  RadiologyTestCard({
    required this.radiologyTest,
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
            color: Color(0xFF043459), // Background color for test name
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            radiologyTest.testName,
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
                        "Test Date: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(radiologyTest.testDate, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Performed By: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(radiologyTest.performedBy, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Report Notes: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          radiologyTest.reportNotes,
                          style: TextStyle(color: Colors.white),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (radiologyTest.imageUrl != null && radiologyTest.imageUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Image.network(radiologyTest.imageUrl!),
              ),
          ],
        ),
      ),
    );
  }
}
