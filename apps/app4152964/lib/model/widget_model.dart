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

sealed class BasePathDataValue {
  DataStatus _status;
  BasePathDataValue({required DataStatus status}) : _status = status;

  DataStatus get status => _status;

  factory BasePathDataValue.unknown() {
    return UnknownPathDataValue();
  }
  factory BasePathDataValue.empty(
      String path, PathDataMetadata metadata, String rank) {
    return PathDataValue(
        path: path,
        metadata: metadata,
        rank: rank,
        status: DataStatus.empty,
        draft: '',
        loaded: null,
        refreshed: null);
  }
  factory BasePathDataValue.some(DataStatus status, String path, metadata,
      String rank, String draft, String loaded, String refreshed) {
    return PathDataValue(
      status: status,
      path: path,
      metadata: metadata,
      rank: rank,
      draft: draft,
      loaded: loaded,
      refreshed: refreshed,
    );
  }

  static bool hasPath(BasePathDataValue value, String searchPath) {
    return switch (value) {
      UnknownPathDataValue() => false,
      PathDataValue(path: var valuePath) => valuePath == searchPath
    };
  }
}

class PathDataValue extends BasePathDataValue {
  String path;
  PathDataMetadata metadata;
  String rank;
  String? draft;
  String? loaded;
  String? refreshed;

  PathDataValue({
    required DataStatus status,
    required this.path,
    required this.metadata,
    required this.rank,
    this.draft,
    this.loaded,
    this.refreshed,
  }) : super(status: status);
}

class UnknownPathDataValue extends BasePathDataValue {
  UnknownPathDataValue() : super(status: DataStatus.unknown);
}

class SuricattaDataNavigator {
  List<BasePathDataValue> pathDataValueList;
  String currentRank;
  SuricattaDataNavigator(this.pathDataValueList, this.currentRank);

  BasePathDataValue findDataByPath(String path) {
    return pathDataValueList.firstWhere(
      (item) => BasePathDataValue.hasPath(item, path),
      orElse: () => BasePathDataValue.unknown(),
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
