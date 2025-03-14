import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_plantao_front/screens/home/components/create_shift_home_button.dart';

import 'package:meu_plantao_front/screens/home/components/calendar_widget.dart';
import 'package:meu_plantao_front/screens/home/components/carousel_widget.dart';
import 'package:meu_plantao_front/screens/home/components/calendar_metrics_widget.dart';

class HomePage extends StatefulWidget {
  final String name;
  final String email;
  final String token;
  final VoidCallback onQuit;

  HomePage({
    required this.name,
    required this.email,
    required this.token,
    required this.onQuit,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchShifts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchShifts(); // Refresh data when dependencies change
  }

  Future<void> _fetchShifts() async {
    try {
      String? storedToken = await _storage.read(key: 'token');

      if (storedToken != null) {
        final response = await http.get(
          Uri.parse('http://10.0.2.2:8080/shifts/getAll'),
          headers: {
            'Authorization': 'Bearer $storedToken',
          },
        );

        if (response.statusCode == 200) {
          List<dynamic> shifts = jsonDecode(response.body);
          Map<DateTime, List<dynamic>> events = {};

          for (var shift in shifts) {
            DateTime startDate = DateTime.parse(shift['startTime']);
            DateTime normalizedDate = DateTime(
              startDate.year,
              startDate.month,
              startDate.day,
            );

            if (events[normalizedDate] == null) {
              events[normalizedDate] = [];
            }
            events[normalizedDate]!.add(shift);
          }

          setState(() {
            _events = events;
          });
        }
      }
    } catch (e) {
      print('Error fetching shifts: $e');
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _handleShiftUpdated() {
    _fetchShifts(); // Refresh the data when a shift is created
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal;

    List<dynamic> selectedDayEvents =
        _selectedDay != null ? _getEventsForDay(_selectedDay!) : [];

    // Sort shifts by start time
    selectedDayEvents.sort((a, b) {
      DateTime startA = DateTime.parse(a['startTime']);
      DateTime startB = DateTime.parse(b['startTime']);
      return startA.compareTo(startB);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text('Ola, ${widget.name}!',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () async {
              await _fetchShifts();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: widget.onQuit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  CalendarWidget(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: _getEventsForDay,
                  ),
                  if (selectedDayEvents.isNotEmpty) ...[
                    SizedBox(height: 15),
                    CarouselWidget(
                      events: selectedDayEvents,
                      primaryColor: primaryColor,
                      onShiftUpdated: _handleShiftUpdated, // Pass the callback
                    ),
                  ],
                  //counter widget
                  CalendarMetricsWidget(
                      events: _events,
                      displayedMonth: _focusedDay.month,
                      displayedYear: _focusedDay.year),
                  SizedBox(height: 15),
                  if (_selectedDay != null)
                    CreateShiftHomeButton(
                      selectedDate: _selectedDay!,
                      onShiftCreated: _handleShiftUpdated, // Pass the callback
                    )
                  else
                    Text('Nenhuma data selecionada'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
