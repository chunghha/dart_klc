<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

A Dart library to convert a date to Korean lunar calendar date.

## ChangeLog

[ChangeLog.md](CHANGELOG.md)


### Overview
Here is a library to convert Korean lunar-calendar to Gregorian calendar in Dart.

Korean and Chinese lunar-calendars are not always same.

The conversion in this package is written per the Gregorian calendar of KARI(Korea Astronomy and Space Science Institute) - https://astro.kasi.re.kr/life/pageView/8

한국 양음력 변환 (한국천문연구원 기준) - 네트워크 연결 불필요

음력 변환은 1391년 1월 1일 부터 2050년 11월 18일까지 지원

````
Gregorian calendar (1391. 2. 5. ~ 2050. 12. 31) <--> Korean lunar-calendar (1391. 1. 1. ~ 2050. 11. 18)
````

## Getting Started

Add the following to your **pubspec.yaml**:

```
dependencies:
  klc: "^0.1.0"
```

then run **pub install**.

Next, import dart-klc:

```
import 'package:klc/klc.dart';
```

### Example

1. 양력 2022년 7월 10일을 음력으로 변환
```Dart
import 'package:sprintf/sprintf.dart';

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
}
```
[Result]
```
2022-06-12
임인년 정미월 갑자일
壬寅年 丁未月 甲子日
```

2. 음력 2022년 6월 12일을 양력으로 변환
```Dart
  // param : year(년), month(월), day(일), intercalation(윤달여부)
  setLunarDate(2022, 6, 12, false);

  // Solar Date (ISO format)
  final solar = getSolarIsoFormat();
  print(solar);
```

[Result]
```
2022-07-10
```


**CREDIT**

Klc Dart package is ported from this Go package:

[go-klc](https://github.com/chunghha/go-klc)

Thanks for the original Java code here which is now converted in Go:

[KoreanLunarCalendar](https://github.com/usingsky/KoreanLunarCalendar)
