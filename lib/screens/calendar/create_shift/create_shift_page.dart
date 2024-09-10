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
    startTime = const TimeOfDay(
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

  Future<void> _checkShiftCrossover() async {
  if (startDate != null && endDate != null && startDate!.month != endDate!.month) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Confirmação de Plantão",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Ao criar um plantão que se inicia em um mês e termina em outro, suas métricas mensais podem ser prejudicadas.\n\nSe o plantão for composto (mais de 12 horas), recomenda-se criá-lo separadamente.\n\nCaso seja um plantão de até 12 horas, iniciando em um mês e terminando em outro, você pode prosseguir normalmente.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog and change duration
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: const Text(
                        "Alterar Duração",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog and continue
                        _saveNewShift(); // Proceed with saving the shift
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Green background for confirmation
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: const Text(
                        "Continuar",
                        style: TextStyle(fontSize: 14, color: Colors.white),
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
  } else {
    _saveNewShift();
  }
}


  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Plantão criado com sucesso!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: const Text(
                        "Retornar ao calendário",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateEndTimeBasedOnStartTime() {
  setState(() {
    if (startDate != null && startTime != null) {
      DateTime startDateTime = DateTime(
        startDate!.year,
        startDate!.month,
        startDate!.day,
        startTime!.hour,
        startTime!.minute,
      );

      // Adding 12 hours to the start time to set the end time
      DateTime endDateTime = startDateTime.add(Duration(hours: 12));

      // Updating endDate and endTime
      endDate = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
      endTime = TimeOfDay.fromDateTime(endDateTime);
    }
  });
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
      body: SingleChildScrollView(
        child: Padding(
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
                  _updateEndTimeBasedOnStartTime();
                },
              ),
        
              const SizedBox(height: 16.0),
        
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
                onPressed: _checkShiftCrossover,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
