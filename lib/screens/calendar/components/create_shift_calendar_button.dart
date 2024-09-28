import 'package:flutter/material.dart';
import 'package:meu_plantao_front/screens/create_shift/create_shift_page.dart';

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

  // Constants for styling
  static const double _padding = 25.0;
  static const double _fontSize = 18.0;
  static const double _borderRadius = 12.0;
  static const Color _pressedColor = Color.fromARGB(255, 24, 148, 68);
  static const Color _defaultColor = Color.fromARGB(255, 32, 184, 86);
  static const Color _textColor = Colors.white;
  static const FontWeight _fontWeight = FontWeight.w600;
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const Curve _animationCurve = Curves.easeInOut;
  static const double _boxShadowOpacity = 0.2;
  static const double _boxShadowSpreadRadius = 1.0;
  static const double _boxShadowBlurRadius = 6.0;
  static const Offset _boxShadowOffset = Offset(0, 3);

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
      borderRadius: BorderRadius.circular(_borderRadius),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: _animationCurve,
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius),
          color: _isPressed ? _pressedColor : _defaultColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_boxShadowOpacity),
              spreadRadius: _boxShadowSpreadRadius,
              blurRadius: _boxShadowBlurRadius,
              offset: _boxShadowOffset,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Criar plantão',
            style: TextStyle(
              color: _textColor,
              fontSize: _fontSize,
              fontWeight: _fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}