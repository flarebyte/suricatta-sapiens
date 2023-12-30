import 'package:app4152964/model/widget_model.dart';
import 'package:flutter_test/flutter_test.dart';

final contactNameMeta = DataMetadata(
    title: 'Contact name',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactCityMeta = DataMetadata(
    title: 'Contact city',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactCountryMeta = DataMetadata(
    title: 'Contact country',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactRegionMeta = DataMetadata(
    title: 'Contact region',
    widgetKind: WidgetKind.text,
    validator: (value) => []);
final contactEmailMeta = DataMetadata(
    title: 'Contact email',
    widgetKind: WidgetKind.text,
    validator: (value) {
      if (value is String) {
        if (value.contains('@')) {
          return [];
        }
      }
      return [
        Message('Incorrect email', MessageLevel.error, MessageCategory.syntax)
      ];
    });

void main() {
  group('SuricattaDataNavigator', () {
    final refNavigator = DataNavigator();
    refNavigator.setRoot();
    refNavigator.addStart('contact', SectionMetadata(title: 'Contact'));
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
      if (actual is! BaseDataValue) {
        fail('No data at path');
      }
      expect(actual.text, 'draft contact name');
      expect(actual.status, DataStatus.populated);
    });
    test('findDataByPath returns error record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/email');
      if (actual is! BaseDataValue) {
        fail('No data at path');
      }
      expect(actual.status, DataStatus.error);
      expect(actual.messages.length, 1);
    });

    test('findDataByRank returns populated record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/name');
      if (actual is! BaseDataValue) {
        fail('No data at path');
      }
      final actualByRank = navigator.findDataByRank(actual.rank);
      if (actualByRank is! BaseDataValue) {
        fail('No data at rank ${actual.rank}');
      }
      expect(actualByRank.text, 'draft contact name');
      expect(actualByRank.status, DataStatus.populated);
    });

    test('first returns first record', () {
      final navigator = refNavigator;
      final actualRank = navigator.first().move().getCurrent();
      expect(actualRank.path, 'contact/name');
    });

    test('You should not be able to go before first record', () {
      final navigator = refNavigator;
      navigator.first().move();
      navigator.previous();
      expect(navigator.canMove(), false);
    });

    test('last returns last record', () {
      final navigator = refNavigator;
      final actual = navigator.last().move().getCurrent();
      expect(actual.path, 'contact/email');
    });

    test('You should not be able to go after last record', () {
      final navigator = refNavigator;
      navigator.last().move();
      navigator.next();
      expect(navigator.canMove(), false);
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
      expect(
          navigator.previous().move().getCurrentValue().path, 'contact/region');
      expect(navigator.previous().move().getCurrentValue().path,
          'contact/country');
      expect(
          navigator.previous().move().getCurrentValue().path, 'contact/city');
    });

    test('firstWhere returns matching a criteria', () {
      final navigator = refNavigator;
      final actual = navigator
          .firstWhere((v) => DataFilter.hasPath(v, 'contact/email'))
          .move()
          .getCurrent();
      expect(actual.path, 'contact/email');
    });

    test('change current value', () {
      final navigator = refNavigator;
      navigator
          .firstWhere((v) => DataFilter.hasPath(v, 'contact/region'))
          .move();
      navigator.setCurrentText('new region');
      expect(navigator.getCurrentValue().text, 'new region');
    });

    test('firstWhere should deal gracefully with no result', () {
      final navigator = refNavigator;
      final actual =
          navigator.firstWhere((v) => DataFilter.hasRank(v, '001:111'));
      expect(actual.canMove(), false);
    });

    test('nextWhere returns matching a criteria', () {
      final navigator = refNavigator;
      final actual = navigator
          .nextWhere((v) => DataFilter.hasStatus(v, DataStatus.error))
          .move()
          .getCurrent();
      expect(actual.path, 'contact/email');
    });

    test('nextWhere returns matching a criteria after first', () {
      final navigator = refNavigator;
      final actual = navigator
          .first()
          .move()
          .nextWhere((v) => DataFilter.hasStatus(v, DataStatus.populated))
          .move()
          .getCurrent();
      expect(actual.path, 'contact/city');
    });
  });
  group('BasePathDataValueFilter', () {
    final contactName = PathDataValue(
        status: DataStatus.populated,
        viewStatus: ViewStatus.full,
        path: 'contact/name',
        metadata: contactNameMeta,
        rank: '001:001',
        category: DataCategory.draft);
    test('hasPath should match if same path', () {
      expect(DataFilter.hasPath(contactName, 'contact/name'), true);
    });

    test('hasPath should not match if path are different', () {
      expect(DataFilter.hasPath(contactName, 'contact/whatever'), false);
    });

    test('hasRank should match if same rank', () {
      expect(DataFilter.hasRank(contactName, '001:001'), true);
    });

    test('hasRank should not match if rank are different', () {
      expect(DataFilter.hasPath(contactName, '001:111'), false);
    });

    test('hasStatus should match if same status', () {
      expect(DataFilter.hasStatus(contactName, DataStatus.populated), true);
    });

    test('hasStatus should not match if status are different', () {
      expect(DataFilter.hasStatus(contactName, DataStatus.error), false);
    });

    test('hasAnyStatus should match if any status matching', () {
      expect(
          DataFilter.hasAnyStatus(
              contactName, [DataStatus.todo, DataStatus.populated]),
          true);
    });

    test('hasAnyStatus should not match if no status matching', () {
      expect(
          DataFilter.hasAnyStatus(
              contactName, [DataStatus.todo, DataStatus.error]),
          false);
    });
  });
}
