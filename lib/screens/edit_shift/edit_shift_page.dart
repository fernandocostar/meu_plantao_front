import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/edit_shift/components/shift_pass_button.dart';
import 'package:meu_plantao_front/screens/manage_locations/manage_locations_page.dart';
import 'package:meu_plantao_front/service/shift_service.dart';
import 'package:meu_plantao_front/service/location_service.dart';
import '../common/components/date_time_picker.dart';
import '../common/components/shift_submit_button.dart';
import '../common/components/auto_close_dialog.dart';
import '../shift_passing/shift_passing_page.dart'; // Importe a página ShiftPassingPage

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
  Map<String, dynamic>? location;
  String? selectedLocationId;

  List<Map<String, dynamic>> locations = [];

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
    _initializeFields();
    _loadLocations();
  }

  void _initializeFields() {
    startDate = DateTime.parse(widget.shift['startTime']);
    startTime = TimeOfDay.fromDateTime(startDate!);
    endDate = DateTime.parse(widget.shift['endTime']);
    endTime = TimeOfDay.fromDateTime(endDate!);
    value = widget.shift['value'];
    location = widget.shift['location'];
    selectedLocationId = widget.shift['location']['id'].toString();
  }

  Future<void> _loadLocations() async {
    try {
      final locationService = LocationService();
      final List<dynamic> locationsData = await locationService.fetchAllActiveLocations();

      setState(() {
        locations = locationsData.map((location) {
          return {
            'id': location['id'].toString(),
            'name': location['name'],
          };
        }).toList();

        bool isSelectedLocationActive = locations.any((loc) => loc['id'] == selectedLocationId);

        if (!isSelectedLocationActive && location != null) {
          locations.add({
            'id': location!['id'].toString(),
            'name': '${location!['name']} (Inativo)',
          });
        }
      });
    } catch (e) {
      print("Failed to load locations: $e");
    }
  }

  Future<void> _saveEditedShift() async {
    try {
      final shiftService = ShiftService();

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
        location: selectedLocationId,
      );
      AutoCloseDialog.show(context, 'Plantão editado com sucesso');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao editar plantão: $e')),
      );
    }

    widget.onSave();
  }

  void _passShift() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShiftPassingPage(shift: widget.shift, onSave: (){}), //TODO Implement onSave
      ),
    ).then((result) {
      if (result == true) {
        widget.onSave(); // Atualiza a lista de plantões após a transferência
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Plantão'),
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
              const SizedBox(height: _padding),

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
              const SizedBox(height: _padding),

              // Value
              TextFormField(
                decoration: const InputDecoration(
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
              const SizedBox(height: _padding),

              // Location
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botão Salvar
                  Expanded(
                    child: ShiftSubmitButton(
                      buttonText: 'Salvar',
                      selectedDate: startDate!,
                      isButtonEnabled: _isButtonEnabled,
                      onPressed: _saveEditedShift,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // Botão Passar Plantão
                ],
              ),

              const SizedBox(height: _padding),

              Row(
                children: [
                  Expanded(
                    child: ShiftPassButton(
                      buttonText: "Passar plantão",
                      onPressed: _passShift, 
                      isButtonEnabled: true)),
                  const SizedBox(width: 10.0),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
