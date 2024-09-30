import 'package:flutter/material.dart';

class ShiftSubmitButton extends StatefulWidget {
  final String buttonText;
  final DateTime selectedDate;
  final bool isButtonEnabled;
  final VoidCallback? onPressed;

  const ShiftSubmitButton({
    required this.buttonText,
    required this.selectedDate,
    required this.isButtonEnabled,
    this.onPressed,
  });

  @override
  _ShiftSubmitButtonState createState() => _ShiftSubmitButtonState();
}

class _ShiftSubmitButtonState extends State<ShiftSubmitButton> {
  bool _isPressed = false;

  // Constants for styling
  static const double _padding = 25.0;
  static const double _fontSize = 18.0;
  static const double _borderRadius = 12.0;
  static const Color _enabledColor = Color.fromARGB(255, 32, 184, 86);
  static const Color _disabledColor = Colors.grey;
  static const Color _textColor = Colors.white;
  static const FontWeight _fontWeight = FontWeight.w600;
  static const double _elevation = 5.0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isButtonEnabled ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isButtonEnabled ? _enabledColor : _disabledColor,
        padding: const EdgeInsets.all(_padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: _elevation,
      ),
      child: Center(
        child: Text(
          widget.buttonText,
          style: const TextStyle(
            color: _textColor,
            fontSize: _fontSize,
            fontWeight: _fontWeight,
          ),
        ),
      ),
    );
  }
}