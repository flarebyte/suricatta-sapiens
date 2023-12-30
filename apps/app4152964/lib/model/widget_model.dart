import 'dart:collection';

import 'hierarchical_identifier.dart';

enum MessageLevel { error, warning, info }

enum MessageCategory { syntax, spelling, server }

enum DataStatus {
  populated,
  error,
  todo,
}

enum ViewStatus {
  full,
  minimized,
}

enum WidgetKind { text, number }

enum DataCategory { draft, loaded, refreshed, template, starting, ending }

class Message {
  String message;
  MessageLevel level;
  MessageCategory category;

  Message(this.message, this.level, this.category);

  static bool hasError(List<Message> messages) =>
      messages.any((message) => message.level == MessageLevel.error);
}

class PathDataException implements Exception {
  final String message;
  PathDataException(this.message);
}

class DataMetadata {
  String title;
  WidgetKind widgetKind;
  bool optional;
  List<Message> Function(String?) validator;
  DataMetadata(
      {required this.title,
      required this.widgetKind,
      required this.validator,
      this.optional = false});
  factory DataMetadata.unknown() {
    return DataMetadata(
      title: '',
      widgetKind: WidgetKind.text,
      validator: (value) => [],
    );
  }
}

class SectionMetadata {
  String title;
  SectionMetadata({required this.title});
}

class DataPreview {
  String text;
  DataPreview({required this.text});
}

sealed class BaseDataValue {
  DataStatus _status = DataStatus.todo;
  ViewStatus _viewStatus = ViewStatus.full;
  BaseDataValue({required DataStatus status, required ViewStatus viewStatus}) {
    _status = status;
    _viewStatus = viewStatus;
  }

  DataStatus get status => _status;
  ViewStatus get viewStatus => _viewStatus;

  String get rank => switch (this) {
        EndingSection(rank: var valueRank) => valueRank,
        PathDataValue(rank: var valueRank) => valueRank,
        StartingSection(rank: var valueRank) => valueRank
      };

  String get composedRank => switch (this) {
        EndingSection(rank: var valueRank) => 'end-$valueRank',
        PathDataValue(rank: var valueRank, category: var valueCategory) =>
          '$valueCategory-$valueRank',
        StartingSection(rank: var valueRank) => 'start-$valueRank',
      };

  String? get text => switch (this) {
        EndingSection() => null,
        PathDataValue(text: var valueText) => valueText,
        StartingSection() => null
      };
  List<Message> get messages => switch (this) {
        EndingSection() => [],
        PathDataValue(messages: var messageList) => messageList,
        StartingSection() => []
      };

  factory BaseDataValue.some(
      {required DataStatus status,
      required String path,
      required metadata,
      required String rank,
      String? text}) {
    return PathDataValue(
      status: status,
      viewStatus: ViewStatus.full,
      path: path,
      metadata: metadata,
      rank: rank,
      category: DataCategory.draft,
      text: text,
    );
  }
  factory BaseDataValue.template(
      {required String path, required metadata, required String rank}) {
    return PathDataValue(
      status: DataStatus.todo,
      viewStatus: ViewStatus.full,
      path: path,
      metadata: metadata,
      rank: rank,
      category: DataCategory.template,
    );
  }
  factory BaseDataValue.start({
    required String path,
    required SectionMetadata metadata,
    required String rank,
  }) {
    return StartingSection(
      status: DataStatus.todo,
      viewStatus: ViewStatus.full,
      path: path,
      metadata: metadata,
      rank: rank,
    );
  }

  factory BaseDataValue.ending({required String rank}) => EndingSection(
      status: DataStatus.todo, viewStatus: ViewStatus.full, rank: rank);
}

class DataFilter {
  static bool hasPath(BaseDataValue value, String searchPath) {
    return switch (value) {
      PathDataValue(path: var valuePath) => valuePath == searchPath,
      StartingSection(path: var valuePath) => valuePath == searchPath,
      EndingSection() => false,
    };
  }

  static bool hasRank(BaseDataValue value, String searchRank) {
    return switch (value) {
      PathDataValue(rank: var valueRank) => valueRank == searchRank,
      StartingSection(rank: var valueRank) => valueRank == searchRank,
      EndingSection(rank: var valueRank) => valueRank == searchRank
    };
  }

  static bool hasStatus(BaseDataValue value, DataStatus searchStatus) {
    return switch (value) {
      PathDataValue(status: var valueStatus) => valueStatus == searchStatus,
      StartingSection(status: var valueStatus) => valueStatus == searchStatus,
      EndingSection(status: var valueStatus) => valueStatus == searchStatus,
    };
  }

  static bool hasCategory(BaseDataValue value, DataCategory searchCategory) {
    return switch (value) {
      PathDataValue(category: var valueCategory) =>
        valueCategory == searchCategory,
      StartingSection() => searchCategory == DataCategory.starting,
      EndingSection() => searchCategory == DataCategory.ending,
    };
  }

  static bool hasNotStatus(BaseDataValue value, DataStatus searchStatus) =>
      !hasStatus(value, searchStatus);

  static bool hasNotCategory(
          BaseDataValue value, DataCategory searchCategory) =>
      !hasCategory(value, searchCategory);

  static bool hasAnyStatus(
      BaseDataValue value, List<DataStatus> searchStatusList) {
    return switch (value) {
      PathDataValue(status: var valueStatus) =>
        searchStatusList.contains(valueStatus),
      StartingSection(status: var valueStatus) =>
        searchStatusList.contains(valueStatus),
      EndingSection(status: var valueStatus) =>
        searchStatusList.contains(valueStatus)
    };
  }
}

class PathDataValue extends BaseDataValue {
  String path;
  DataMetadata metadata;
  @override
  String rank;
  DataCategory category;
  @override
  String? text;
  @override
  List<Message> messages;

  PathDataValue({
    required super.status,
    required super.viewStatus,
    required this.path,
    required this.metadata,
    required this.rank,
    required this.category,
    this.text,
    this.messages = const [],
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
    return 'PathDataValue{path: $path, metadata: $metadata, rank: $rank, category: $category, text: $text, status: $status, view status: $viewStatus}';
  }

  setTextAsString(String newText) {
    final isSupported = metadata.widgetKind == WidgetKind.text;
    if (!isSupported) {
      throw PathDataException('Not supported for ${metadata.widgetKind}');
    }
    text = newText;
    final validationResults = metadata.validator(text);
    final unsuccessful = Message.hasError(validationResults);
    _status = unsuccessful ? DataStatus.error : DataStatus.populated;
    messages = validationResults;
  }

  factory PathDataValue.todo(PathDataValue template) {
    return PathDataValue(
      path: template.path,
      metadata: template.metadata,
      rank: template.rank,
      category: DataCategory.draft,
      text: template.text,
      status: DataStatus.todo,
      viewStatus: ViewStatus.full,
    );
  }
}

class StartingSection extends BaseDataValue {
  String path;
  SectionMetadata metadata;
  @override
  String rank;

  StartingSection(
      {required super.status,
      required super.viewStatus,
      required this.path,
      required this.metadata,
      required this.rank});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartingSection &&
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

class EndingSection extends BaseDataValue {
  @override
  String rank;
  EndingSection(
      {required super.status, required super.viewStatus, required this.rank});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EndingSection &&
          runtimeType == other.runtimeType &&
          rank == other.rank;

  @override
  int get hashCode => rank.hashCode;

  @override
  String toString() {
    return 'EndingSectionPathDataValue{rank: $rank}';
  }
}

class DataValueCollection {
  SplayTreeMap<String, BaseDataValue> pathDataValueMap =
      SplayTreeMap<String, BaseDataValue>((a, b) => a.compareTo(b));
  update(BaseDataValue added) {
    pathDataValueMap.update(added.composedRank, (v) => added,
        ifAbsent: () => added);
  }

  List<String> toRankList() => pathDataValueMap.values
      .whereType<PathDataValue>()
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  List<String> toActiveRankList() => pathDataValueMap.values
      .whereType<PathDataValue>()
      .where((value) => DataFilter.hasNotCategory(value, DataCategory.template))
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  BaseDataValue? findByRank(String rank,
          [DataCategory category = DataCategory.draft]) =>
      pathDataValueMap['$category-$rank'];

  BaseDataValue findByPath(String path,
      [DataCategory category = DataCategory.draft]) {
    return pathDataValueMap.values.firstWhere(
      (item) =>
          DataFilter.hasPath(item, path) &&
          DataFilter.hasCategory(item, category),
    );
  }

  count() => pathDataValueMap.length;

  countByCategory(DataCategory category) => pathDataValueMap.values
      .where((item) => DataFilter.hasCategory(item, category))
      .length;

  BaseDataValue? firstWhere(bool Function(BaseDataValue) where) {
    final BaseDataValue result = pathDataValueMap.values
        .toList()
        .firstWhere(where, orElse: () => BaseDataValue.ending(rank: ''));
    return result.rank == '' ? null : result;
  }

  Iterable<PathDataValue> findAllByCategory(DataCategory category) =>
      pathDataValueMap.values
          .whereType<PathDataValue>()
          .where((item) => DataFilter.hasCategory(item, DataCategory.template));
}

class DataNavigatorException implements Exception {
  final String message;
  DataNavigatorException(this.message);
  @override
  String toString() => message;
}

class DataNavigator {
  DataValueCollection dataValueCollection = DataValueCollection();
  HierarchicalIdentifierBuilder hierarchicalIdentifierBuilder =
      HierarchicalIdentifierBuilder();
  String? currentRank;
  String? possibleRank;
  DataNavigator();

  setRoot() {
    hierarchicalIdentifierBuilder.setRoot();
  }

  addTemplate(String path, DataMetadata metadata) {
    final template = BaseDataValue.template(
        path: path,
        metadata: metadata,
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    dataValueCollection.update(template);
  }

  addStart(String path, SectionMetadata metadata) {
    final start = BaseDataValue.start(
        path: path,
        metadata: metadata,
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    dataValueCollection.update(start);
  }

  addEnding() {
    final ending = BaseDataValue.ending(
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    dataValueCollection.update(ending);
  }

  BaseDataValue? findDataByPath(String path,
      [DataCategory category = DataCategory.draft]) {
    return dataValueCollection.firstWhere(
      (item) =>
          DataFilter.hasPath(item, path) &&
          DataFilter.hasCategory(item, category),
    );
  }

  BaseDataValue? findDataByRank(String rank,
      [DataCategory category = DataCategory.draft]) {
    return dataValueCollection.firstWhere(
      (item) =>
          DataFilter.hasRank(item, rank) &&
          DataFilter.hasCategory(item, category),
    );
  }

  BaseDataValue? getCurrent() {
    if (currentRank is String) {
      return findDataByRank(currentRank ?? '', DataCategory.draft);
    } else {
      throw DataNavigatorException('There is no current element');
    }
  }

  PathDataValue getCurrentValue() {
    if (currentRank is String) {
      final maybeValue = findDataByRank(currentRank ?? '', DataCategory.draft);
      if (maybeValue is PathDataValue) {
        return maybeValue;
      }
    }
    throw DataNavigatorException('Cannot get a current value for navigation');
  }

  bool hasCurrent() => (currentRank is String);

  first() {
    final firstRank = dataValueCollection.toActiveRankList().firstOrNull;
    possibleRank = firstRank;
    return this;
  }

  firstWhere(bool Function(BaseDataValue) where) {
    final matched = dataValueCollection.firstWhere(where);
    if (matched is BaseDataValue) {
      possibleRank = matched.rank;
    } else {
      possibleRank = null;
    }
    return this;
  }

  last() {
    final lastRank = dataValueCollection.toActiveRankList().lastOrNull;
    possibleRank = lastRank;
    return this;
  }

  next() {
    final ranks = dataValueCollection.toActiveRankList();
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    if (indexCurrent >= 0 && indexCurrent < ranks.length - 1) {
      possibleRank = ranks[indexCurrent + 1];
    } else {
      possibleRank = null;
    }
    return this;
  }

  nextWhere(bool Function(BaseDataValue) where) {
    final ranks = dataValueCollection.toRankList();
    final indexCurrent = ranks.indexOf(currentRank ?? '');
    final matched = dataValueCollection.firstWhere((value) {
      final matchingRank = ranks.indexOf(value.rank);
      return (indexCurrent == -1 || matchingRank > indexCurrent) &&
          where(value);
    });
    if (matched is BaseDataValue) {
      possibleRank = matched.rank;
    } else {
      possibleRank = null;
    }
    return this;
  }

  previous() {
    final ranks = dataValueCollection.toActiveRankList();
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

  count() => dataValueCollection.count();

  countByCategory(DataCategory category) =>
      dataValueCollection.countByCategory(category);

  createRootTodos() {
    final todoTemplates =
        dataValueCollection.findAllByCategory(DataCategory.template).toList();
    for (PathDataValue template in todoTemplates) {
      final todo = PathDataValue.todo(template);
      dataValueCollection.update(todo);
    }
  }

  setTextAsStringByRank(String newText,
      {required String rank, DataCategory category = DataCategory.draft}) {
    final previous = dataValueCollection.findByRank(rank, category);
    if (previous is PathDataValue) {
      previous.setTextAsString(newText);
    } else {
      throw DataNavigatorException(
          "No existing value for rank: $rank and category: $category");
    }
  }

  setTextAsStringByPath(String newText,
      {required String path, DataCategory category = DataCategory.draft}) {
    final previous = dataValueCollection.findByPath(path, category);
    if (previous is PathDataValue) {
      previous.setTextAsString(newText);
    } else {
      throw DataNavigatorException(
          "No existing value for path: $path and category: $category");
    }
  }

  setCurrentText(String newText) {
    if (currentRank is String) {
      setTextAsStringByRank(newText, rank: currentRank ?? '');
    } else {
      throw DataNavigatorException('Current rank is not set');
    }
  }

  static List<String> toRankList(List<BaseDataValue> valueList) => valueList
      .whereType<PathDataValue>()
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  static List<String> toActiveRankList(List<BaseDataValue> valueList) =>
      toRankList(valueList
          .where((value) =>
              DataFilter.hasNotCategory(value, DataCategory.template))
          .toList());
}

class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
