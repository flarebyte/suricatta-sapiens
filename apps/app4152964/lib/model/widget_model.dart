import 'dart:collection';

import 'hierarchical_identifier.dart';

enum Level { error, warning, info }

enum Category { syntax, spelling, server }

enum DataStatus {
  populated,
  warning,
  error,
  skipped,
  unknown,
  todo,
}

enum WidgetKind { text, number }

enum DataCategory { draft, loaded, refreshed, template, starting, ending }

class Message {
  String message;
  Level level;
  Category category;

  Message(this.message, this.level, this.category);
}

class PathDataError implements Exception {
  final String message;
  PathDataError(this.message);
}

class PathDataMetadata {
  String title;
  WidgetKind widgetKind;
  bool optional;
  List<Message> Function(String?) validator;
  PathDataMetadata(
      {required this.title,
      required this.widgetKind,
      required this.validator,
      this.optional = false});
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

  String get rank => switch (this) {
        EndingSectionPathDataValue(rank: var valueRank) => valueRank,
        PathDataValue(rank: var valueRank) => valueRank,
        SectionPathDataValue(rank: var valueRank) => valueRank
      };

  String get composedRank => switch (this) {
        EndingSectionPathDataValue(rank: var valueRank) => 'end-$valueRank',
        PathDataValue(rank: var valueRank, category: var valueCategory) =>
          '$valueCategory-$valueRank',
        SectionPathDataValue(rank: var valueRank) => 'start-$valueRank',
      };

  String? get text => switch (this) {
        EndingSectionPathDataValue() => null,
        PathDataValue(text: var valueText) => valueText,
        SectionPathDataValue() => null
      };

  factory BasePathDataValue.some(
      {required DataStatus status,
      required String path,
      required metadata,
      required String rank,
      String? text}) {
    return PathDataValue(
      status: status,
      path: path,
      metadata: metadata,
      rank: rank,
      category: DataCategory.draft,
      text: text,
    );
  }
  factory BasePathDataValue.template(
      {required String path, required metadata, required String rank}) {
    return PathDataValue(
      status: DataStatus.todo,
      path: path,
      metadata: metadata,
      rank: rank,
      category: DataCategory.template,
    );
  }
  factory BasePathDataValue.start({
    required String path,
    required SectionPathDataMetadata metadata,
    required String rank,
  }) {
    return SectionPathDataValue(
      status: DataStatus.todo,
      path: path,
      metadata: metadata,
      rank: rank,
    );
  }

  factory BasePathDataValue.ending({required String rank}) =>
      EndingSectionPathDataValue(status: DataStatus.todo, rank: rank);
}

class BasePathDataValueFilter {
  static bool hasPath(BasePathDataValue value, String searchPath) {
    return switch (value) {
      PathDataValue(path: var valuePath) => valuePath == searchPath,
      SectionPathDataValue(path: var valuePath) => valuePath == searchPath,
      EndingSectionPathDataValue() => false,
    };
  }

  static bool hasRank(BasePathDataValue value, String searchRank) {
    return switch (value) {
      PathDataValue(rank: var valueRank) => valueRank == searchRank,
      SectionPathDataValue(rank: var valueRank) => valueRank == searchRank,
      EndingSectionPathDataValue(rank: var valueRank) => valueRank == searchRank
    };
  }

  static bool hasStatus(BasePathDataValue value, DataStatus searchStatus) {
    return switch (value) {
      PathDataValue(status: var valueStatus) => valueStatus == searchStatus,
      SectionPathDataValue(status: var valueStatus) =>
        valueStatus == searchStatus,
      EndingSectionPathDataValue(status: var valueStatus) =>
        valueStatus == searchStatus,
    };
  }

  static bool hasCategory(
      BasePathDataValue value, DataCategory searchCategory) {
    return switch (value) {
      PathDataValue(category: var valueCategory) =>
        valueCategory == searchCategory,
      SectionPathDataValue() => searchCategory == DataCategory.starting,
      EndingSectionPathDataValue() => searchCategory == DataCategory.ending,
    };
  }

  static bool hasNotStatus(BasePathDataValue value, DataStatus searchStatus) =>
      !hasStatus(value, searchStatus);

  static bool hasNotCategory(
          BasePathDataValue value, DataCategory searchCategory) =>
      !hasCategory(value, searchCategory);

  static bool hasAnyStatus(
      BasePathDataValue value, List<DataStatus> searchStatusList) {
    return switch (value) {
      PathDataValue(status: var valueStatus) =>
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
  DataCategory category;
  @override
  String? text;

  PathDataValue({
    required super.status,
    required this.path,
    required this.metadata,
    required this.rank,
    required this.category,
    this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PathDataValue &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          metadata == other.metadata &&
          rank == other.rank &&
          category == other.category &&
          text == other.text;

  @override
  int get hashCode =>
      path.hashCode ^
      metadata.hashCode ^
      rank.hashCode ^
      category.hashCode ^
      text.hashCode;

  @override
  String toString() {
    return 'PathDataValue{path: $path, metadata: $metadata, rank: $rank, category: $category, text: $text}';
  }

  setTextAsString(String newText) {
    final isSupported = metadata.widgetKind == WidgetKind.text;
    if (!isSupported) {
      throw PathDataError('Not supported for ${metadata.widgetKind}');
    }
    text = newText;
    _status = DataStatus.populated;
  }

  factory PathDataValue.todo(PathDataValue template) {
    return PathDataValue(
        path: template.path,
        metadata: template.metadata,
        rank: template.rank,
        category: DataCategory.draft,
        text: template.text,
        status: DataStatus.todo);
  }
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

class BasePathDataValueCollection {
  SplayTreeMap<String, BasePathDataValue> pathDataValueMap =
      SplayTreeMap<String, BasePathDataValue>((a, b) => a.compareTo(b));
  add(BasePathDataValue added) {
    pathDataValueMap.update(added.composedRank, (v) => added);
  }

  List<String> toRankList() => pathDataValueMap.values
      .whereType<PathDataValue>()
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  List<String> toActiveRankList() => pathDataValueMap.values
      .whereType<PathDataValue>()
      .where((value) =>
          BasePathDataValueFilter.hasNotCategory(value, DataCategory.template))
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  BasePathDataValue? findByRank(String rank,
          [DataCategory category = DataCategory.draft]) =>
      pathDataValueMap['$category-$rank'];

  BasePathDataValue findDataByPath(String path,
      [DataCategory category = DataCategory.draft]) {
    return pathDataValueMap.values.firstWhere(
      (item) =>
          BasePathDataValueFilter.hasPath(item, path) &&
          BasePathDataValueFilter.hasCategory(item, category),
    );
  }

  count() => pathDataValueMap.length;

  countByCategory(DataCategory category) => pathDataValueMap.values
      .where((item) => BasePathDataValueFilter.hasCategory(item, category))
      .length;

  firstWhere(bool Function(BasePathDataValue) where) =>
      pathDataValueMap.values.firstWhere(where);

  Iterable<PathDataValue> findAllByCategory(DataCategory category) =>
      pathDataValueMap.values.whereType<PathDataValue>().where((item) =>
          BasePathDataValueFilter.hasCategory(item, DataCategory.template));
}

class SuricattaDataNavigatorException implements Exception {
  final String message;
  SuricattaDataNavigatorException(this.message);
  @override
  String toString() => message;
}

class SuricattaDataNavigator {
  BasePathDataValueCollection pathDataValueList = BasePathDataValueCollection();
  HierarchicalIdentifierBuilder hierarchicalIdentifierBuilder =
      HierarchicalIdentifierBuilder();
  String? currentRank;
  String? possibleRank;
  SuricattaDataNavigator();

  setRoot() {
    hierarchicalIdentifierBuilder.setRoot();
  }

  addTemplate(String path, PathDataMetadata metadata) {
    final template = BasePathDataValue.template(
        path: path,
        metadata: metadata,
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    pathDataValueList.add(template);
  }

  addStart(String path, SectionPathDataMetadata metadata) {
    final start = BasePathDataValue.start(
        path: path,
        metadata: metadata,
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    pathDataValueList.add(start);
  }

  addEnding() {
    final ending = BasePathDataValue.ending(
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    pathDataValueList.add(ending);
  }

  BasePathDataValue findDataByPath(String path,
      [DataCategory category = DataCategory.draft]) {
    return pathDataValueList.firstWhere(
      (item) =>
          BasePathDataValueFilter.hasPath(item, path) &&
          BasePathDataValueFilter.hasCategory(item, category),
    );
  }

  BasePathDataValue findDataByRank(String rank,
      [DataCategory category = DataCategory.draft]) {
    return pathDataValueList.firstWhere(
      (item) =>
          BasePathDataValueFilter.hasRank(item, rank) &&
          BasePathDataValueFilter.hasCategory(item, category),
    );
  }

  BasePathDataValue getCurrent() {
    if (currentRank is String) {
      return findDataByRank(currentRank ?? '', DataCategory.draft);
    } else {
      throw SuricattaDataNavigatorException('There is no current element');
    }
  }

  PathDataValue getCurrentValue() {
    if (currentRank is String) {
      final maybeValue = findDataByRank(currentRank ?? '', DataCategory.draft);
      if (maybeValue is PathDataValue) {
        return maybeValue;
      }
    }
    throw SuricattaDataNavigatorException(
        'Cannot get a current value for navigation');
  }

  bool hasCurrent() => (currentRank is String);

  first() {
    final firstRank = pathDataValueList.toActiveRankList().firstOrNull;
    possibleRank = firstRank;
    return this;
  }

  firstWhere(bool Function(BasePathDataValue) where) {
    final matched = pathDataValueList.firstWhere(where);
    possibleRank = matched.rank;
    return this;
  }

  last() {
    final lastRank = pathDataValueList.toActiveRankList().lastOrNull;
    possibleRank = lastRank;
    return this;
  }

  next() {
    final ranks = pathDataValueList.toActiveRankList();
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    if (indexCurrent >= 0 && indexCurrent < ranks.length - 1) {
      possibleRank = ranks[indexCurrent + 1];
    } else {
      possibleRank = null;
    }
    return this;
  }

  nextWhere(bool Function(BasePathDataValue) where) {
    final ranks = pathDataValueList.toRankList();
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    final matched = pathDataValueList.firstWhere((value) {
      final matchingRank = ranks.indexOf(value.rank);
      return (indexCurrent == -1 || matchingRank > indexCurrent) &&
          where(value);
    });
    possibleRank = matched.rank;
    return this;
  }

  previous() {
    final ranks = pathDataValueList.toActiveRankList();
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

  count() => pathDataValueList.count();

  countByCategory(DataCategory category) =>
      pathDataValueList.countByCategory(category);

  createRootTodos() {
    final todoTemplates =
        pathDataValueList.findAllByCategory(DataCategory.template);
    List<BasePathDataValue> newPathDataValueList = [];
    for (PathDataValue template in todoTemplates) {
      final todo = PathDataValue.todo(template);
      newPathDataValueList.add(todo);
    }
    // pathDataValueList = newPathDataValueList;
  }

  setTextAsStringByRank(String newText,
      {required String rank, DataCategory category = DataCategory.draft}) {
    final previous = pathDataValueList.findByRank(rank, category);
    if (previous is PathDataValue) {
      previous.setTextAsString(newText);
    } else {
      throw SuricattaDataNavigatorException(
          "No existing value for rank: $rank and category: $category");
    }
  }

  setTextAsStringByPath(String newText,
      {required String path, DataCategory category = DataCategory.draft}) {
    final previous = pathDataValueList.findDataByPath(path, category);
    if (previous is PathDataValue) {
      previous.setTextAsString(newText);
    } else {
      throw SuricattaDataNavigatorException(
          "No existing value for path: $path and category: $category");
    }
  }

  static List<String> toRankList(List<BasePathDataValue> valueList) => valueList
      .whereType<PathDataValue>()
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  static List<String> toActiveRankList(List<BasePathDataValue> valueList) =>
      toRankList(valueList
          .where((value) => BasePathDataValueFilter.hasNotCategory(
              value, DataCategory.template))
          .toList());
}

class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
