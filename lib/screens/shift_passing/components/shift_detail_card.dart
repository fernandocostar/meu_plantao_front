// shift_details_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShiftDetailsCard extends StatelessWidget {
  final Map<String, dynamic> shift;
  final Color primaryColor;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onPassShift;

  // Constants for styling
  static const double _fontSize = 16.0;
  static const double _headerFontSize = 18.0;
  static const double _padding = 16.0;
  static const double _cardElevation = 4.0;
  static const double _borderRadius = 16.0;
  static const Color _whiteColor = Color(0xFFFFFFFF);
  static const Color _black87Color = Color(0xDD000000);
  static const Color _greyColor = Color(0xFF9E9E9E);

  ShiftDetailsCard({
    required this.shift,
    required this.primaryColor,
    this.onEdit,
    this.onDelete,
    this.onPassShift,
  });

  String _calculateDuration(DateTime startTime, DateTime endTime) {
    Duration duration = endTime.difference(startTime);
    int hours = duration.inHours;
    int minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    DateTime startTime = DateTime.parse(shift['startTime']);
    DateTime endTime = DateTime.parse(shift['endTime']);
    String formattedStartTime =
        DateFormat('dd/MM/yyyy HH:mm').format(startTime);
    String formattedDuration = _calculateDuration(startTime, endTime);
    double value = shift['value'];
    String location = shift['location']['name'];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      elevation: _cardElevation,
      color: _whiteColor,
      child: Padding(
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header with title and optional action icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detalhes do plantão:",
                  style: TextStyle(
                    fontSize: _headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Row(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        icon: Icon(Icons.edit, color: _greyColor),
                        onPressed: onEdit,
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: Icon(Icons.delete, color: _greyColor),
                        onPressed: onDelete,
                      ),
                    if (onPassShift != null)
                      IconButton(
                        icon: Icon(Icons.send, color: _greyColor),
                        onPressed: onPassShift,
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Início: $formattedStartTime",
              style: TextStyle(
                fontSize: _fontSize,
                color: _black87Color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Duração: $formattedDuration",
              style: TextStyle(
                fontSize: _fontSize,
                color: _black87Color,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Valor: R\$${value.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: _fontSize,
                color: _black87Color,
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: _greyColor),
                SizedBox(width: 8.0),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _black87Color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
