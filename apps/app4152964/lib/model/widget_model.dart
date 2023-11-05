import 'dart:collection';

enum Level { error, warning, info }

enum Category { syntax, spelling, server }

enum DataStatus { empty, populated, warning, error, skipped }

enum WidgetKind { text, number }

class Message {
  String message;
  Level level;
  Category category;

  Message(this.message, this.level, this.category);
}

class GenericPathDataMeta {
  String genericPath;
  String title;
  WidgetKind widgetKind;
  List<Message> Function(String?) validator;
  GenericPathDataMeta(
      this.genericPath, this.title, this.widgetKind, this.validator);
}

class DataPreview {
  String text;
  DataPreview(this.text);
}

class PathDataValue {
  String path;
  String genericPath;
  String draft;
  String loaded;
  String refreshed;
  DataPreview preview;
  DataStatus status;

  PathDataValue(this.path, this.genericPath, this.draft, this.loaded,
      this.refreshed, this.preview, this.status);
}

class PathDataValueEntry extends LinkedListEntry<PathDataValueEntry> {
  final PathDataValue value;
  PathDataValueEntry(this.value);
}



class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
