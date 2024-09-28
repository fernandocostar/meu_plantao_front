import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class CustomDateTimePicker extends StatefulWidget {
  final String labelText;
  final DateTime? initialDateTime;
  final ValueChanged<DateTime?>? onChanged;

  CustomDateTimePicker({
    required this.labelText,
    this.initialDateTime,
    this.onChanged,
  });

  @override
  _CustomDateTimePickerState createState() => _CustomDateTimePickerState();
}

class _CustomDateTimePickerState extends State<CustomDateTimePicker> {
  DateTime? selectedDateTime;
  late TextEditingController _dateTimeController;

  // Constants for styling
  static const double _paddingHorizontal = 25.0;
  static const double _paddingVertical = 8.0;
  static const double _fontSize = 16.0;
  static const double _borderRadius = 8.0;
  static const Color _labelColor = Color(0xFF424242); // Equivalent to Colors.grey[800]
  static const Color _iconColor = Color(0xFF1565C0); // Equivalent to Colors.blue[800]
  static const String _dateFormat = 'dd/MM/yyyy HH:mm';

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
    _dateTimeController = TextEditingController(
      text: selectedDateTime != null
          ? DateFormat(_dateFormat).format(selectedDateTime!)
          : '',
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _dateTimeController.text =
              DateFormat(_dateFormat).format(selectedDateTime!);
          widget.onChanged?.call(selectedDateTime);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _paddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _fontSize,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: _paddingVertical),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateTimeController,
                  readOnly: true, // Prevents direct editing of the field
                  decoration: InputDecoration(
                    hintText: 'DD/MM/YYYY HH:MM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  ],
                ),
              ),
              const SizedBox(width: _paddingVertical),
              IconButton(
                icon: Icon(Icons.calendar_today, color: _iconColor),
                onPressed: () => _selectDateTime(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}