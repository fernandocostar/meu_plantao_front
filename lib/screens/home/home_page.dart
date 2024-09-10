import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meu_plantao_front/service/shift_service.dart';
import 'package:meu_plantao_front/screens/home/components/shift_home_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ShiftService _shiftService = ShiftService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  List<dynamic> _upcomingShifts = [];
  List<dynamic> _currentMonthShifts = [];
  double _totalShifts = 0;
  int _totalHours = 0;
  double _totalEarnings = 0.0;
  bool _isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _initializeData(); // Load data in an asynchronous manner
  }

  Future<void> _initializeData() async {
    try {
      await Future.wait([
        _fetchUpcomingShifts(),
        _fetchCurrentMonthShifts(),
      ]);
    } catch (e) {
      print('Error initializing data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Data loading is complete
      });
    }
  }

  Future<void> _fetchUpcomingShifts() async {
    try {
      List<dynamic> shifts = await _shiftService.fetchUpcomingShifts();

      if (shifts.isNotEmpty) {
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
        print('Failed to load shifts');
      }
    } catch (e) {
      print('Error fetching shifts: $e');
    }
  }

  Future<void> _fetchCurrentMonthShifts() async {
  try {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month, 1);
    DateTime endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(microseconds: 1)); // End of the current month

    List<dynamic> shifts = await _shiftService.fetchAllShifts();

    _currentMonthShifts = shifts.where((shift) {
      DateTime start = DateTime.parse(shift['startTime']);
      // Include shifts that start or end in the current month
      return (start.isBefore(endOfMonth) && start.isAfter(startOfMonth));
    }).toList();

    // Calculate metrics for current month shifts
    setState(() {
      _totalHours = _currentMonthShifts.fold(0, (sum, shift) {
        DateTime start = DateTime.parse(shift['startTime']);
        DateTime end = DateTime.parse(shift['endTime']);
        return sum + end.difference(start).inHours;
      });
      _totalShifts = _totalHours/12;
      _totalEarnings = _currentMonthShifts.fold(0.0, (sum, shift) => sum + shift['value']);
    });
  } catch (e) {
    print('Error fetching current month shifts: $e');
  }
}

// Helper method to format the number
  String _formatNumber(double number) {
    // If the number is an integer (e.g., 10.0), show it without decimals
    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    } else {
      // Otherwise, show it with two decimals
      return number.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(), // Show loading indicator while data is being fetched
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0), // Reduced side padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upcoming Shifts Section
              Text(
                'Próximos Plantões',
                style: TextStyle(
                  fontSize: 22.0, // Slightly reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 12), // Adjusted spacing for consistency
              _buildUpcomingShiftsSection(),

              // Dashboard Metrics Section
              SizedBox(height: 20), // Reduced spacing for separation
              Text(
                'Visão Mensal',
                style: TextStyle(
                  fontSize: 22.0, // Slightly reduced font size
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800],
                ),
              ),
              SizedBox(height: 12), // Adjusted spacing for consistency
              _buildDashboardOverview(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingShiftsSection() {
    if (_upcomingShifts.isEmpty) {
      return Center(
        child: Text(
          'Nenhum plantão futuro.',
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
      );
    }

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
      _buildMetricCard('Número de Plantões', _formatNumber(_totalShifts).toString()),
      _buildMetricCard('Total de Horas', '$_totalHours horas'),
      _buildMetricCard('Remuneração Total', 'R\$${_formatNumber(_totalEarnings)}'),
    ],
  );
}

  Widget _buildMetricCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0), // Reduced margin
      elevation: 2, // Reduced elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Reduced border radius
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0), // Reduced content padding
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14.0, // Reduced font size
            fontWeight: FontWeight.w600,
            color: Colors.teal[900],
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 14.0, // Reduced font size
            fontWeight: FontWeight.bold,
            color: Colors.teal[700],
          ),
        ),
      ),
    );
  }
}
