import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_plantao_front/service/shiftpass_service.dart';
import 'package:meu_plantao_front/service/location_service.dart';

class OfferedShiftsPage extends StatefulWidget {
  @override
  _OfferedShiftsPageState createState() => _OfferedShiftsPageState();
}

class _OfferedShiftsPageState extends State<OfferedShiftsPage> {
  final ShiftPassService _shiftPassService = ShiftPassService();
  final LocationService _locationService = LocationService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  List<dynamic> _offeredShifts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOfferedShifts();
  }

  Future<void> _fetchOfferedShifts() async {
    try {
      List<dynamic> shifts = await _shiftPassService.fetchOfferedShifts();
      setState(() {
        _offeredShifts = shifts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching offered shifts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _acceptShiftPass(int shiftPassId) async {
    List<dynamic> locations = await _locationService.fetchAllActiveLocations();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LocationSelectionDialog(
          shiftPassId: shiftPassId,
          locations: locations,
          onAccept: (int selectedLocationId) {
            _confirmShiftPassAccept(shiftPassId, selectedLocationId);
          },
        );
      },
    );
  }

  Future<void> _confirmShiftPassAccept(int shiftPassId, int locationId) async {
    try {
      await _shiftPassService.acceptShiftPass(shiftPassId, locationId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plantão aceito com sucesso!')),
      );
      _fetchOfferedShifts(); // Refresh after accepting
    } catch (e) {
      print('Error accepting shift pass: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aceitar plantão!')),
      );
    }
  }

  Future<void> _rejectShiftPass(int shiftPassId) async {
    bool confirmed = await _showConfirmationDialog();
    if (confirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plantão rejeitado com sucesso!')),
      );
    }
  }

  Future<bool> _showConfirmationDialog() async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rejeitar Plantão'),
          content: Text('Você tem certeza que deseja rejeitar este plantão?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Rejeitar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  // Método para calcular a duração do plantão em horas
  double _calculateDuration(String startTime, String endTime) {
    DateTime start = DateTime.parse(startTime);
    DateTime end = DateTime.parse(endTime);
    Duration duration = end.difference(start);
    return duration.inHours.toDouble() + (duration.inMinutes % 60) / 60.0;
  }

  // Converte a string ISO 8601 para um formato de data legível
  String _formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    String day = DateFormat('d', 'pt_BR').format(dateTime);
    String month = DateFormat('MMMM', 'pt_BR').format(dateTime);
    String year = DateFormat('yyyy').format(dateTime);
    return '$day de $month, $year';
  }

  // Converte a string ISO 8601 para um formato de hora legível
  String _formatTime(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('HH:mm', 'pt_BR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Plantões Oferecidos'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _offeredShifts.isEmpty
                ? [Center(child: Text('Nenhum plantão oferecido.'))]
                : _offeredShifts.map<Widget>((shift) {
                    double value = shift['value'] ?? 0.0;
                    double duration = _calculateDuration(
                        shift['startTime'], shift['endTime']);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Coluna de horários e local
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(shift['startTime']),
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[800],
                                    ),
                                  ),
                                  Text(
                                    '${_formatTime(shift['startTime'])} - ${_formatTime(shift['endTime'])}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.teal[700],
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    shift['locationName'] ??
                                        'Local não informado',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Coluna de duração e valor
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${duration.toStringAsFixed(1)} hrs',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[600],
                                    ),
                                  ),
                                  Text(
                                    'R\$ ${value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Ícones de aceitar e recusar
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    _acceptShiftPass(shift['id']);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    _rejectShiftPass(shift['id']);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ),
      ),
    );
  }
}

class LocationSelectionDialog extends StatefulWidget {
  final int shiftPassId;
  final List<dynamic> locations;
  final Function(int) onAccept;

  LocationSelectionDialog({
    required this.shiftPassId,
    required this.locations,
    required this.onAccept,
  });

  @override
  _LocationSelectionDialogState createState() =>
      _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<LocationSelectionDialog> {
  int? _selectedLocationId;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecione o Local',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            DropdownButton<int>(
              isExpanded: true,
              value: _selectedLocationId,
              hint: Text('Escolha um local'),
              items: widget.locations.map<DropdownMenuItem<int>>((location) {
                return DropdownMenuItem<int>(
                  value: location['id'],
                  child: Text(location['name']),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedLocationId = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedLocationId != null
                  ? () {
                      widget.onAccept(_selectedLocationId!);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Text('Aceitar Plantão'),
            ),
          ],
        ),
      ),
    );
  }
}
