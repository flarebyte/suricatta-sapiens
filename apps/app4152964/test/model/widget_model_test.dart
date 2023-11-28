import 'package:app4152964/model/widget_model.dart';
import 'package:flutter_test/flutter_test.dart';

final contactSectionStart = BasePathDataValue.start(
  path: 'contact',
  metadata: SectionPathDataMetadata(title: 'Contact name'),
  rank: '001:--',
);
final contactSectionEnd = BasePathDataValue.ending(rank: '001:>>');
final contactNameTemplate = BasePathDataValue.template(
    path: 'contact/name',
    metadata: PathDataMetadata(
        title: 'Contact name',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:001');
final contactName = BasePathDataValue.some(
    status: DataStatus.populated,
    path: 'contact/name',
    metadata: PathDataMetadata(
        title: 'Contact name',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:001',
    draft: 'draft contact name');
final contactCityTemplate = BasePathDataValue.template(
  path: 'contact/city',
  metadata: PathDataMetadata(
      title: 'Contact city',
      widgetKind: WidgetKind.text,
      validator: (value) => []),
  rank: '001:002',
);
final contactCity = BasePathDataValue.some(
    status: DataStatus.populated,
    path: 'contact/city',
    metadata: PathDataMetadata(
        title: 'Contact city',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:002',
    draft: 'draft contact city');
final contactEmailTemplate = BasePathDataValue.template(
  path: 'contact/email',
  metadata: PathDataMetadata(
      title: 'Contact city',
      widgetKind: WidgetKind.text,
      validator: (value) => []),
  rank: '001:003',
);
final contactEmail = BasePathDataValue.some(
    status: DataStatus.error,
    path: 'contact/email',
    metadata: PathDataMetadata(
        title: 'Contact city',
        widgetKind: WidgetKind.text,
        validator: (value) => []),
    rank: '001:003',
    draft: 'draft contact email');
final contactCountryTemplate = BasePathDataValue.template(
  path: 'contact/country',
  metadata: PathDataMetadata(
      title: 'Contact country',
      widgetKind: WidgetKind.text,
      validator: (value) => []),
  rank: '001:004',
);

final contactRegionTemplate = BasePathDataValue.template(
  path: 'contact/region',
  metadata: PathDataMetadata(
      title: 'Contact region',
      widgetKind: WidgetKind.text,
      validator: (value) => []),
  rank: '001:005',
);
final contactCountry = BasePathDataValue.empty(
  path: 'contact/country',
  metadata: PathDataMetadata(
      title: 'Contact country',
      widgetKind: WidgetKind.text,
      validator: (value) => []),
  rank: '001:004',
);

final simpleDataList = [
  contactCity,
  contactEmail,
  contactName,
  contactCountry,
  contactSectionEnd,
  contactSectionStart,
  contactNameTemplate,
  contactCityTemplate,
  contactEmailTemplate,
  contactCountryTemplate,
  contactRegionTemplate
];
final contactNameMeta = PathDataMetadata(
    title: 'Contact name',
    widgetKind: WidgetKind.text,
    validator: (value) => []);

void main() {
  group('SuricattaDataNavigator', () {
    final refNavigator = SuricattaDataNavigator();
    refNavigator.setRoot();
    refNavigator.addStart('contact', SectionPathDataMetadata(title: 'Contact'));
    refNavigator.addTemplate('contact/name', contactNameMeta);
    test('findDataByPath returns unknown for empty data', () {
      final navigator = SuricattaDataNavigator();
      final actual = navigator.findDataByPath('');
      expect(actual, BasePathDataValue.unknown());
    });

    test('findDataByPath returns populated record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/name');
      expect(actual, contactName);
    });
    test('findDataByPath returns empty record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/country');
      expect(actual, contactCountry);
    });
    test('findDataByPath returns error record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByPath('contact/email');
      expect(actual, contactEmail);
    });
    test('findDataByRank returns unknown for empty data', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByRank('');
      expect(actual, BasePathDataValue.unknown());
    });

    test('findDataByRank returns populated record', () {
      final navigator = refNavigator;
      final actual = navigator.findDataByRank('001:001');
      expect(actual, contactName);
    });

    test('toRankList returns a list of rank in alphabetical order', () {
      final actual = SuricattaDataNavigator.toRankList(simpleDataList);
      expect(actual, ['001:001', '001:002', '001:003', '001:004', '001:005']);
    });

    test('first returns first record', () {
      final navigator = refNavigator;
      final actualRank = navigator.first().move().getCurrent();
      expect(actualRank, contactName);
    });

    test('last returns last record', () {
      final navigator = refNavigator;
      final actual = navigator.last().move().getCurrent();
      expect(actual, contactCountry);
    });

    test('next returns next record', () {
      final navigator = refNavigator;
      expect(navigator.first().move().getCurrentValue().rank, '001:001');
      expect(navigator.next().move().getCurrentValue().rank, '001:002');
      expect(navigator.next().move().getCurrentValue().rank, '001:003');
      expect(navigator.next().move().getCurrentValue().rank, '001:004');
      expect(navigator.next().canMove(), false);
    });

    test('previous returns previous record', () {
      final navigator = refNavigator;
      expect(navigator.last().move().getCurrentValue().rank, '001:004');
      expect(navigator.previous().move().getCurrentValue().rank, '001:003');
      expect(navigator.previous().move().getCurrentValue().rank, '001:002');
      expect(navigator.previous().move().getCurrentValue().rank, '001:001');
      expect(navigator.previous().canMove(), false);
    });

    test('firstWhere returns matching a criteria', () {
      final navigator = refNavigator;
      final actual = navigator
          .firstWhere((v) => BasePathDataValueFilter.hasRank(v, '001:003'))
          .move()
          .getCurrent();
      expect(actual, contactEmail);
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
      expect(actual, contactEmail);
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
      expect(actual, contactCity);
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
