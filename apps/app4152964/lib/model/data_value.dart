import 'message.dart';
import 'validators.dart';

enum DataStatus {
  populated,
  error,
  todo,
}

enum ViewStatus {
  full,
  minimized,
}

enum DataCategory { draft, loaded, refreshed, template, starting, ending }

/// Base class to simulate an union type that would take the values:
/// DataValue, StartingSection, EndingSection
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
        DataValue(rank: var valueRank) => valueRank,
        StartingSection(rank: var valueRank) => valueRank
      };

  String get composedRank => switch (this) {
        EndingSection(rank: var valueRank) => 'end-$valueRank',
        DataValue(rank: var valueRank, category: var valueCategory) =>
          '$valueCategory-$valueRank',
        StartingSection(rank: var valueRank) => 'start-$valueRank',
      };

  String? get text => switch (this) {
        EndingSection() => null,
        DataValue(text: var valueText) => valueText,
        StartingSection() => null
      };

  List<String> get otherTexts => switch (this) {
        EndingSection() => [],
        DataValue(otherTexts: var valueOtherTexts) => valueOtherTexts,
        StartingSection() => []
      };

  List<Message> get messages => switch (this) {
        EndingSection() => [],
        DataValue(messages: var messageList) => messageList,
        StartingSection() => []
      };
}
/// Factory to provide sugar functions to create
/// some, template, start or ending
/// Note: initially this was part of the base class as
/// factory methods but we were having issues after refactoring
class DataValueFactory {
  static DataValue some(
      {required DataStatus status,
      required String path,
      required metadata,
      required String rank,
      String? text}) {
    return DataValue(
      status: status,
      viewStatus: ViewStatus.full,
      path: path,
      metadata: metadata,
      rank: rank,
      category: DataCategory.draft,
      text: text,
    );
  }

  static DataValue template(
      {required String path, required metadata, required String rank}) {
    return DataValue(
      status: DataStatus.todo,
      viewStatus: ViewStatus.full,
      path: path,
      metadata: metadata,
      rank: rank,
      category: DataCategory.template,
    );
  }

  static start({
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

  static ending({required String rank}) => EndingSection(
      status: DataStatus.todo, viewStatus: ViewStatus.full, rank: rank);
}

enum WidgetKind { text, number, choices, multiselect }

class PathDataException implements Exception {
  final String message;
  PathDataException(this.message);
}

/// Metadata for DataValue
/// This should facilitate the reuse of metadata for different values
class DataMetadata {
  String title;
  WidgetKind widgetKind;
  bool optional;
  List<Message> Function({String? text, List<String> otherTexts}) validator;
  DataMetadata(
      {required this.title,
      required this.widgetKind,
      required this.validator,
      this.optional = false});
  factory DataMetadata.unknown() {
    return DataMetadata(
      title: '',
      widgetKind: WidgetKind.text,
      validator: alwaysPassValidator,
    );
  }
}

/// DataValue is usually used to represent fields that will be edited
/// by the user. This will include the current state of the field (ex: error)
class DataValue extends BaseDataValue {
  String path;
  DataMetadata metadata;
  @override
  String rank;
  DataCategory category;
  @override
  String? text;
  @override
  List<String> otherTexts;
  @override
  List<Message> messages;

  DataValue({
    required super.status,
    required super.viewStatus,
    required this.path,
    required this.metadata,
    required this.rank,
    required this.category,
    this.text,
    this.otherTexts = const [],
    this.messages = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataValue &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          metadata == other.metadata &&
          rank == other.rank &&
          category == other.category &&
          text == other.text &&
          otherTexts == other.otherTexts;

  @override
  int get hashCode =>
      path.hashCode ^
      metadata.hashCode ^
      rank.hashCode ^
      category.hashCode ^
      text.hashCode ^
      otherTexts.hashCode;

  @override
  String toString() {
    return 'PathDataValue{path: $path, metadata: $metadata, rank: $rank, category: $category, text: $text, otherTexts: ${otherTexts.length}, status: $status, view status: $viewStatus}';
  }

  setTextAsString(String newText) {
    final isSupported = metadata.widgetKind == WidgetKind.text;
    if (!isSupported) {
      throw PathDataException('Not supported for ${metadata.widgetKind}');
    }
    text = newText;
    final validationResults = metadata.validator(text: text);
    final unsuccessful = Message.hasError(validationResults);
    _status = unsuccessful ? DataStatus.error : DataStatus.populated;
    messages = validationResults;
  }

  setViewStatus(ViewStatus newViewStatus) {
    _viewStatus = newViewStatus;
  }

  setOtherTextsAsStrings(List<String> newOtherTexts) {
    final isSupported = metadata.widgetKind == WidgetKind.multiselect;
    if (!isSupported) {
      throw PathDataException(
          'setOtherTextsAsStrings not supported for ${metadata.widgetKind}');
    }
    otherTexts = newOtherTexts;
    final validationResults = metadata.validator(otherTexts: otherTexts);
    final unsuccessful = Message.hasError(validationResults);
    _status = unsuccessful ? DataStatus.error : DataStatus.populated;
    messages = validationResults;
  }

  factory DataValue.todo(DataValue template) {
    return DataValue(
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

class SectionMetadata {
  String title;
  SectionMetadata({required this.title});
}

/// This indicates that a new section is starting
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

///This indicates that the section is ending
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
