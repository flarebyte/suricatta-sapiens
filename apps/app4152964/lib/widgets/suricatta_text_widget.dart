import 'package:flutter/material.dart';

class SuricattaTextField extends StatefulWidget {
  SuricattaTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?) validator;

  @override
  _SuricattaTextFieldState createState() => _SuricattaTextFieldState();
}

class _SuricattaTextFieldState extends State<SuricattaTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: InputBorder.none,
            ),
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}
