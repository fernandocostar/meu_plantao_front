import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_plantao_front/screens/calendar/components/create_shift_calendar_button.dart';
import 'package:meu_plantao_front/screens/account/account_page.dart';
import 'package:meu_plantao_front/screens/shift_passing/shift_pass_page.dart';
import 'package:meu_plantao_front/screens/calendar/components/calendar_widget.dart';
import 'package:meu_plantao_front/screens/calendar/components/carousel_widget.dart';
import 'package:meu_plantao_front/screens/calendar/components/calendar_metrics_widget.dart';
import 'package:meu_plantao_front/screens/home/home_page.dart';

class CalendarPage extends StatefulWidget {
  final String name;
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

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Constants for styling
  static const double _iconSize = 30.0;
  static const double _appBarFontSize = 20.0;
  static const double _bottomNavIconSize = 20.0;
  static const double _paddingHorizontal = 8.0;
  static const double _paddingVertical = 4.0;
  static const double _toolbarHeight = kToolbarHeight - 10;
  static const double _calendarSpacing = 8.0;
  static const double _metricsSpacing = 10.0;
  static const Color _primaryColor = Colors.teal;
  static const Color _whiteColor = Colors.white;
  static const Color _greyColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _fetchShifts();
    name = widget.name;
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

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
            if (_selectedDay != null) ...[
              SizedBox(height: _calendarSpacing),
              CarouselWidget(
                events: _getEventsForDay(_selectedDay!),
                primaryColor: _primaryColor,
                onShiftUpdated: _handleShiftUpdated,
              ),
              SizedBox(height: _calendarSpacing),
              CalendarMetricsWidget(
                events: _events,
                displayedMonth: _focusedDay.month,
                displayedYear: _focusedDay.year,
              ),
              SizedBox(height: _metricsSpacing),
              CreateShiftCalendarButton(
                selectedDate: _selectedDay!,
                onShiftCreated: _handleShiftUpdated,
              ),
            ] else
              const Center(child: Text('Nenhuma data selecionada')),
          ],
        );
      case 0:
        return HomePage();
      case 2:
        return OfferedShiftsPage();
      default:
        return Center(child: Text('Unknown Page'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.account_circle,
            color: _whiteColor,
            size: _iconSize,
          ),
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
        title: Text(
          'Olá, ${name}!',
          style: TextStyle(fontSize: _appBarFontSize, color: _whiteColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: _whiteColor),
            onPressed: () async {
              await _fetchShifts();
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: _whiteColor),
            onPressed: widget.onQuit,
          ),
        ],
        toolbarHeight: _toolbarHeight,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: _paddingHorizontal,
          vertical: _paddingVertical,
        ),
        child: _buildContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: _bottomNavIconSize,
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
            icon: Icon(Icons.swap_horiz),
            label: 'Passagens de plantão',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _greyColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
