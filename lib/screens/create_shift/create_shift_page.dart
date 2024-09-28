import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/manage_locations/manage_locations_page.dart';
import 'package:meu_plantao_front/service/location_service.dart';
import 'package:meu_plantao_front/service/shift_service.dart';
import '../common/components/date_time_picker.dart';
import 'package:meu_plantao_front/screens/calendar/components/shift_submit_button.dart';

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
  String? selectedLocationId;

  List<Map<String, dynamic>> locations = []; // Location list with id and name

  bool get _isButtonEnabled =>
      startDate != null &&
      endDate != null &&
      startTime != null &&
      endTime != null &&
      value != null &&
      value! > 0 &&
      selectedLocationId != null &&
      selectedLocationId!.isNotEmpty;

  // Constants for styling
  static const double _padding = 16.0;
  static const double _buttonPadding = 15.0;
  static const double _dialogPadding = 20.0;
  static const double _fontSize = 18.0;
  static const double _buttonFontSize = 14.0;
  static const double _borderRadius = 8.0;
  static const Color _primaryColor = Color(0xFF32CD32); // Equivalent to Colors.green
  static const Color _secondaryColor = Color(0xFFBDBDBD); // Equivalent to Colors.grey[400]
  static const Color _whiteColor = Color(0xFFFFFFFF); // Equivalent to Colors.white
  static const Color _blackColor = Color(0xFF000000); // Equivalent to Colors.black

  @override
  void initState() {
    super.initState();
    startDate = widget.selectedDate;
    startTime = const TimeOfDay(hour: 7, minute: 0);
    endDate = widget.selectedDate;
    endTime = const TimeOfDay(hour: 19, minute: 0);
    value = 0.0;

    // Load the locations when the widget is initialized
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      // Fetch locations using the LocationService
      final locationService = LocationService();
      final List<dynamic> locationsData = await locationService.fetchAllActiveLocations();

      setState(() {
        // Convert the List<dynamic> to List<Map<String, dynamic>> if necessary
        locations = locationsData.map((location) {
          return {
            'id': location['id'].toString(),
            'name': location['name'],
          };
        }).toList();
      });
    } catch (e) {
      // Handle errors here
      print("Failed to load locations: $e");
      // Optionally show an error message to the user
    }
  }

  Future<void> _saveNewShift() async {
    try {
      final shiftService = ShiftService();

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
        location: selectedLocationId, // Store the location ID
      );

      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create shift: $e')),
      );
    }
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

        DateTime endDateTime = startDateTime.add(const Duration(hours: 12));

        endDate = DateTime(endDateTime.year, endDateTime.month, endDateTime.day);
        endTime = TimeOfDay.fromDateTime(endDateTime);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Plantão'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(_padding),
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

              const SizedBox(height: _padding),

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

              const SizedBox(height: _padding),

              // Value
              TextFormField(
                decoration: const InputDecoration(
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

              const SizedBox(height: _padding),

              // Location Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Local'),
                value: selectedLocationId,
                items: locations.map((location) {
                  return DropdownMenuItem<String>(
                    value: location['id'],
                    child: Text(location['name']),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedLocationId = newValue;
                  });
                },
              ),

              const SizedBox(height: _padding),

              // Edit Locations Button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ManageLocationsPage(onLocationsUpdated: _loadLocations,),
                        ),
                      );
                    },
                    child: const Text('Editar meus locais', style: TextStyle(color: _primaryColor)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _whiteColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_borderRadius),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: _buttonPadding, vertical: _buttonPadding),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: _padding),

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
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(_dialogPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Plantão criado com sucesso!",
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold,
                    color: _primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: _padding),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(true); // Go back to homepage
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _secondaryColor, // Use the correct color constant
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_borderRadius),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: _buttonPadding, vertical: _buttonPadding),
                      ),
                      child: const Text(
                        "Retornar ao calendário",
                        style: TextStyle(fontSize: _buttonFontSize, color: _blackColor),
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
}