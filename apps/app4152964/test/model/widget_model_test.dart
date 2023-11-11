import 'package:app4152964/model/widget_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuricattaDataNavigator', () {
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

    final simpleDataList = [
      contactCity,
      contactEmail,
      contactName,
      contactCountry
    ];
    test('findDataByPath returns unknown for empty data', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: [], currentRank: '');
      final actual = navigator.findDataByPath('');
      expect(actual, BasePathDataValue.unknown());
    });

    test('findDataByPath returns populated record', () {
      final navigator = SuricattaDataNavigator(
          pathDataValueList: simpleDataList, currentRank: '');
      final actual = navigator.findDataByPath('contact/name');
      expect(actual, contactName);
    });
    test('findDataByPath returns empty record', () {
      final navigator = SuricattaDataNavigator(
          pathDataValueList: simpleDataList, currentRank: '');
      final actual = navigator.findDataByPath('contact/country');
      expect(actual, contactCountry);
    });
    test('findDataByPath returns error record', () {
      final navigator = SuricattaDataNavigator(
          pathDataValueList: simpleDataList, currentRank: '');
      final actual = navigator.findDataByPath('contact/email');
      expect(actual, contactEmail);
    });
    test('findDataByRank returns unknown for empty data', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: [], currentRank: '');
      final actual = navigator.findDataByRank('');
      expect(actual, BasePathDataValue.unknown());
    });

    test('findDataByRank returns populated record', () {
      final navigator = SuricattaDataNavigator(
          pathDataValueList: simpleDataList, currentRank: '');
      final actual = navigator.findDataByRank('001:001');
      expect(actual, contactName);
    });
  });
}
