import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final Color activeColor;
  final Color inactiveColor;

  PageIndicator({
    required this.itemCount,
    required this.currentIndex,
    this.activeColor = Colors.teal,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return itemCount > 1
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(itemCount, (index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  color: index == currentIndex ? activeColor : inactiveColor,
                  shape: BoxShape.circle,
                ),
              );
            }),
          )
        : SizedBox.shrink(); // Hide if there's only one item
  }
}
