import 'package:flutter/cupertino.dart';

enum Level { error, warning, info }

enum Category { syntax, spelling, server }

enum DataStatus { empty, populated, warning, error, skipped, unknown }

enum WidgetKind { text, number }

class Message {
  String message;
  Level level;
  Category category;

  Message(this.message, this.level, this.category);
}



class PathDataMetadata {
  String title;
  WidgetKind widgetKind;
  List<Message> Function(String?) validator;
  PathDataMetadata({ required this.title, required this.widgetKind, required this.validator});
  factory PathDataMetadata.unknown(){
    return
      PathDataMetadata(
        title: '',
        widgetKind: WidgetKind.text,
        validator: (value) => [],
      );
    }

}

class DataPreview {
  String text;
  DataPreview({required this.text});
}

class PathDataValue {
  String path;
  PathDataMetadata metadata;
  String rank;
  String draft;
  String loaded;
  String refreshed;
  DataPreview preview;
  DataStatus status;

  PathDataValue(
      {required this.path,
      required this.metadata,
      required this.rank,
      required this.draft,
      required this.loaded,
      required this.refreshed,
      required this.preview,
      required this.status});

  factory PathDataValue.unknown() {
    return PathDataValue._(
        path: '',
        rank: '',
        draft: '',
        loaded: '',
        refreshed: '',
        preview: DataPreview(text: ''),
        status: DataStatus.unknown);
  }

}

class SuricattaDataNavigator {
  List<PathDataValue> pathDataValueList;
  String currentPath;
  SuricattaDataNavigator(this.pathDataValueList, this.currentPath);

  findDataByPath(String path) {
    return pathDataValueList.firstWhere(
      (item) => item.path == path,
      orElse: () => PathDataValue(
          path: path,
          rank: '',
          draft: '',
          loaded: '',
          refreshed: '',
          preview: DataPreview(text: ''),
          status: DataStatus.unknown),
    );
  }
}

class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
