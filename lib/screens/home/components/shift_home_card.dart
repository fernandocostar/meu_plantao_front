import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date and time formatting

class ShiftCard extends StatelessWidget {
  final String startTime;
  final String location;
  final double duration; // Duration in hours
  final double value;

  ShiftCard({
    required this.startTime,
    required this.location,
    required this.duration,
    required this.value,
  });

  // Convert the ISO 8601 date string to a human-readable format
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);

    // Use DateFormat with the 'pt_BR' locale to get day, month, and year separately
    String day = DateFormat('d', 'pt_BR').format(dateTime);
    String month = DateFormat('MMMM', 'pt_BR').format(dateTime);
    String year = DateFormat('yyyy').format(dateTime);

    // Concatenate with "de"
    return '$day de $month, $year';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 6, // Slightly increased elevation for a more pronounced shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15.0),
        leading: Icon(
          Icons.calendar_today, // Icon to represent the shift
          color: Colors.teal[700],
        ),
        title: Text(
          _formatDate(startTime), // Formatted date and time
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        subtitle: Text(
          location,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[700],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${duration.toStringAsFixed(1)} hrs',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal[600],
              ),
            ),
            Text(
              'R\$${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.teal[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
