import 'package:flutter/material.dart';

class AuthSubmitButton extends StatefulWidget {
  final Function()? onTap;
  final String text;

  const AuthSubmitButton({super.key, required this.onTap, required this.text});

  @override
  _AuthSubmitButtonState createState() => _AuthSubmitButtonState();
}

class _AuthSubmitButtonState extends State<AuthSubmitButton> {
  static const double _padding = 25.0;
  static const double _borderRadius = 12.0;
  static const Color _defaultColor = Color.fromARGB(255, 32, 184, 86);
  static const Color _pressedColor = Color.fromARGB(255, 24, 148, 68);
  static const TextStyle _textStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHighlightChanged: (isHighlighted) {
        setState(() {
          _isPressed = isHighlighted;
        });
      },
      borderRadius: BorderRadius.circular(_borderRadius),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_borderRadius),
          color: _isPressed ? _pressedColor : _defaultColor,
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
            widget.text,
            style: _textStyle,
          ),
        ),
      ),
    );
  }
}