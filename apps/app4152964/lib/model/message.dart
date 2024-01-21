enum MessageLevel { error, warning, info }

enum MessageCategory { syntax, spelling, server }

class Message {
  String message;
  MessageLevel level;
  MessageCategory category;

  Message(this.message, this.level, this.category);

  static bool hasError(List<Message> messages) =>
      messages.any((message) => message.level == MessageLevel.error);
}
