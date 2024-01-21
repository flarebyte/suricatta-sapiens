import 'data_filter.dart';
import 'data_value.dart';
import 'data_value_collection.dart';
import 'hierarchical_identifier.dart';

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
    final template = DataValueFactory.template(
        path: path,
        metadata: metadata,
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    dataValueCollection.update(template);
  }

  addStart(String path, SectionMetadata metadata) {
    final start = DataValueFactory.start(
        path: path,
        metadata: metadata,
        rank: hierarchicalIdentifierBuilder.addChild().idAsString());
    dataValueCollection.update(start);
  }

  addEnding() {
    final ending = DataValueFactory.ending(
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

  DataValue getCurrentValue() {
    if (currentRank is String) {
      final maybeValue = findDataByRank(currentRank ?? '', DataCategory.draft);
      if (maybeValue is DataValue) {
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
    for (DataValue template in todoTemplates) {
      final todo = DataValue.todo(template);
      dataValueCollection.update(todo);
    }
  }

  setTextAsStringByRank(String newText,
      {required String rank, DataCategory category = DataCategory.draft}) {
    final previous = dataValueCollection.findByRank(rank, category);
    if (previous is DataValue) {
      previous.setTextAsString(newText);
    } else {
      throw DataNavigatorException(
          "No existing value for rank: $rank and category: $category");
    }
  }

  setTextAsStringByPath(String newText,
      {required String path, DataCategory category = DataCategory.draft}) {
    final previous = dataValueCollection.findByPath(path, category);
    if (previous is DataValue) {
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
      .whereType<DataValue>()
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
