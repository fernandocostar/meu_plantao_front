import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';

class AutoCloseDialog {
  static void show(BuildContext context, String message,
      {int durationMilliseconds = 600}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: AnimatedDialogContent(
            message: message,
            durationMilliseconds: durationMilliseconds,
          ),
        );
      },
    );
  }
}

class AnimatedDialogContent extends StatefulWidget {
  final String message;
  final int durationMilliseconds;

  const AnimatedDialogContent({
    required this.message,
    required this.durationMilliseconds,
  });

  @override
  _AnimatedDialogContentState createState() => _AnimatedDialogContentState();
}

class _AnimatedDialogContentState extends State<AnimatedDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showSuccess = false;

  // Constants for styling
  static const double _padding = 24.0;
  static const double _iconSize = 50.0;
  static const double _lottieSize = 70.0;
  static const double _spacing = 20.0;
  static const double _fontSize = 18.0;
  static const Color _textColor = Colors.green;
  static const FontWeight _fontWeight = FontWeight.bold;
  static const Duration _initialAnimationDuration = Duration(milliseconds: 300);
  static const Duration _successAnimationDuration = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: _initialAnimationDuration,
    );

    // Start the success animation after a short delay
    Future.delayed(Duration(milliseconds: widget.durationMilliseconds), () {
      setState(() {
        _showSuccess = true;
      });
      _animationController.forward();

      // Close the dialog automatically after the animation ends
      Future.delayed(_successAnimationDuration, () {
        Navigator.of(context).pop(true);
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_padding),
      child: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_showSuccess)
              SpinKitCircle(
                color: _textColor,
                size: _iconSize,
              )
            else
              Lottie.asset(
                'assets/animations/success_checkmark.json', // Ensure you have this animation file in your assets
                controller: _animationController,
                onLoaded: (composition) {
                  _animationController.duration = composition.duration;
                },
                width: _lottieSize,
                height: _lottieSize,
              ),
            SizedBox(height: _spacing),
            Text(
              _showSuccess ? widget.message : "Carregando...",
              style: TextStyle(
                color: _textColor,
                fontSize: _fontSize,
                fontWeight: _fontWeight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}