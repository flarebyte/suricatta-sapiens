import 'package:flutter/material.dart';

import '../model/widget_model.dart';

IconData getLevelIcon(MessageLevel level) {
  switch (level) {
    case MessageLevel.error:
      return Icons.error;
    case MessageLevel.warning:
      return Icons.warning;
    case MessageLevel.info:
      return Icons.info;
    default:
      return Icons.help;
  }
}

IconData getCategoryIcon(MessageCategory category) {
  switch (category) {
    case MessageCategory.syntax:
      return Icons.code;
    case MessageCategory.spelling:
      return Icons.spellcheck;
    case MessageCategory.server:
      return Icons.cloud;
    default:
      return Icons.help;
  }
}

IconData getNavigationPathStatusIcon(DataStatus status) {
  switch (status) {
    case DataStatus.populated:
      return Icons.verified;
    case DataStatus.error:
      return Icons.error;
    case DataStatus.warning:
      return Icons.warning;
    case DataStatus.skipped:
      return Icons.skip_next;
    default:
      return Icons.help;
  }
}

Color getLevelColor(MessageLevel level) {
  switch (level) {
    case MessageLevel.error:
      return Colors.red;
    case MessageLevel.warning:
      return Colors.orange;
    case MessageLevel.info:
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getNavigationPathStatusColor(DataStatus status) {
  switch (status) {
    case DataStatus.populated:
      return Colors.blue;
    case DataStatus.error:
      return Colors.red;
    case DataStatus.warning:
      return Colors.orange;
    case DataStatus.skipped:
      return Colors.grey;
    default:
      return Colors.grey;
  }
}

Color getCategoryColor(MessageCategory category) {
  switch (category) {
    case MessageCategory.syntax:
      return Colors.purple;
    case MessageCategory.spelling:
      return Colors.green;
    case MessageCategory.server:
      return Colors.cyan;
    default:
      return Colors.grey;
  }
}
