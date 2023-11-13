import 'package:app4152964/model/widget_model.dart';
import 'package:flutter_test/flutter_test.dart';

final contactName = BasePathDataValue.some(
    status: DataStatus.populated,
    path: 'contact/name',
    metadata: PathDataMetadata(
        title: 'Contact name',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:001',
    draft: 'draft contact name');
final contactCity = BasePathDataValue.some(
    status: DataStatus.populated,
    path: 'contact/city',
    metadata: PathDataMetadata(
        title: 'Contact city',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:002',
    draft: 'draft contact city');
final contactEmail = BasePathDataValue.some(
    status: DataStatus.error,
    path: 'contact/email',
    metadata: PathDataMetadata(
        title: 'Contact city',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:003',
    draft: 'draft contact email');
final contactCountry = BasePathDataValue.empty(
  path: 'contact/country',
  metadata: PathDataMetadata(
      title: 'Contact country',
      widgetKind: WidgetKind.text,
      validator: (value) => []),
  rank: '001:004',
);

final simpleDataList = [contactCity, contactEmail, contactName, contactCountry];

void main() {
  group('SuricattaDataNavigator', () {
    test('findDataByPath returns unknown for empty data', () {
      final navigator = SuricattaDataNavigator(pathDataValueList: []);
      final actual = navigator.findDataByPath('');
      expect(actual, BasePathDataValue.unknown());
    });

    test('findDataByPath returns populated record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      final actual = navigator.findDataByPath('contact/name');
      expect(actual, contactName);
    });
    test('findDataByPath returns empty record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      final actual = navigator.findDataByPath('contact/country');
      expect(actual, contactCountry);
    });
    test('findDataByPath returns error record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      final actual = navigator.findDataByPath('contact/email');
      expect(actual, contactEmail);
    });
    test('findDataByRank returns unknown for empty data', () {
      final navigator = SuricattaDataNavigator(pathDataValueList: []);
      final actual = navigator.findDataByRank('');
      expect(actual, BasePathDataValue.unknown());
    });

    test('findDataByRank returns populated record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      final actual = navigator.findDataByRank('001:001');
      expect(actual, contactName);
    });

    test('toRankList returns a list of rank in alphabetical order', () {
      final actual = SuricattaDataNavigator.toRankList(simpleDataList);
      expect(actual, ['001:001', '001:002', '001:003', '001:004']);
    });

    test('first returns first record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      final actualRank = navigator.first().move().getCurrent();
      expect(actualRank, contactName);
    });

    test('last returns last record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      final actual = navigator.last().move().getCurrent();
      expect(actual, contactCountry);
    });

    test('next returns next record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      expect(navigator.first().move().getCurrentValue().rank, '001:001');
      expect(navigator.next().move().getCurrentValue().rank, '001:002');
      expect(navigator.next().move().getCurrentValue().rank, '001:003');
      expect(navigator.next().move().getCurrentValue().rank, '001:004');
      expect(navigator.next().canMove(), false);
    });

    test('previous returns previous record', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: simpleDataList);
      expect(navigator.last().move().getCurrentValue().rank, '001:004');
      expect(navigator.previous().move().getCurrentValue().rank, '001:003');
      expect(navigator.previous().move().getCurrentValue().rank, '001:002');
      expect(navigator.previous().move().getCurrentValue().rank, '001:001');
      expect(navigator.previous().canMove(), false);
    });
  });
  group('BasePathDataValueFilter', () {
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
      expect(BasePathDataValueFilter.hasStatus(contactName, DataStatus.empty),
          false);
    });

    test('hasAnyStatus should match if any status matching', () {
      expect(
          BasePathDataValueFilter.hasAnyStatus(
              contactName, [DataStatus.empty, DataStatus.populated]),
          true);
    });

    test('hasAnyStatus should not match if no status matching', () {
      expect(
          BasePathDataValueFilter.hasAnyStatus(
              contactName, [DataStatus.empty, DataStatus.skipped]),
          false);
    });
  });
}
