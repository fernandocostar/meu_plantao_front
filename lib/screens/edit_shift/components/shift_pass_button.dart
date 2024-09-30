import 'package:flutter/material.dart';

class ShiftPassButton extends StatelessWidget {
  final String buttonText;
  final bool isButtonEnabled;
  final VoidCallback? onPressed;

  const ShiftPassButton({
    Key? key,
    required this.buttonText,
    required this.isButtonEnabled,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definição das constantes de estilo
    const double _paddingVertical = 10.0; // Padding vertical menor
    const double _paddingHorizontal = 20.0;
    const double _fontSize = 16.0; // Fonte um pouco menor
    const double _borderRadius = 10.0;
    const Color _enabledColor = Color.fromARGB(255, 79, 141, 255); // Verde mais suave
    const Color _disabledColor = Colors.grey;
    const Color _textColor = Colors.white;
    const FontWeight _fontWeight = FontWeight.w600;
    const double _elevation = 3.0; // Elevação menor

    return ElevatedButton(
      onPressed: isButtonEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isButtonEnabled ? _enabledColor : _disabledColor,
        padding: const EdgeInsets.symmetric(
          vertical: _paddingVertical,
          horizontal: _paddingHorizontal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
        ),
        elevation: _elevation,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            buttonText,
            style: const TextStyle(
              color: _textColor,
              fontSize: _fontSize,
              fontWeight: _fontWeight,
            ),
          ),
          const SizedBox(width: 10.0),
          const Icon(Icons.send, color: _textColor)
        ],
      ),
    );
  }
}
