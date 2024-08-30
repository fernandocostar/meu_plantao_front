import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_plantao_front/screens/calendar/components/create_shift_calendar_button.dart';
import 'package:meu_plantao_front/screens/account/account_page.dart';
import 'package:meu_plantao_front/screens/calendar/components/calendar_widget.dart';
import 'package:meu_plantao_front/screens/calendar/components/carousel_widget.dart';
import 'package:meu_plantao_front/screens/calendar/components/calendar_metrics_widget.dart';
import 'package:meu_plantao_front/screens/home/home_page.dart';

class CalendarPage extends StatefulWidget {
  String name;
  final String email;
  final String token;
  final VoidCallback onQuit;

  CalendarPage({
    required this.name,
    required this.email,
    required this.token,
    required this.onQuit,
  });

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int _selectedIndex = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  String name = '';

  @override
  void initState() {
    super.initState();
    _fetchShifts();
    name = widget.name;
  }

  final FlutterSecureStorage _storage = FlutterSecureStorage();

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
          Uri.parse('http://35.166.116.189:8080/shifts/getAll'),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _updateName(String newName) {
    print('Updating name to $newName');
    setState(() {
      name = newName;
    });
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

    Widget _buildContent() {
      switch (_selectedIndex) {
        case 1:
          return Column(
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
              CalendarMetricsWidget(
                  events: _events,
                  displayedMonth: _focusedDay.month,
                  displayedYear: _focusedDay.year),
              SizedBox(height: 15),
              if (_selectedDay != null)
                CreateShiftCalendarButton(
                  selectedDate: _selectedDay!,
                  onShiftCreated: _handleShiftUpdated, // Pass the callback
                )
              else
                Text('Nenhuma data selecionada'),
            ],
          );
        case 0:
          return HomePage();
        case 2:
          return Center(
              child: Text('Relatórios em breve!',
                  style: TextStyle(
                      fontSize: 24,
                      color: primaryColor,
                      fontWeight: FontWeight.bold)));
        default:
          return Center(child: Text('Unknown Page'));
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.account_circle,
            color: Colors.white,
            size: 35,
          ),
          color: Colors.white,
          onPressed: () async {
            var result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountPage(onNameUpdated: _updateName),
              ),
            );
            print(result.toString());
            await _fetchShifts();
          },
        ),
        title: Text('Olá, ${name}!',
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
        child: _buildContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendário',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Relatórios',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
