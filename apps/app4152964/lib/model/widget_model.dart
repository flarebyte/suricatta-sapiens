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
  PathDataMetadata(
      {required this.title, required this.widgetKind, required this.validator});
  factory PathDataMetadata.unknown() {
    return PathDataMetadata(
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

class BasePathDataValue {
  const BasePathDataValue._();
  factory BasePathDataValue.unknown() {
    return UnknownPathDataValue(DataStatus.unknown);
  }

  factory BasePathDataValue.empty(
      String path, PathDataMetadata metadata, String rank) {
    return PathDataValue(
        path: path,
        metadata: metadata,
        rank: rank,
        status: DataStatus.unknown,
        draft: '',
        loaded: null,
        refreshed: null);
  }
}

class PathDataValue extends BasePathDataValue {
  String path;
  PathDataMetadata metadata;
  String rank;
  String? draft;
  String? loaded;
  String? refreshed;
  DataStatus status;

  PathDataValue(
      {required this.path,
      required this.metadata,
      required this.rank,
      this.draft,
      this.loaded,
      this.refreshed,
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

class UnknownPathDataValue extends BasePathDataValue {
  final DataStatus status;
  const UnknownPathDataValue(this.status) : super._();
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
