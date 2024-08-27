import 'package:flutter/material.dart';
import 'package:meu_plantao_front/service/shift_service.dart';
import '../../common/components/date_time_picker.dart';
import '../components/shift_submit_button.dart';
import '../../common/components/auto_close_dialog.dart';

class EditShiftPage extends StatefulWidget {
  final Map<String, dynamic> shift;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  EditShiftPage({
    required this.shift,
    required this.onSave,
    required this.onCancel,
  });

  @override
  _EditShiftPageState createState() => _EditShiftPageState();
}

class _EditShiftPageState extends State<EditShiftPage> {
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
    // Initialize fields from the provided shift data
    startDate = DateTime.parse(widget.shift['startTime']);
    startTime = TimeOfDay.fromDateTime(startDate!);
    endDate = DateTime.parse(widget.shift['endTime']);
    endTime = TimeOfDay.fromDateTime(endDate!);
    value = widget.shift['value'];
    location = widget.shift['location'];
  }

  Future<void> _saveEditedShift() async {
    try {
      final ShiftService shiftService = ShiftService();

      await shiftService.editShift(
        id: widget.shift['id'],
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
      AutoCloseDialog.show(context, 'Plantão editado com sucesso');
    } catch (e) {
      // Handle error, e.g., show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to edit shift: $e')),
      );
    }

    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Plantão'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('returning from edit page');
            Navigator.of(context).pop(true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Start Date and Time
            CustomDateTimePicker(
              labelText: 'Data/Hora de início',
              initialDateTime: DateTime(
                startDate!.year,
                startDate!.month,
                startDate!.day,
                startTime!.hour,
                startTime!.minute,
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
              initialDateTime: DateTime(
                endDate!.year,
                endDate!.month,
                endDate!.day,
                endTime!.hour,
                endTime!.minute,
              ),
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
              initialValue: value.toString(),
              keyboardType: TextInputType.number,
              onChanged: (input) {
                setState(() {
                  value = double.tryParse(input);
                });
              },
            ),
            SizedBox(height: 16.0),

            // Location
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Local',
              ),
              initialValue: location,
              onChanged: (input) {
                setState(() {
                  location = input;
                });
              },
            ),
            SizedBox(height: 25.0),

            // Save Button
            ShiftSubmitButton(
              buttonText: 'Salvar',
              selectedDate: startDate!,
              isButtonEnabled: _isButtonEnabled,
              onPressed: _saveEditedShift,
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Plantão editado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
