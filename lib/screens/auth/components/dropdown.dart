import 'package:flutter/material.dart';

class Dropdown extends StatelessWidget {
  final List<String> items;
  final String hintText;
  final ValueNotifier<String?> controller; // This acts as the controller
  final ValueChanged<String?>? onChanged;

  final double padding = 25;

  const Dropdown({
    super.key,
    required this.items,
    required this.hintText,
    required this.controller, // Require the controller
    this.onChanged,
    double? padding,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller, // Bind the controller
      builder: (context, value, _) {
        return DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            labelStyle: TextStyle(color: Colors.grey.shade800),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: const Color.fromARGB(255, 32, 184, 86),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            fillColor: Colors.grey.shade100,
            filled: true,
            contentPadding: const EdgeInsets.all(20.0),
          ),
          hint: Text(
            hintText,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          icon: const Icon(Icons.arrow_drop_down),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(color: Colors.grey.shade900),
          dropdownColor: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            controller.value = newValue; // Update the controller value
            if (onChanged != null) {
              onChanged!(newValue);
            }
          },
        );
      },
    );
  }
}
