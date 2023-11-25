enum Level { error, warning, info }

enum Category { syntax, spelling, server }

enum DataStatus {
  empty,
  populated,
  warning,
  error,
  skipped,
  unknown,
  starting,
  ending,
  todo,
  template,
}

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

class SectionPathDataMetadata {
  String title;
  SectionPathDataMetadata({required this.title});
}

class DataPreview {
  String text;
  DataPreview({required this.text});
}

sealed class BasePathDataValue {
  DataStatus _status;
  BasePathDataValue({required DataStatus status}) : _status = status;

  DataStatus get status => _status;

  String? get rank => switch (this) {
        UnknownPathDataValue() => null,
        EndingSectionPathDataValue(rank: var valueRank) => valueRank,
        PathDataValue(rank: var valueRank) => valueRank,
        TemplatePathDataValue(rank: var valueRank) => valueRank,
        SectionPathDataValue(rank: var valueRank) => valueRank
      };

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
  factory BasePathDataValue.template(
      {required String path, required metadata, required String rank}) {
    return PathDataValue(
      status: DataStatus.template,
      path: path,
      metadata: metadata,
      rank: rank,
    );
  }
  factory BasePathDataValue.start({
    required String path,
    required metadata,
    required String rank,
  }) {
    return SectionPathDataValue(
      status: DataStatus.starting,
      path: path,
      metadata: metadata,
      rank: rank,
    );
  }

  factory BasePathDataValue.ending({required String rank}) =>
      EndingSectionPathDataValue(status: DataStatus.ending, rank: rank);
}

class BasePathDataValueFilter {
  static bool hasPath(BasePathDataValue value, String searchPath) {
    return switch (value) {
      UnknownPathDataValue() => false,
      PathDataValue(path: var valuePath) => valuePath == searchPath,
      TemplatePathDataValue(path: var valuePath) => valuePath == searchPath,
      SectionPathDataValue(path: var valuePath) => valuePath == searchPath,
      EndingSectionPathDataValue() => false,
    };
  }

  static bool hasRank(BasePathDataValue value, String searchRank) {
    return switch (value) {
      UnknownPathDataValue() => false,
      PathDataValue(rank: var valueRank) => valueRank == searchRank,
      TemplatePathDataValue(rank: var valueRank) => valueRank == searchRank,
      SectionPathDataValue(rank: var valueRank) => valueRank == searchRank,
      EndingSectionPathDataValue(rank: var valueRank) => valueRank == searchRank
    };
  }

  static bool hasStatus(BasePathDataValue value, DataStatus searchStatus) {
    return switch (value) {
      UnknownPathDataValue() => false,
      PathDataValue(status: var valueStatus) => valueStatus == searchStatus,
      TemplatePathDataValue(status: var valueStatus) =>
        valueStatus == searchStatus,
      SectionPathDataValue(status: var valueStatus) =>
        valueStatus == searchStatus,
      EndingSectionPathDataValue(status: var valueStatus) =>
        valueStatus == searchStatus,
    };
  }

  static bool hasNotStatus(BasePathDataValue value, DataStatus searchStatus) =>
      !hasStatus(value, searchStatus);

  static bool hasAnyStatus(
      BasePathDataValue value, List<DataStatus> searchStatusList) {
    return switch (value) {
      UnknownPathDataValue() => false,
      PathDataValue(status: var valueStatus) =>
        searchStatusList.contains(valueStatus),
      TemplatePathDataValue(status: var valueStatus) =>
        searchStatusList.contains(valueStatus),
      SectionPathDataValue(status: var valueStatus) =>
        searchStatusList.contains(valueStatus),
      EndingSectionPathDataValue(status: var valueStatus) =>
        searchStatusList.contains(valueStatus)
    };
  }
}

class PathDataValue extends BasePathDataValue {
  String path;
  PathDataMetadata metadata;
  @override
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathDataValue &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          metadata == other.metadata &&
          rank == other.rank &&
          draft == other.draft &&
          loaded == other.loaded &&
          refreshed == other.refreshed;

  @override
  int get hashCode =>
      path.hashCode ^
      metadata.hashCode ^
      rank.hashCode ^
      draft.hashCode ^
      loaded.hashCode ^
      refreshed.hashCode;

  @override
  String toString() {
    return 'PathDataValue{path: $path, metadata: $metadata, rank: $rank, draft: $draft, loaded: $loaded, refreshed: $refreshed}';
  }
}

class TemplatePathDataValue extends BasePathDataValue {
  String path;
  PathDataMetadata metadata;
  @override
  String rank;
  TemplatePathDataValue(
      {required super.status,
      required this.path,
      required this.metadata,
      required this.rank});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TemplatePathDataValue &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          metadata == other.metadata &&
          rank == other.rank;

  @override
  int get hashCode => path.hashCode ^ metadata.hashCode ^ rank.hashCode;

  @override
  String toString() {
    return 'TemplatePathDataValue{path: $path, metadata: $metadata, rank: $rank}';
  }
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

class SectionPathDataValue extends BasePathDataValue {
  String path;
  SectionPathDataMetadata metadata;
  @override
  String rank;

  SectionPathDataValue(
      {required super.status,
      required this.path,
      required this.metadata,
      required this.rank});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SectionPathDataValue &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          metadata == other.metadata &&
          rank == other.rank;

  @override
  int get hashCode => path.hashCode ^ metadata.hashCode ^ rank.hashCode;

  @override
  String toString() {
    return 'SectionPathDataValue{path: $path, metadata: $metadata, rank: $rank}';
  }
}

class EndingSectionPathDataValue extends BasePathDataValue {
  @override
  String rank;
  EndingSectionPathDataValue({required super.status, required this.rank});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EndingSectionPathDataValue &&
          runtimeType == other.runtimeType &&
          rank == other.rank;

  @override
  int get hashCode => rank.hashCode;

  @override
  String toString() {
    return 'EndingSectionPathDataValue{rank: $rank}';
  }
}

class SuricattaDataNavigatorException implements Exception {
  final String message;
  SuricattaDataNavigatorException(this.message);
  @override
  String toString() => message;
}

class SuricattaDataNavigator {
  List<BasePathDataValue> pathDataValueList;
  String? currentRank;
  String? possibleRank;
  SuricattaDataNavigator({required this.pathDataValueList});

  BasePathDataValue findDataByPath(String path) {
    return pathDataValueList.firstWhere(
      (item) => BasePathDataValueFilter.hasPath(item, path),
      orElse: () => BasePathDataValue.unknown(),
    );
  }

  BasePathDataValue findDataByRank(String rank) {
    return pathDataValueList.firstWhere(
      (item) => BasePathDataValueFilter.hasRank(item, rank),
      orElse: () => BasePathDataValue.unknown(),
    );
  }

  BasePathDataValue getCurrent() {
    if (currentRank is String) {
      return findDataByRank(currentRank ?? '');
    } else {
      return BasePathDataValue.unknown();
    }
  }

  PathDataValue getCurrentValue() {
    if (currentRank is String) {
      final maybeValue = findDataByRank(currentRank ?? '');
      if (maybeValue is PathDataValue) {
        return maybeValue;
      }
    }
    throw SuricattaDataNavigatorException(
        'Cannot get a current value for navigation');
  }

  bool hasCurrent() => (currentRank is String);

  first() {
    final firstRank = toActiveRankList(pathDataValueList).firstOrNull;
    possibleRank = firstRank;
    return this;
  }

  firstWhere(bool Function(BasePathDataValue) where) {
    final matched = pathDataValueList.firstWhere(where,
        orElse: () => BasePathDataValue.unknown());
    possibleRank = matched.rank;
    return this;
  }

  last() {
    final lastRank = toActiveRankList(pathDataValueList).lastOrNull;
    possibleRank = lastRank;
    return this;
  }

  next() {
    final ranks = toActiveRankList(pathDataValueList);
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    if (indexCurrent >= 0 && indexCurrent < ranks.length - 1) {
      possibleRank = ranks[indexCurrent + 1];
    } else {
      possibleRank = null;
    }
    return this;
  }

  nextWhere(bool Function(BasePathDataValue) where) {
    final ranks = toRankList(pathDataValueList);
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    final matched = pathDataValueList.firstWhere((value) {
      final matchingRank = ranks.indexOf(value.rank ?? '');
      return (indexCurrent == -1 || matchingRank > indexCurrent) &&
          where(value);
    }, orElse: () => BasePathDataValue.unknown());
    possibleRank = matched.rank;
    return this;
  }

  previous() {
    final ranks = toActiveRankList(pathDataValueList);
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    if (indexCurrent > 0) {
      possibleRank = ranks[indexCurrent - 1];
    } else {
      possibleRank = null;
    }
    return this;
  }

  bool canMove() => (possibleRank is String);

  move() {
    if (possibleRank != null) {
      currentRank = possibleRank;
    }
    return this;
  }

  static List<String> toRankList(List<BasePathDataValue> valueList) => valueList
      .whereType<PathDataValue>()

      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  static List<String> toActiveRankList(List<BasePathDataValue> valueList) =>
      toRankList(valueList
          .where((value) =>
              BasePathDataValueFilter.hasNotStatus(value, DataStatus.template))
          .toList());
}

class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
