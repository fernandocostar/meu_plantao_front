import 'package:flutter/material.dart';

class ShiftPassSubmitButton extends StatelessWidget {
  final String buttonText;
  final bool isButtonEnabled;
  final VoidCallback? onPressed;

  const ShiftPassSubmitButton({
    required this.buttonText,
    required this.isButtonEnabled,
    this.onPressed,
  });

  // Constants for styling
  static const double _padding = 16.0;
  static const double _fontSize = 16.0;
  static const double _borderRadius = 8.0;
  static const Color _enabledColor = Color.fromARGB(255, 32, 184, 86);
  static const Color _disabledColor = Colors.grey;
  static const Color _textColor = Colors.white;
  static const FontWeight _fontWeight = FontWeight.w600;
  static const double _elevation = 3.0;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isButtonEnabled? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isButtonEnabled ? _enabledColor : _disabledColor,
        padding: const EdgeInsets.symmetric(vertical: _padding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: _elevation,
      ),
      child: Center(
        child: Text(
                buttonText,
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
