import 'package:flutter/material.dart';

class EmergencyContact {
  final String fullName;
  final String relationship;
  final String phoneNumber;

  EmergencyContact({
    required this.fullName,
    required this.relationship,
    required this.phoneNumber,
  });
}

class MyEmergencyContactScreen extends StatefulWidget {
  @override
  _MyEmergencyContactScreenState createState() =>
      _MyEmergencyContactScreenState();
}

class _MyEmergencyContactScreenState extends State<MyEmergencyContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  List<EmergencyContact> emergencyContacts = [
    EmergencyContact(
      fullName: "John Doe",
      relationship: "Brother",
      phoneNumber: "+20 123 456 7890",
    ),
    EmergencyContact(
      fullName: "Jane Doe",
      relationship: "Mother",
      phoneNumber: "+20 987 654 3210",
    ),
  ];

  bool isFormVisible = false;
  int? _editingIndex;

  void _addOrEditEmergencyContact() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        if (_editingIndex == null) {
          emergencyContacts.add(EmergencyContact(
            fullName: _fullNameController.text,
            relationship: _relationshipController.text,
            phoneNumber: _phoneNumberController.text,
          ));
        } else {
          emergencyContacts[_editingIndex!] = EmergencyContact(
            fullName: _fullNameController.text,
            relationship: _relationshipController.text,
            phoneNumber: _phoneNumberController.text,
          );
        }
        _clearForm();
      });
    }
  }

  void _editEmergencyContact(int index) {
    setState(() {
      _editingIndex = index;
      isFormVisible = true;
      _fullNameController.text = emergencyContacts[index].fullName;
      _relationshipController.text = emergencyContacts[index].relationship;
      _phoneNumberController.text = emergencyContacts[index].phoneNumber;
    });
  }

  void _deleteEmergencyContact(int index) {
    setState(() {
      emergencyContacts.removeAt(index);
    });
  }

  void _clearForm() {
    _fullNameController.clear();
    _relationshipController.clear();
    _phoneNumberController.clear();
    isFormVisible = false;
    _editingIndex = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Emergency Contact", style: TextStyle(color: Colors.white)),
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
        child: Column(
          children: [
            if (!isFormVisible)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isFormVisible = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  "Add Emergency Contact",
                  style: TextStyle(color: Color(0xFF021229)),
                ),
              ),
            if (isFormVisible)
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFF043459),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextFormField(
                        controller: _fullNameController,
                        label: "Full Name",
                        validator: "Please enter the full name",
                      ),
                      SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _relationshipController,
                        label: "Relationship",
                        validator: "Please enter the relationship",
                      ),
                      SizedBox(height: 12),
                      _buildTextFormField(
                        controller: _phoneNumberController,
                        label: "Phone Number",
                        validator: "Please enter the phone number",
                        maxLines: 1,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _addOrEditEmergencyContact,
                        child: Text("Save Emergency Contact", style: TextStyle(color: Color(0xFF021229))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Wrap the ListView with Expanded
            Expanded(
              child: ListView.builder(
                itemCount: emergencyContacts.length,
                itemBuilder: (context, index) {
                  return EmergencyContactCard(
                    emergencyContact: emergencyContacts[index],
                    onEdit: () => _editEmergencyContact(index),
                    onDelete: () => _deleteEmergencyContact(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 1.0),
        ),
      ),
      validator: (value) {
        if (value != null && value.isEmpty && validator.isNotEmpty) {
          return validator;
        }
        return null;
      },
      maxLines: maxLines,
    );
  }
}

class EmergencyContactCard extends StatelessWidget {
  final EmergencyContact emergencyContact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  EmergencyContactCard({
    required this.emergencyContact,
    required this.onEdit,
    required this.onDelete,
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
            color: Color(0xFF043459), // Background color for full name
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            emergencyContact.fullName,
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
            // Container for Relationship and Phone Number
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
                        "Relationship: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(emergencyContact.relationship, style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "Phone Number: ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          emergencyContact.phoneNumber,
                          style: TextStyle(color: Colors.white),
                          overflow: TextOverflow.ellipsis, // Ensures the text doesn't overflow
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
