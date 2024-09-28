import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWidget extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;
  final List<dynamic> Function(DateTime) eventLoader;

  CalendarWidget({
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
  });

  // Constants for styling
  static const double _fontSize = 14.0;
  static const double _headerFontSize = 20.0;
  static const double _cellMargin = 2.0;
  static const double _rowHeight = 40.0;
  static const double _headerPaddingVertical = 8.0;
  static const FontWeight _fontWeight = FontWeight.w500;
  static const FontWeight _headerFontWeight = FontWeight.bold;
  static const Color _primaryColor = Color(0xFF008080); // Equivalent to Colors.teal
  static const Color _todayColor = Color(0xFF757575); // Equivalent to Colors.grey[600]
  static const Color _shiftMarksColor = Color(0xFFFFA500); // Equivalent to Colors.orange[800]
  static const Color _weekendColor = Color(0xFFFF0000); // Equivalent to Colors.red
  static const Color _whiteColor = Color(0xFFFFFFFF); // Equivalent to Colors.white

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();

    return TableCalendar(
      locale: locale,
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) {
        return isSameDay(selectedDay, day);
      },
      onDaySelected: onDaySelected,
      eventLoader: eventLoader,
      onPageChanged: onPageChanged,
      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          color: _todayColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: _primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: const BoxDecoration(
          color: _shiftMarksColor,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: const TextStyle(
          fontSize: _fontSize, // Smaller font size for day numbers
          fontWeight: _fontWeight, // Slightly lighter font weight
        ),
        weekendTextStyle: const TextStyle(
          fontSize: _fontSize, // Smaller font size for weekend numbers
          fontWeight: _fontWeight, // Slightly lighter font weight
          color: _weekendColor,
        ),
        cellMargin: EdgeInsets.all(_cellMargin), // Reduce margin around each cell
        todayTextStyle: TextStyle(
          fontSize: _fontSize,
          color: _whiteColor,
        ),
        selectedTextStyle: const TextStyle(
          fontSize: _fontSize,
          color: _whiteColor,
        ),
        outsideTextStyle: const TextStyle(
          fontSize: _fontSize,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: _headerFontSize, // Smaller font size for the header
          fontWeight: _headerFontWeight,
          color: _primaryColor,
        ),
        titleCentered: true, // Center the header title
        leftChevronPadding: EdgeInsets.zero,
        rightChevronPadding: EdgeInsets.zero,
        headerPadding: EdgeInsets.symmetric(vertical: _headerPaddingVertical), // Adjust vertical padding
      ),
      rowHeight: _rowHeight, // Adjust the row height for less vertical spacing
    );
  }
}