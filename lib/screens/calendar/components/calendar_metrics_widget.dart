import 'package:flutter/material.dart';

class CalendarMetricsWidget extends StatefulWidget {
  final Map<DateTime, List<dynamic>> events;
  final int displayedMonth;
  final int displayedYear;

  const CalendarMetricsWidget({
    super.key,
    required this.events,
    required this.displayedMonth,
    required this.displayedYear,
  });

  @override
  _CalendarMetricsWidgetState createState() => _CalendarMetricsWidgetState();
}

class _CalendarMetricsWidgetState extends State<CalendarMetricsWidget> {
  double _shiftCount = 0;
  double _totalValue = 0.0;

  // Constants for styling
  static const double _padding = 5.0;
  static const double _borderRadius = 5.0;
  static const double _fontSize = 14.0;
  static const Color _backgroundColor = Color(0xFFEEEEEE); // Equivalent to Colors.grey[200]
  static const FontWeight _fontWeight = FontWeight.bold;

  @override
  void didUpdateWidget(CalendarMetricsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateMetrics();
  }

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  String _formatNumber(double number) {
    // If the number is an integer (e.g., 10.0), show it without decimals
    return number == number.roundToDouble()
        ? number.toStringAsFixed(0)
        : number.toStringAsFixed(1);
  }

  void _calculateMetrics() {
    double totalHours = 0.0;
    double totalValue = 0.0;

    widget.events.forEach((date, shifts) {
      if (date.month == widget.displayedMonth &&
          date.year == widget.displayedYear) {
        for (var shift in shifts) {
          DateTime startTime = DateTime.parse(shift['startTime']);
          DateTime endTime = DateTime.parse(shift['endTime']);
          double duration = endTime.difference(startTime).inHours.toDouble();

          totalHours += duration;
          totalValue += shift['value'] ?? 0.0;
        }
      }
    });

    // Calculate total number of shifts based on duration sum divided by 12 hours
    double shiftCount = totalHours / 12;

    setState(() {
      _shiftCount = shiftCount;
      _totalValue = totalValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_padding),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Plantões: ${_formatNumber(_shiftCount)}',
            style: const TextStyle(fontSize: _fontSize, fontWeight: _fontWeight),
          ),
          Text(
            'Valor total: R\$ ${_totalValue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: _fontSize, fontWeight: _fontWeight),
          ),
        ],
      ),
    );
  }
}