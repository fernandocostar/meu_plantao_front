import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_plantao_front/service/shift_service.dart'; // Import your ShiftService
import 'package:meu_plantao_front/screens/home/components/shift_home_card.dart'; // Import your custom ShiftCard widget
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShiftService _shiftService = ShiftService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<dynamic> _upcomingShifts = [];
  int _totalShifts = 0;
  int _totalHours = 0;
  double _totalEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  Future<void> _fetchShifts() async {
    try {
      List<dynamic> shifts = await _shiftService.fetchAllShifts();

      if (shifts.isNotEmpty) {
        // Calculate metrics
        _totalShifts = shifts.length;
        _totalHours = shifts.fold(0, (sum, shift) {
          DateTime start = DateTime.parse(shift['startTime']);
          DateTime end = DateTime.parse(shift['endTime']);
          return sum + end.difference(start).inHours;
        });
        _totalEarnings = shifts.fold(0.0, (sum, shift) => sum + shift['value']);

        // Add duration calculation
        setState(() {
          _upcomingShifts = shifts.map((shift) {
            DateTime start = DateTime.parse(shift['startTime']);
            DateTime end = DateTime.parse(shift['endTime']);
            final duration = end.difference(start).inHours.toDouble();
            return {
              ...shift,
              'duration': duration,
            };
          }).toList();
        });
      } else {
        // Handle errors
        print('Failed to load shifts');
      }
    } catch (e) {
      print('Error fetching shifts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming Shifts Section
              Text(
                'Próximos Plantões',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 10),
              _buildUpcomingShiftsSection(),

              // Dashboard Metrics Section
              SizedBox(height: 20),
              Text(
                'Visão Geral',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 10),
              _buildDashboardOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingShiftsSection() {
    return Column(
      children: _upcomingShifts.map((shift) {
        return ShiftCard(
          startTime: shift['startTime'],
          duration: shift['duration'], // Use the calculated duration
          location: shift['location'],
          value: shift['value'],
        );
      }).toList(),
    );
  }

  Widget _buildDashboardOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMetricCard('Total de Plantões', _totalShifts.toString()),
        _buildMetricCard('Horas Trabalhadas', '$_totalHours horas'),
        _buildMetricCard(
            'Remuneração Total', 'R\$${_totalEarnings.toStringAsFixed(2)}'),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.teal[900],
          ),
        ),
        trailing: Text(
          value,
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
