import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/calendar/create_shift/create_shift_page.dart';

class CreateShiftCalendarButton extends StatefulWidget {
  final DateTime selectedDate;
  final VoidCallback onShiftCreated; // Callback function

  const CreateShiftCalendarButton({
    required this.selectedDate,
    required this.onShiftCreated,
  });

  @override
  _CreateShiftCalendarButtonState createState() =>
      _CreateShiftCalendarButtonState();
}

class _CreateShiftCalendarButtonState extends State<CreateShiftCalendarButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CreateShiftPage(
              selectedDate: widget.selectedDate,
              autofill: true,
            ),
          ),
        );

        // If a shift was created, call the callback to refresh the home page
        if (result == true) {
          widget.onShiftCreated();
        }
      },
      onHighlightChanged: (isHighlighted) {
        setState(() {
          _isPressed = isHighlighted;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(25.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _isPressed
              ? const Color.fromARGB(255, 24, 148, 68)
              : const Color.fromARGB(255, 32, 184, 86),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Criar plantão',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
