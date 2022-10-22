import 'package:klc/klc.dart';

void main() {
  // param : year(년), month(월), day(일)
  setSolarDate(2022, 7, 10);

  // Lunar Date (ISO format)
  final lunar = getLunarIsoFormat();
  print(lunar);

  // Korean GapJa String
  final lunarGapja = getGapjaString();
  print(lunarGapja);

  // Chinese GapJa String
  final lunarChineseGapja = getChineseGapJaString();
  print(lunarChineseGapja);

  // just a line space
  print("");

  // param : year(년), month(월), day(일), intercalation(윤달여부)
  setLunarDate(2022, 6, 12, false);

  // Solar Date (ISO format)
  final solar = getSolarIsoFormat();
  print(solar);
}
