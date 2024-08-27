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
  int _shiftCount = 0;
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

  void _calculateMetrics() {
    int shiftCount = 0;
    double totalValue = 0.0;

    widget.events.forEach((date, shifts) {
      if (date.month == widget.displayedMonth &&
          date.year == widget.displayedYear) {
        shiftCount += shifts.length;
        totalValue +=
            shifts.fold(0.0, (sum, shift) => sum + (shift['value'] ?? 0.0));
      }
    });

    setState(() {
      _shiftCount = shiftCount;
      _totalValue = totalValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Plantões: $_shiftCount',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Valor total: R\$ ${_totalValue.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
