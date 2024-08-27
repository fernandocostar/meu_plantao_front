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

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isButtonEnabled ? widget.onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.isButtonEnabled
            ? const Color.fromARGB(255, 32, 184, 86)
            : Colors.grey,
        padding: const EdgeInsets.all(25.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
      child: Center(
        child: Text(
          widget.buttonText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
