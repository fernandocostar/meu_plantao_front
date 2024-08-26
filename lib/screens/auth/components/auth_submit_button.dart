import 'package:flutter/material.dart';

class AuthSubmitButton extends StatefulWidget {
  final Function()? onTap;
  final String text;

  const AuthSubmitButton({super.key, required this.onTap, required this.text});

  @override
  _AuthSubmitButtonState createState() => _AuthSubmitButtonState();
}

class _AuthSubmitButtonState extends State<AuthSubmitButton> {
  String get text => widget.text;

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
            this.text,
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
