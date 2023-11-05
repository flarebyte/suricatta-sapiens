enum Level { error, warning, info }

enum Category { syntax, spelling, server }

enum NavigationPathStatus { empty, populated, warning, error, skipped }

class Message {
  String message;
  Level level;
  Category category;

  Message(this.message, this.level, this.category);
}

class NavigationPath {
  String path;
  String title;
  String preview;
  NavigationPathStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
