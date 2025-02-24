import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date parsing and formatting

class MyDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MyDetailsScreen(),
    );
  }
}

class MyDetailsScreen extends StatefulWidget {
  @override
  _MyDetailsScreenState createState() => _MyDetailsScreenState();
}

class _MyDetailsScreenState extends State<MyDetailsScreen> {
  // Define dark blue and other colors
  final Color darkBlue = const Color(0xFF021229);
  final Color deepDarkBlue = const Color(0xFF043459);
  // Removed lightPink and replaced with a gradient background

  // Details map for user information.
  Map<String, String> details = {
    'Full Name': 'Tony Magdy',
    'National ID': '12345678901234',
    'Email': 'tony.magdy@example.com',
    'Phone Number': '+20 123 456 7890',
    'Birthday': '01-01-2002',
    'Address': '123 Street, City, Egypt',
    'City': 'Alexandria',
    'Gender': 'Male',
    'Marital Status': 'Single',
  };

  // Icon mapping for each detail.
  Map<String, IconData> icons = {
    'Full Name': Icons.person,
    'National ID': Icons.credit_card,
    'Email': Icons.email,
    'Phone Number': Icons.phone,
    'Birthday': Icons.cake,
    'Address': Icons.home,
    'City': Icons.location_city,
    'Gender': Icons.transgender,
    'Marital Status': Icons.group,
    'Age': Icons.calendar_today, // Icon for age
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar with white background and dark blue text/icons.
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkBlue),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("My Details", style: TextStyle(color: darkBlue)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        // New background: gradient from light blue to white.
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // User details section with avatar and full name.
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: const AssetImage(
                            'Images/man.png'), // Replace with your actual image.
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        details['Full Name']!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Build the list of detail cards.
                ..._buildDetailsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a list of detail cards, inserting age after the birthday entry.
  List<Widget> _buildDetailsList() {
    List<Widget> detailCards = [];
    details.forEach((key, value) {
      detailCards.add(_buildDetailCard(key, value));
      if (key == 'Birthday') {
        // Insert Age immediately after Birthday.
        detailCards.add(
            _buildDetailCard('Age', _calculateAge(details['Birthday']!)));
      }
    });
    return detailCards;
  }

  /// Build a single detail card.
  Widget _buildDetailCard(String key, String value) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          key,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: deepDarkBlue, // Title in dark blue.
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: darkBlue, // Subtitle in dark blue.
          ),
        ),
        leading: Icon(
          icons[key] ?? Icons.info_outline,
          color: deepDarkBlue, // Icon in dark blue.
        ),
        trailing: key != 'Age'
            ? IconButton(
          icon: Icon(Icons.edit, color: deepDarkBlue),
          onPressed: () => _editDetail(context, key, value),
        )
            : null, // No edit icon for Age.
      ),
    );
  }

  /// Calculate age from the birthday string.
  String _calculateAge(String birthday) {
    try {
      DateTime birthDate = DateFormat('dd-MM-yyyy').parse(birthday);
      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--; // Adjust if birthday hasn't occurred yet this year.
      }
      return '$age years';
    } catch (e) {
      return 'Invalid date';
    }
  }

  /// Display a dialog to edit a detail.
  void _editDetail(BuildContext context, String key, String currentValue) {
    TextEditingController controller =
    TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit $key", style: TextStyle(color: darkBlue)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: key),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: darkBlue)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  details[key] = controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("Save", style: TextStyle(color: darkBlue)),
            ),
          ],
        );
      },
    );
  }
}
