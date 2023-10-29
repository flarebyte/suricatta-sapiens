import 'package:flutter/material.dart';

class SuricattaTextField extends StatefulWidget {
  const SuricattaTextField({
    super.key,
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
  SuricattaTextFieldState createState() => SuricattaTextFieldState();
}

class SuricattaTextFieldState extends State<SuricattaTextField> {
  String _errorMessage = '';

  void _setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
              ),
              onChanged: (text) {
                final validated = widget.validator(text);
                _setErrorMessage(validated ?? '');
              }),
          Text(_errorMessage,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ))
        ],
      ),
    );
  }
}
