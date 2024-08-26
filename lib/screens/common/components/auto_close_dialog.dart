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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: AnimatedDialogContent(
              message: message, durationMilliseconds: durationMilliseconds),
        );
      },
    );
  }
}

class AnimatedDialogContent extends StatefulWidget {
  final String message;
  final int durationMilliseconds;

  const AnimatedDialogContent(
      {required this.message, required this.durationMilliseconds});

  @override
  _AnimatedDialogContentState createState() => _AnimatedDialogContentState();
}

class _AnimatedDialogContentState extends State<AnimatedDialogContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Start the success animation after a short delay
    Future.delayed(Duration(milliseconds: widget.durationMilliseconds), () {
      setState(() {
        _showSuccess = true;
      });
      _animationController.forward();

      // Close the dialog automatically after the animation ends
      Future.delayed(const Duration(milliseconds: 1200), () {
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
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_showSuccess)
              SpinKitCircle(
                color: Colors.green,
                size: 50.0,
              )
            else
              Lottie.asset(
                'assets/animations/success_checkmark.json', // Ensure you have this animation file in your assets
                controller: _animationController,
                onLoaded: (composition) {
                  _animationController.duration = composition.duration;
                },
                width: 70,
                height: 70,
              ),
            SizedBox(height: 20),
            Text(
              _showSuccess ? widget.message : "Carregando...",
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
