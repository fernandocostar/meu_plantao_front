import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/calendar/components/shift_submit_button.dart';
import 'package:meu_plantao_front/service/shift_service.dart';
import '../../common/components/date_time_picker.dart';

class CreateShiftPage extends StatefulWidget {
  final DateTime selectedDate;
  final bool autofill;

  CreateShiftPage({required this.selectedDate, required this.autofill});

  @override
  _CreateShiftPageState createState() => _CreateShiftPageState();
}

class _CreateShiftPageState extends State<CreateShiftPage> {
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;
  double? value;
  String? location;

  bool get _isButtonEnabled =>
      startDate != null &&
      endDate != null &&
      startTime != null &&
      endTime != null &&
      value != null &&
      value! > 0 &&
      location != null &&
      location!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Autofill the fields with default values

    startDate = widget.selectedDate;
    startTime = TimeOfDay(
        hour: 7,
        minute:
            0); // Set start time to 7 AM      endDate = widget.selectedDate;

    endDate = widget.selectedDate;
    endTime = TimeOfDay(hour: 19, minute: 0);

    value = 0.0;
    location = '';
  }

  Future<void> _saveNewShift() async {
    try {
      final shiftService = ShiftService(); // Create an instance of ShiftService

      await shiftService.createShift(
        startDate: DateTime(
          startDate!.year,
          startDate!.month,
          startDate!.day,
          startTime!.hour,
          startTime!.minute,
        ),
        endDate: DateTime(
          endDate!.year,
          endDate!.month,
          endDate!.day,
          endTime!.hour,
          endTime!.minute,
        ),
        value: value,
        location: location,
      );

      // Show success message or navigate to another page
      _showSuccessDialog();
    } catch (e) {
      // Handle error, e.g., show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create shift: $e')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Plantão criado com sucesso!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pop(true); // Go back to the homepage
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.grey[300], // Light grey background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        "Retornar",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          // Clear the form fields
                          startDate = null;
                          startTime = null;
                          endDate = null;
                          endTime = null;
                          value = null;
                          location = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green, // Green background for continue
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        "Continuar criando",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Plantão'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Start Date and Time
            CustomDateTimePicker(
              labelText: 'Data/Hora de início',
              initialDateTime: DateTime(
                startDate!.year,
                startDate!.month,
                startDate!.day,
                startTime?.hour ?? TimeOfDay.now().hour,
                startTime?.minute ?? TimeOfDay.now().minute,
              ),
              onChanged: (dateTime) {
                setState(() {
                  startDate = dateTime;
                  startTime = dateTime != null
                      ? TimeOfDay.fromDateTime(dateTime)
                      : null;
                });
              },
            ),

            SizedBox(height: 16.0),

            // End Date and Time
            CustomDateTimePicker(
              labelText: 'Data/Hora de fim',
              initialDateTime: endDate != null && endDate != null
                  ? DateTime(endDate!.year, endDate!.month, endDate!.day,
                      endTime!.hour, endTime!.minute)
                  : null,
              onChanged: (dateTime) {
                setState(() {
                  endDate = dateTime;
                  endTime = dateTime != null
                      ? TimeOfDay.fromDateTime(dateTime)
                      : null;
                });
              },
            ),

            SizedBox(height: 16.0),

            // Value
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Valor',
                prefixText: 'R\$ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  this.value = double.tryParse(value);
                });
              },
            ),

            SizedBox(height: 16.0),

            // Location
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Local',
              ),
              onChanged: (location) {
                setState(() {
                  this.location = location;
                });
              },
            ),
            SizedBox(height: 25.0),
            // Save Button
            ShiftSubmitButton(
              buttonText: 'Criar',
              selectedDate: widget.selectedDate,
              isButtonEnabled: _isButtonEnabled,
              onPressed: _saveNewShift,
            ),
          ],
        ),
      ),
    );
  }
}
