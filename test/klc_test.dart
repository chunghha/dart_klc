import 'package:klc/klc.dart';
import 'package:test/test.dart';

void main() {
  group('A group of klc tests', () {
    setUp(() {
      //
    });

    test('getLunarIsoFormat() should return a valid lunarDate in ISO format', () {
      // param : year(년), month(월), day(일)
      setSolarDate(2022, 7, 10);

      final lunar = getLunarIsoFormat();

      expect(lunar, '2022-06-12');
    });

    test('getLunarIsoFormat() should return a valid lunarDate in ISO format', () {
      // param : year(년), month(월), day(일), intercalation(윤달여부)
      setLunarDate(2022, 6, 12, false);

      final solar = getSolarIsoFormat();

      expect(solar, '2022-07-10');
    });
  });
}
