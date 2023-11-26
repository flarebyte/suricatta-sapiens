import 'package:app4152964/model/hierarchical_identifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HierarchicalIdentifier', ()
  {
    test(
        'should parse and format a string correctly', () {
      final id = HierarchicalIdentifier('001:002:003');
      expect(id.idAsString(), '001:002:003');
    });

    test(
        'should recognize a parent-child relationship', () {
      final parent = HierarchicalIdentifier('001:002');
      final child = HierarchicalIdentifier('001:002:003');
      expect(parent.isParentOf(child), true);
      expect(child.isParentOf(parent), false);
    });

    test(
        'should recognize a child-parent relationship', () {
      final parent = HierarchicalIdentifier('001:002');
      final child = HierarchicalIdentifier('001:002:003');
      expect(child.isChildOf(parent), true);
      expect(parent.isChildOf(child), false);
    });

    test('should recognize a sibling relationship', () {
      final sibling1 = HierarchicalIdentifier('001:002:003');
      final sibling2 = HierarchicalIdentifier('001:002:004');
      final nonSibling = HierarchicalIdentifier('001:003:003');
      expect(sibling1.isSiblingOf(sibling2), true);
      expect(sibling2.isSiblingOf(sibling1), true);
      expect(sibling1.isSiblingOf(nonSibling), false);
      expect(nonSibling.isSiblingOf(sibling1), false);
    });

    test('should recognize an equal relationship', () {
      final id1 = HierarchicalIdentifier('001:002:003');
      final id2 = HierarchicalIdentifier('001:002:003');
      final id3 = HierarchicalIdentifier('001:002:004');
      expect(id1.isEqualTo(id2), true);
      expect(id2.isEqualTo(id1), true);
      expect(id1.isEqualTo(id3), false);
      expect(id3.isEqualTo(id1), false);
    });
  });
}
