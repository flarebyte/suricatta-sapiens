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

  factory BasePathDataValue.unknown() => UnknownPathDataValue();

  factory BasePathDataValue.empty(
      {required String path,
      required PathDataMetadata metadata,
      required String rank}) {
    return PathDataValue(
        path: path,
        metadata: metadata,
        rank: rank,
        status: DataStatus.empty,
        draft: '',
        loaded: null,
        refreshed: null);
  }
  factory BasePathDataValue.some(
      {required DataStatus status,
      required String path,
      required metadata,
      required String rank,
      String? draft,
      String? loaded,
      String? refreshed}) {
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

  static bool hasRank(BasePathDataValue value, String searchRank) {
    return switch (value) {
      UnknownPathDataValue() => false,
      PathDataValue(rank: var valueRank) => valueRank == searchRank
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
    required super.status,
    required this.path,
    required this.metadata,
    required this.rank,
    this.draft,
    this.loaded,
    this.refreshed,
  });
}

class UnknownPathDataValue extends BasePathDataValue {
  UnknownPathDataValue() : super(status: DataStatus.unknown);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownPathDataValue && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

class SuricattaDataNavigator {
  List<BasePathDataValue> pathDataValueList;
  String currentRank;
  SuricattaDataNavigator(
      {required this.pathDataValueList, required this.currentRank});

  BasePathDataValue findDataByPath(String path) {
    return pathDataValueList.firstWhere(
      (item) => BasePathDataValue.hasPath(item, path),
      orElse: () => BasePathDataValue.unknown(),
    );
  }

  BasePathDataValue findDataByRank(String rank) {
    return pathDataValueList.firstWhere(
      (item) => BasePathDataValue.hasRank(item, rank),
      orElse: () => BasePathDataValue.unknown(),
    );
  }

  BasePathDataValue getCurrent() {
    return findDataByRank(currentRank);
  }

  static List<String> toRankList(List<BasePathDataValue> valueList) =>
      valueList.whereType<PathDataValue>().map((value) => value.rank).toList()
        ..sort();
}

class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
