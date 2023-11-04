import 'package:flutter/material.dart';

import '../model/widget_model.dart';

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
  final List<Message> Function(String?) validator;

  @override
  SuricattaTextFieldState createState() => SuricattaTextFieldState();
}

class SuricattaTextFieldState extends State<SuricattaTextField> {
  List<Message> messages = [];

  void _setMessages(List<Message> updatedMessages) {
    setState(() {
      messages = updatedMessages;
    });
  }

  @override
  void initState() {
    super.initState();
    messages = widget.validator('');
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
          // const SizedBox(height: 8),
          TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
              ),
              onChanged: (text) {
                final validated = widget.validator(text);
                _setMessages(validated);
              }),

          ListView.builder(
            shrinkWrap: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(
                  getLevelIcon(messages[index].level),
                  color: getLevelColor(messages[index].level),
                ),
                title: Text(messages[index].message),
                trailing: Icon(
                  getCategoryIcon(messages[index].category),
                  color: getCategoryColor(messages[index].category),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
