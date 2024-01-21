import 'dart:collection';

import 'data_filter.dart';
import 'data_value.dart';

class DataValueCollection {
  SplayTreeMap<String, BaseDataValue> pathDataValueMap =
  SplayTreeMap<String, BaseDataValue>((a, b) => a.compareTo(b));
  update(BaseDataValue added) {
    pathDataValueMap.update(added.composedRank, (v) => added,
        ifAbsent: () => added);
  }

  List<String> toRankList() => pathDataValueMap.values
      .whereType<DataValue>()
      .map((value) => value.rank)
      .toSet()
      .toList()
    ..sort();

  List<String> toActiveRankList() => pathDataValueMap.values
      .whereType<DataValue>()
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
        .firstWhere(where, orElse: () => DataValueFactory.ending(rank: ''));
    return result.rank == '' ? null : result;
  }

  Iterable<DataValue> findAllByCategory(DataCategory category) =>
      pathDataValueMap.values
          .whereType<DataValue>()
          .where((item) => DataFilter.hasCategory(item, DataCategory.template));
}
