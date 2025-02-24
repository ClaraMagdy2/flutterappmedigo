import 'package:flutter/material.dart';

class LabTest {
  final String testName;
  final String testDate;
  final String? imageUrl; // Make imageUrl nullable
  final String reportNotes;
  final String performedBy;
  final String sampleRequired;

  LabTest({
    required this.testName,
    required this.testDate,
    this.imageUrl, // Now optional
    required this.reportNotes,
    required this.performedBy,
    required this.sampleRequired,
  });
}

class LabTestResultScreen extends StatelessWidget {
  final List<LabTest> labTests = [
    LabTest(
      testName: "Blood Test",
      testDate: "2024-12-01",
      imageUrl: null, // Image URL is now optional
      reportNotes: "Normal levels",
      performedBy: "Dr. Smith",
      sampleRequired: "Blood Sample",
    ),
    LabTest(
      testName: "Glucose level",
      testDate: "2024-11-15",
      imageUrl: "https://www.compliancegate.com/wp-content/uploads/2022/02/REACH-test-report-sample.jpeg",
      reportNotes: "Normal levels",
      performedBy: "Dr. Adams",
      sampleRequired: "Blood Sample",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blood Bio Markers", style: TextStyle(color: Colors.white)),
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
          itemCount: labTests.length,
          itemBuilder: (context, index) {
            return LabTestCard(
              labTest: labTests[index],
            );
          },
        ),
      ),
    );
  }
}

class LabTestCard extends StatelessWidget {
  final LabTest labTest;

  LabTestCard({
    required this.labTest,
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
            labTest.testName,
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
                      Text(labTest.testDate, style: TextStyle(color: Colors.white)),
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
                      Text(labTest.performedBy, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Sample Required: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(labTest.sampleRequired, style: TextStyle(color: Colors.white)),
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
                          labTest.reportNotes,
                          style: TextStyle(color: Colors.white),
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (labTest.imageUrl != null && labTest.imageUrl!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: 8),
                child: Image.network(labTest.imageUrl!),
              ),
          ],
        ),
      ),
    );
  }
}
