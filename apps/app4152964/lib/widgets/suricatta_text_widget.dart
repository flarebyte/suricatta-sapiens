import 'package:flutter/material.dart';

enum Level { error, warning, info }

enum Category { syntax, spelling, server }

class Message {
  String message;
  Level level;
  Category category;

  Message(this.message, this.level, this.category);
}

IconData getLevelIcon(Level level) {
  switch (level) {
    case Level.error:
      return Icons.error;
    case Level.warning:
      return Icons.warning;
    case Level.info:
      return Icons.info;
    default:
      return Icons.help;
  }
}

IconData getCategoryIcon(Category category) {
  switch (category) {
    case Category.syntax:
      return Icons.code;
    case Category.spelling:
      return Icons.spellcheck;
    case Category.server:
      return Icons.cloud;
    default:
      return Icons.help;
  }
}

Color getLevelColor(Level level) {
  switch (level) {
    case Level.error:
      return Colors.red;
    case Level.warning:
      return Colors.orange;
    case Level.info:
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getCategoryColor(Category category) {
  switch (category) {
    case Category.syntax:
      return Colors.purple;
    case Category.spelling:
      return Colors.green;
    case Category.server:
      return Colors.cyan;
    default:
      return Colors.grey;
  }
}

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

  void _setMessages(List<Message> messages) {
    setState(() {
      messages = messages;
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
                _setMessages(validated ?? []);
              }),
          ListView.builder(
            itemCount: messages.length, // The number of messages
            itemBuilder: (context, index) {
              // Build each message item
              return ListTile(
                leading: Icon(
                  getLevelIcon(messages[index].level),
                  color: getLevelColor(
                      messages[index].level),
                ),
                title: Text(messages[index].message),
                trailing: Icon(
                  getCategoryIcon(
                      messages[index].category),
                  color: getCategoryColor(
                      messages[index].category),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
