import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RiskManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Risk Assessment"),
        backgroundColor: Color(0xFF02597A), // AppBar background color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chart Display
            Container(
              height: 300,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF043459),
                borderRadius: BorderRadius.circular(15),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 1.5),
                        FlSpot(2, 2),
                        FlSpot(3, 1.8),
                        FlSpot(4, 2.5),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Risk Category and Score
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF021229),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Risk Category: High",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Risk Score: 85%",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Primary Risk Factors
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF043459),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Primary Risk Factors:",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "- Age over 60",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "- High Blood Pressure",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "- Family History of Heart Disease",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Recommended Actions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF021229),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Recommended Actions:",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "- Monitor blood pressure regularly",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "- Regular cardiovascular checkups",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "- Lifestyle changes (diet, exercise)",
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
