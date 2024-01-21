import 'data_value.dart';

class DataPreview {
  String text;
  DataPreview({required this.text});
}


class NavigationPath {
  String path;
  String title;
  String preview;
  DataStatus status;

  NavigationPath(this.path, this.title, this.preview, this.status);
}
