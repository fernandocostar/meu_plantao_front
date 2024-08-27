import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4, // Increased elevation for a more pronounced shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        title: Text(
          startTime,
          style: TextStyle(
            fontSize: 17.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal[800],
          ),
        ),
        subtitle: Text(
          location,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
        trailing: Text(
          '${duration.toStringAsFixed(1)} hrs | R\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.teal[700],
          ),
        ),
      ),
    );
  }
}
