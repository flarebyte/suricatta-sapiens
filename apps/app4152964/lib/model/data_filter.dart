import 'data_value.dart';

class DataFilter {
  static bool hasPath(BaseDataValue value, String searchPath) {
    return switch (value) {
      DataValue(path: var valuePath) => valuePath == searchPath,
      StartingSection(path: var valuePath) => valuePath == searchPath,
      EndingSection() => false,
    };
  }

  static bool hasRank(BaseDataValue value, String searchRank) {
    return switch (value) {
      DataValue(rank: var valueRank) => valueRank == searchRank,
      StartingSection(rank: var valueRank) => valueRank == searchRank,
      EndingSection(rank: var valueRank) => valueRank == searchRank
    };
  }

  static bool hasStatus(BaseDataValue value, DataStatus searchStatus) {
    return switch (value) {
      DataValue(status: var valueStatus) => valueStatus == searchStatus,
      StartingSection(status: var valueStatus) => valueStatus == searchStatus,
      EndingSection(status: var valueStatus) => valueStatus == searchStatus,
    };
  }

  static bool hasCategory(BaseDataValue value, DataCategory searchCategory) {
    return switch (value) {
      DataValue(category: var valueCategory) =>
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
      DataValue(status: var valueStatus) =>
          searchStatusList.contains(valueStatus),
      StartingSection(status: var valueStatus) =>
          searchStatusList.contains(valueStatus),
      EndingSection(status: var valueStatus) =>
          searchStatusList.contains(valueStatus)
    };
  }
}
