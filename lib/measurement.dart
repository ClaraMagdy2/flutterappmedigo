import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date parsing and formatting

// Model for Measurement
class Measurement {
  final double weight;
  final double height;
  final double bmi;
  final String measurementType;
  final String measurementValue;
  final String measurementDate;

  Measurement({
    required this.weight,
    required this.height,
    required this.bmi,
    required this.measurementType,
    required this.measurementValue,
    required this.measurementDate,
  });
}

class MyMeasurementScreen extends StatefulWidget {
  @override
  _MyMeasurementScreenState createState() => _MyMeasurementScreenState();
}

class _MyMeasurementScreenState extends State<MyMeasurementScreen> {
  final List<Measurement> measurementList = [
    Measurement(
      weight: 70.0,
      height: 170.0,
      bmi: 24.2,
      measurementType: "Blood Pressure",
      measurementValue: "120/80 mmHg",
      measurementDate: "21-12-2024",
    ),
  ];

  final _measurementValueController = TextEditingController();
  final _measurementDateController = TextEditingController();
  String _selectedMeasurementType = "Blood Pressure";
  bool _isAddMeasurementVisible = false;

  final Color darkBlue = const Color(0xFF021229);

  void _toggleAddMeasurementForm() {
    setState(() {
      _isAddMeasurementVisible = !_isAddMeasurementVisible;
    });
  }

  void _addMeasurement() {
    if (_measurementValueController.text.isNotEmpty &&
        _measurementDateController.text.isNotEmpty) {
      setState(() {
        measurementList.add(Measurement(
          weight: 0.0,
          height: 0.0,
          bmi: 0.0,
          measurementType: _selectedMeasurementType,
          measurementValue: _measurementValueController.text,
          measurementDate: _measurementDateController.text,
        ));

        _measurementValueController.clear();
        _measurementDateController.clear();
        _selectedMeasurementType = "Blood Pressure";
        _isAddMeasurementVisible = false;
      });
    }
  }

  void _editWeightHeight(double weight, double height) {
    setState(() {
      final double bmi =
      (weight > 0 && height > 0) ? weight / ((height / 100) * (height / 100)) : 0;
      measurementList[0] = Measurement(
        weight: weight,
        height: height,
        bmi: bmi,
        measurementType: measurementList[0].measurementType,
        measurementValue: measurementList[0].measurementValue,
        measurementDate: measurementList[0].measurementDate,
      );
    });
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _measurementDateController.text =
        "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
        Text("Clinical Indicators", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF02597A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light Blue
              Colors.white,
            ],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toggle measurement form button.
                  ElevatedButton(
                    onPressed: _toggleAddMeasurementForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: darkBlue,
                      side: BorderSide(color: darkBlue),
                    ),
                    child: Text(
                      _isAddMeasurementVisible ? "Cancel" : "Add Measurement",
                      style: TextStyle(color: darkBlue),
                    ),
                  ),
                  // AnimatedSwitcher for measurement form.
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: _isAddMeasurementVisible
                        ? Container(
                      key: ValueKey("addMeasurementForm"),
                      padding: EdgeInsets.all(16),
                      margin: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedMeasurementType,
                                  decoration: InputDecoration(
                                    labelText: "Measurement Type",
                                    labelStyle:
                                    TextStyle(color: darkBlue),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: darkBlue),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: darkBlue),
                                    ),
                                  ),
                                  style: TextStyle(color: darkBlue),
                                  items: [
                                    "Blood Pressure",
                                    "Blood Glucose",
                                    "Heart Rate"
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value,
                                          style: TextStyle(
                                              color: darkBlue)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMeasurementType = value!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _measurementValueController,
                                  style: TextStyle(color: darkBlue),
                                  decoration: InputDecoration(
                                    labelText: "Value",
                                    labelStyle:
                                    TextStyle(color: darkBlue),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: darkBlue),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: darkBlue),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          GestureDetector(
                            onTap: _pickDate,
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _measurementDateController,
                                style: TextStyle(color: darkBlue),
                                decoration: InputDecoration(
                                  labelText: "Date",
                                  labelStyle:
                                  TextStyle(color: darkBlue),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkBlue),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: darkBlue),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _addMeasurement,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF02597A),
                            ),
                            child: Text("Save Measurement",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    )
                        : SizedBox.shrink(key: ValueKey("empty")),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: measurementList.length,
                itemBuilder: (context, index) {
                  return index == 0
                      ? WeightHeightCard(
                    weight: measurementList[index].weight,
                    height: measurementList[index].height,
                    bmi: measurementList[index].bmi,
                    onEdit: _editWeightHeight,
                  )
                      : MeasurementCard(
                    measurement: measurementList[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightHeightCard extends StatelessWidget {
  final double weight;
  final double height;
  final double bmi;
  final void Function(double, double) onEdit;

  WeightHeightCard({
    required this.weight,
    required this.height,
    required this.bmi,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final _weightController =
    TextEditingController(text: weight.toStringAsFixed(1));
    final _heightController =
    TextEditingController(text: height.toStringAsFixed(1));

    final Color darkBlue = const Color(0xFF021229);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text("Weight and Height",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: darkBlue)),
            trailing: IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF02597A)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Edit Weight and Height",
                        style: TextStyle(color: darkBlue)),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: "Weight (kg)",
                            labelStyle: TextStyle(color: darkBlue),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        TextField(
                          controller: _heightController,
                          decoration: InputDecoration(
                            labelText: "Height (cm)",
                            labelStyle: TextStyle(color: darkBlue),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          final double newWeight =
                              double.tryParse(_weightController.text) ??
                                  weight;
                          final double newHeight =
                              double.tryParse(_heightController.text) ??
                                  height;
                          onEdit(newWeight, newHeight);
                          Navigator.of(context).pop();
                        },
                        child: Text("Save",
                            style: TextStyle(color: darkBlue)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel",
                            style: TextStyle(color: darkBlue)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Weight: ${weight.toStringAsFixed(1)} kg",
                style: TextStyle(color: darkBlue)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Height: ${height.toStringAsFixed(1)} cm",
                style: TextStyle(color: darkBlue)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("BMI: ${bmi.toStringAsFixed(1)}",
                style: TextStyle(color: darkBlue)),
          ),
        ],
      ),
    );
  }
}

class MeasurementCard extends StatelessWidget {
  final Measurement measurement;

  MeasurementCard({required this.measurement});

  @override
  Widget build(BuildContext context) {
    final Color darkBlue = const Color(0xFF021229);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text("Measurement Date: ${measurement.measurementDate}",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: darkBlue)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Type: ${measurement.measurementType}",
                style: TextStyle(color: darkBlue)),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Value: ${measurement.measurementValue}",
                style: TextStyle(color: darkBlue)),
          ),
        ],
      ),
    );
  }
}
