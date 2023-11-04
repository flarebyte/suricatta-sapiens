import 'package:flutter/material.dart';

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

IconData getNavigationPathStatusIcon(NavigationPathStatus status) {
  switch (status) {
    case NavigationPathStatus.populated:
      return Icons.verified;
    case NavigationPathStatus.error:
      return Icons.error;
    case NavigationPathStatus.warning:
      return Icons.warning;
    case NavigationPathStatus.empty:
      return Icons.check_box_outline_blank;
    case NavigationPathStatus.skipped:
      return Icons.skip_next;
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

Color getNavigationPathStatusColor(NavigationPathStatus status) {
  switch (status) {
    case NavigationPathStatus.populated:
      return Colors.blue;
    case NavigationPathStatus.error:
      return Colors.red;
    case NavigationPathStatus.warning:
      return Colors.orange;
    case NavigationPathStatus.empty:
      return Colors.orange;
    case NavigationPathStatus.skipped:
      return Colors.grey;
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
