import 'package:app4152964/model/widget_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuricattaDataNavigator', () {
    test('findDataByPath returns unknown for empty data', () {
      final navigator =
          SuricattaDataNavigator(pathDataValueList: [], currentRank: '');
      final actual = navigator.findDataByPath('');
      expect(actual, BasePathDataValue.unknown());
    });
  });
}
