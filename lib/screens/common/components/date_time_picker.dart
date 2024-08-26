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

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.initialDateTime;
    _dateTimeController = TextEditingController(
      text: selectedDateTime != null
          ? DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!)
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
              DateFormat('dd/MM/yyyy HH:mm').format(selectedDateTime!);
          widget.onChanged?.call(selectedDateTime);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.labelText,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _dateTimeController,
                  readOnly: true, // Impede a edição direta do campo
                  decoration: InputDecoration(
                    hintText: 'DD/MM/YYYY HH:MM',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              IconButton(
                icon: Icon(Icons.calendar_today, color: Colors.blue[800]),
                onPressed: () => _selectDateTime(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
