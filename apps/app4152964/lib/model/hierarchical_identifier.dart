import 'dart:core';
import 'package:collection/collection.dart';

var deepEquality = DeepCollectionEquality();

final noneHierarchicalIdentifier = HierarchicalIdentifier([]);

class HierarchicalIdentifier {
  List<int> segments;

  HierarchicalIdentifier(this.segments);

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

  getParent() {
    if (segments.length == 0) return noneHierarchicalIdentifier;
    return HierarchicalIdentifier(segments.sublist(0, segments.length - 1));
  }

  @override
  String toString() {
    return 'HierarchicalIdentifier: ${idAsString()}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HierarchicalIdentifier &&
          runtimeType == other.runtimeType &&
          deepEquality.equals(segments, other.segments);
  @override
  int get hashCode => segments.hashCode;

  factory HierarchicalIdentifier.fromString(String id) =>
      HierarchicalIdentifier(id.split(':').map(int.parse).toList());

  factory HierarchicalIdentifier.fromParentAndChildId(
          HierarchicalIdentifier parent, int relativeId) =>
      HierarchicalIdentifier(parent.segments + [relativeId]);
}

class HierarchicalIdentifierBuilder {
  List<HierarchicalIdentifier> ids;
  HierarchicalIdentifier _current = noneHierarchicalIdentifier;

  HierarchicalIdentifier get current => _current;

  set current(HierarchicalIdentifier value) {
    _current = value;
  }

  HierarchicalIdentifierBuilder() : ids = [];

  setRoot(){
    _current = HierarchicalIdentifier([0]);
    ids.add(_current);
  }

  HierarchicalIdentifier addChildTo(String id) {
    HierarchicalIdentifier parent = ids.firstWhere(
        (h) => h == HierarchicalIdentifier.fromString(id),
        orElse: () => noneHierarchicalIdentifier);
    if (parent == null) return noneHierarchicalIdentifier;
    int max = ids
        .where((h) => h.isChildOf(parent))
        .fold(0, (m, h) => h.segments.last > m ? h.segments.last : m);
    HierarchicalIdentifier child =
        HierarchicalIdentifier.fromParentAndChildId(parent, max + 1);
    ids.add(child);
    return child;
  }

  HierarchicalIdentifier addChild() => addChildTo(_current.idAsString());

  HierarchicalIdentifier addSiblingTo(String id) {
    HierarchicalIdentifier current = ids.firstWhere(
        (h) => h == HierarchicalIdentifier.fromString(id),
        orElse: () => noneHierarchicalIdentifier);
    if (current == null) return noneHierarchicalIdentifier;
    int max = ids
        .where((h) => h.isSiblingOf(current))
        .fold(0, (m, h) => h.segments.last > m ? h.segments.last : m);
    HierarchicalIdentifier sibling =
        HierarchicalIdentifier.fromParentAndChildId(
            current.getParent(), max + 1);
    ids.add(sibling);
    return sibling;
  }

  void delete(String id) {
    HierarchicalIdentifier target = ids.firstWhere(
        (h) => h == HierarchicalIdentifier.fromString(id),
        orElse: () => noneHierarchicalIdentifier);
    if (target == null) return;
    ids.removeWhere((h) => h == target || h.isChildOf(target));
  }
}
