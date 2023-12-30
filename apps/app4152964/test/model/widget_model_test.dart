import 'package:app4152964/model/widget_model.dart';
import 'package:flutter_test/flutter_test.dart';

final contactNameMeta = PathDataMetadata(
    title: 'Contact name',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactCityMeta = PathDataMetadata(
    title: 'Contact city',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactCountryMeta = PathDataMetadata(
    title: 'Contact country',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactRegionMeta = PathDataMetadata(
    title: 'Contact region',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactEmailMeta = PathDataMetadata(
    title: 'Contact email',
    widgetKind: WidgetKind.text,
    validator: (value) {
      if (value is String) {
        if (value.contains('@')) {
          return [];
        }
      }
      return [Message('', Level.error, Category.syntax)];
    });

void main() {
  group('SuricattaDataNavigator', () {
    final refNavigator = SuricattaDataNavigator();
    refNavigator.setRoot();
    refNavigator.addStart('contact', SectionPathDataMetadata(title: 'Contact'));
    refNavigator.addTemplate('contact/name', contactNameMeta);
    refNavigator.addTemplate('contact/city', contactCityMeta);
    refNavigator.addTemplate('contact/country', contactCountryMeta);
    refNavigator.addTemplate('contact/region', contactRegionMeta);
    refNavigator.addTemplate('contact/email', contactEmailMeta);
    refNavigator.addEnding();
    refNavigator.createRootTodos();
    refNavigator.setTextAsStringByPath('draft contact name',
        path: 'contact/name');
    refNavigator.setTextAsStringByPath('draft contact city',
        path: 'contact/city');
    refNavigator.setTextAsStringByPath('draft contact region',
        path: 'contact/region');
    refNavigator.setTextAsStringByPath('draft contact email',
        path: 'contact/email');
    refNavigator.setTextAsStringByPath('draft contact country',
        path: 'contact/country');

    test('count returns the number of records', () {
      final navigator = refNavigator;
      expect(navigator.count(), 12);
      expect(navigator.countByCategory(DataCategory.starting), 1);
      expect(navigator.countByCategory(DataCategory.ending), 1);
      expect(navigator.countByCategory(DataCategory.template), 5);
      expect(navigator.countByCategory(DataCategory.draft), 5);
    });

    test('findDataByPath returns populated record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/name');
      expect(actual.text, 'draft contact name');
      expect(actual.status, DataStatus.populated);
    });
    test('findDataByPath returns error record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/email');
      expect(actual.status, DataStatus.error);
    });

    test('findDataByRank returns populated record', () {
      final navigator = refNavigator;
      final rank = navigator.findDataByPath('contact/name').rank;
      final actual = navigator.findDataByRank(rank);
      expect(actual.text, 'draft contact name');
      expect(actual.status, DataStatus.populated);
    });

    test('first returns first record', () {
      final navigator = refNavigator;
      final actualRank = navigator.first().move().getCurrent();
      expect(actualRank.path, 'contact/name');
    });

    test('last returns last record', () {
      final navigator = refNavigator;
      final actual = navigator.last().move().getCurrent();
      expect(actual.path, 'contact/email');
    });

    test('next returns next record', () {
      final navigator = refNavigator;
      expect(navigator.first().move().getCurrentValue().path, 'contact/name');
      expect(navigator.next().move().getCurrentValue().path, 'contact/city');
      expect(navigator.next().move().getCurrentValue().path, 'contact/country');
    });

    test('previous returns previous record', () {
      final navigator = refNavigator;
      expect(navigator.last().move().getCurrentValue().path, 'contact/email');
      expect(navigator.previous().move().getCurrentValue().path, 'contact/region');
      expect(navigator.previous().move().getCurrentValue().path, 'contact/country');
      expect(navigator.previous().move().getCurrentValue().path, 'contact/city');
    });

    test('firstWhere returns matching a criteria', () {
      final navigator = refNavigator;
      final actual = navigator
          .firstWhere(
              (v) => BasePathDataValueFilter.hasPath(v, 'contact/email'))
          .move()
          .getCurrent();
      expect(actual.path, 'contact/email');
    });

    test('firstWhere should deal gracefully with no result', () {
      final navigator = refNavigator;
      final actual = navigator
          .firstWhere((v) => BasePathDataValueFilter.hasRank(v, '001:111'));
      expect(actual.canMove(), false);
    });

    test('nextWhere returns matching a criteria', () {
      final navigator = refNavigator;
      final actual = navigator
          .nextWhere(
              (v) => BasePathDataValueFilter.hasStatus(v, DataStatus.error))
          .move()
          .getCurrent();
      expect(actual.path, 'contact/email');
    });

    test('nextWhere returns matching a criteria after first', () {
      final navigator = refNavigator;
      final actual = navigator
          .first()
          .move()
          .nextWhere(
              (v) => BasePathDataValueFilter.hasStatus(v, DataStatus.populated))
          .move()
          .getCurrent();
      expect(actual.path, 'contact/city');
    });
  });
  group('BasePathDataValueFilter', () {
    final contactName = PathDataValue(
        status: DataStatus.populated,
        path: 'contact/name',
        metadata: contactNameMeta,
        rank: '001:001',
        category: DataCategory.draft);
    test('hasPath should match if same path', () {
      expect(
          BasePathDataValueFilter.hasPath(contactName, 'contact/name'), true);
    });

    test('hasPath should not match if path are different', () {
      expect(BasePathDataValueFilter.hasPath(contactName, 'contact/whatever'),
          false);
    });

    test('hasRank should match if same rank', () {
      expect(BasePathDataValueFilter.hasRank(contactName, '001:001'), true);
    });

    test('hasRank should not match if rank are different', () {
      expect(BasePathDataValueFilter.hasPath(contactName, '001:111'), false);
    });

    test('hasStatus should match if same status', () {
      expect(
          BasePathDataValueFilter.hasStatus(contactName, DataStatus.populated),
          true);
    });

    test('hasStatus should not match if status are different', () {
      expect(BasePathDataValueFilter.hasStatus(contactName, DataStatus.error),
          false);
    });

    test('hasAnyStatus should match if any status matching', () {
      expect(
          BasePathDataValueFilter.hasAnyStatus(
              contactName, [DataStatus.todo, DataStatus.populated]),
          true);
    });

    test('hasAnyStatus should not match if no status matching', () {
      expect(
          BasePathDataValueFilter.hasAnyStatus(
              contactName, [DataStatus.todo, DataStatus.skipped]),
          false);
    });
  });
}
