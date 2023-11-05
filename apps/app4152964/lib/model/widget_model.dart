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

class GenericPathDataMeta {
  String genericPath;
  String title;
  WidgetKind widgetKind;
  List<Message> Function(String?) validator;
  GenericPathDataMeta(
      this.genericPath, this.title, this.widgetKind, this.validator);
}

class DataPreview {
  String text;
  DataPreview({required this.text});
}

class PathDataValue {
  String path;
  String genericPath;
  String draft;
  String loaded;
  String refreshed;
  DataPreview preview;
  DataStatus status;

  PathDataValue(
      {required this.path,
      required this.genericPath,
      required this.draft,
      required this.loaded,
      required this.refreshed,
      required this.preview,
      required this.status});
}

class SuricattaDataNavigator {
  List<GenericPathDataMeta> genericMetaList;
  List<PathDataValue> pathDataValueList;
  String currentPath;
  SuricattaDataNavigator(
      this.genericMetaList, this.pathDataValueList, this.currentPath);

  findDataByPath(String path) {
    return pathDataValueList.firstWhere(
      (item) => item.path == path,
      orElse: () => PathDataValue(
          path: path,
          genericPath: '',
          draft: '',
          loaded: '',
          refreshed: '',
          preview: DataPreview(text: ''),
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
