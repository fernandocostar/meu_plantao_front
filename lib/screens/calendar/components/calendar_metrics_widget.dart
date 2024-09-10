import 'package:flutter/material.dart';

class CalendarMetricsWidget extends StatefulWidget {
  final Map<DateTime, List<dynamic>> events;
  final int displayedMonth;
  final int displayedYear;

  CalendarMetricsWidget({
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
    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(0);
    } else {
      // Otherwise, show it with two decimals
      return number.toStringAsFixed(1);
    }
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
    double shiftCount = (totalHours / 12);

    setState(() {
      _shiftCount = shiftCount;
      _totalValue = totalValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Plantões: ${_formatNumber(_shiftCount)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            'Valor total: R\$ ${_totalValue.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
