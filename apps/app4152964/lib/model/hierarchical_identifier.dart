import 'dart:core';

class HierarchicalIdentifier {
  List<int> segments;

  HierarchicalIdentifier(String id)
      : segments = id.split(':').map(int.parse).toList();

  String idAsString() {
    return segments.map((s) => s.toString().padLeft(3, '0')).join(':');
  }

  isParentOf(HierarchicalIdentifier other) {
    if (segments.length >= other.segments.length) return false;
    for (int i = 0; i < segments.length; i++) {
      if (segments[i] != other.segments[i]) return false;
    }
    return true;
  }

  isChildOf(HierarchicalIdentifier other) {
    return other.isParentOf(this);
  }

  isSiblingOf(HierarchicalIdentifier other) {
    if (segments.length != other.segments.length) return false;
    for (int i = 0; i < segments.length - 1; i++) {
      if (segments[i] != other.segments[i]) return false;
    }
    return true;
  }

  isEqualTo(HierarchicalIdentifier other) {
    if (segments.length != other.segments.length) return false;
    for (int i = 0; i < segments.length; i++) {
      if (segments[i] != other.segments[i]) return false;
    }
    return true;
  }

  @override
  String toString() {
    return 'HierarchicalIdentifier: ${idAsString()}';
  }
}

final noneHierarchicalIdentifier = HierarchicalIdentifier('000');

class HierarchicalIdentifierBuilder {
  List<HierarchicalIdentifier> ids;

  HierarchicalIdentifierBuilder() : ids = [];

  HierarchicalIdentifier addChildTo(String id) {
    HierarchicalIdentifier parent = ids.firstWhere(
        (h) => h.isEqualTo(HierarchicalIdentifier(id)),
        orElse: () => noneHierarchicalIdentifier);
    if (parent == null) return noneHierarchicalIdentifier;
    int max = ids
        .where((h) => h.isChildOf(parent))
        .fold(0, (m, h) => h.segments.last > m ? h.segments.last : m);
    HierarchicalIdentifier child =
        HierarchicalIdentifier(id + ':' + (max + 1).toString());
    ids.add(child);
    return child;
  }

  HierarchicalIdentifier addSiblingTo(String id) {
    HierarchicalIdentifier current = ids.firstWhere(
        (h) => h.isEqualTo(HierarchicalIdentifier(id)),
        orElse: () => noneHierarchicalIdentifier);
    if (current == null) return noneHierarchicalIdentifier;
    int max = ids
        .where((h) => h.isSiblingOf(current))
        .fold(0, (m, h) => h.segments.last > m ? h.segments.last : m);
    HierarchicalIdentifier sibling = HierarchicalIdentifier(
        current.segments.sublist(0, current.segments.length - 1).join(':') +
            ':' +
            (max + 1).toString());
    ids.add(sibling);
    return sibling;
  }

  void delete(String id) {
    HierarchicalIdentifier target = ids.firstWhere(
        (h) => h.isEqualTo(HierarchicalIdentifier(id)),
        orElse: () => noneHierarchicalIdentifier);
    if (target == null) return;
    ids.removeWhere((h) => h.isEqualTo(target) || h.isChildOf(target));
  }
}
