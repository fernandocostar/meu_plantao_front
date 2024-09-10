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

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.teal;
    final todayColor = Colors.grey[600];
    final shiftMarksColor = Colors.orange[800];
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
        todayDecoration: BoxDecoration(
          color: todayColor,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: primaryColor,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: shiftMarksColor,
          shape: BoxShape.circle,
        ),
        defaultTextStyle: TextStyle(
          fontSize: 14, // Smaller font size for day numbers
          fontWeight: FontWeight.w500, // Slightly lighter font weight
        ),
        weekendTextStyle: TextStyle(
          fontSize: 14, // Smaller font size for weekend numbers
          fontWeight: FontWeight.w500, // Slightly lighter font weight
          color: Colors.red,
        ),
        cellMargin: EdgeInsets.all(2.0), // Reduce margin around each cell
        todayTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        selectedTextStyle: TextStyle(
          fontSize: 14,
          color: Colors.white,
        ),
        outsideTextStyle: TextStyle(
          fontSize: 14,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleTextStyle: TextStyle(
          fontSize: 20, // Smaller font size for the header
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        titleCentered: true, // Center the header title
        leftChevronPadding: EdgeInsets.zero,
        rightChevronPadding: EdgeInsets.zero,
        headerPadding: EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical padding
      ),
      rowHeight: 40.0, // Adjust the row height for less vertical spacing
    );
  }
}
