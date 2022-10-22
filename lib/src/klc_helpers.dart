import 'package:klc/klc.dart';
import 'package:sprintf/sprintf.dart';

int getLunarData(int year) {
  return KOREAN_LUNAR_DATA[year - KOREAN_LUNAR_BASE_YEAR];
}

int getLunarIntercalationMonth(int lunarData) {
  return (lunarData >> 12) & 0x000F;
}

int shiftLunarDays(int year) {
  var lunarData = getLunarData(year);

  return (lunarData >> 17) & 0x01FF;
}

int getLunarDays(int year, int month, bool isIntercalation) {
  var days = 0;
  var lunarData = getLunarData(year);

  if (isIntercalation && getLunarIntercalationMonth(lunarData) == month) {
    if (((lunarData >> 16) & 0x01) > 0) {
      days = LUNAR_BIG_MONTH_DAY;
    } else {
      days = LUNAR_SMALL_MONTH_DAY;
    }
  } else {
    if (((lunarData >> (12 - month)) & 0x01) > 0) {
      days = LUNAR_BIG_MONTH_DAY;
    } else {
      days = LUNAR_SMALL_MONTH_DAY;
    }
  }

  return days;
}

int getLunarDaysBeforeBaseYear(int year) {
  var days = 0;

  for (int baseYear = KOREAN_LUNAR_BASE_YEAR; baseYear < year + 1; baseYear++) {
    days += shiftLunarDays(baseYear);
  }
  return days;
}

int getLunarDaysBeforeBaseMonth(int year, int month, bool isIntercalation) {
  var days = 0;

  if (year >= KOREAN_LUNAR_BASE_YEAR && month > 0) {
    for (int baseMonth = 1; baseMonth < month + 1; baseMonth++) {
      days += getLunarDays(year, baseMonth, false);
    }

    if (isIntercalation) {
      final intercalationMonth = getLunarIntercalationMonth(getLunarData(year));

      if (intercalationMonth > 0 && intercalationMonth < month + 1) {
        days += getLunarDays(year, intercalationMonth, true);
      }
    }
  }

  return days;
}

int getLunarAbsDays(int year, int month, int day, bool isIntercalation) {
  var days = getLunarDaysBeforeBaseYear(year - 1) + getLunarDaysBeforeBaseMonth(year, month - 1, true) + day;

  if (isIntercalation && getLunarIntercalationMonth(getLunarData(year)) == month) {
    days += getLunarDays(year, month, false);
  }

  return days;
}

bool isSolarIntercalationYear(int lunarData) {
  return ((lunarData >> 30) & 0x01) > 0;
}

int shiftSolarDays(int year) {
  var days = 0;
  final lunarData = getLunarData(year);

  if (isSolarIntercalationYear(lunarData)) {
    days = SOLAR_BIG_YEAR_DAY;
  } else {
    days = SOLAR_SMALL_YEAR_DAY;
  }

  if (year == 1582) {
    days -= 10;
  }

  return days;
}

int getSolarDays(int year, int month) {
  var days = 0;
  final lunarData = getLunarData(year);

  if (month == 2 && isSolarIntercalationYear(lunarData)) {
    days = SOLAR_DAYS[12];
  } else {
    days = SOLAR_DAYS[month - 1];
  }

  if (year == 1582 && month == 10) {
    days -= 10;
  }

  return days;
}

int getSolarDayBeforeBaseYear(int year) {
  var days = 0;

  for (int baseYear = KOREAN_LUNAR_BASE_YEAR; baseYear < year + 1; baseYear++) {
    days += shiftSolarDays(baseYear);
  }

  return days;
}

int getSolarDaysBeforeBaseMonth(int year, int month) {
  var days = 0;

  for (int baseMonth = 1; baseMonth < month + 1; baseMonth++) {
    days += getSolarDays(year, baseMonth);
  }

  return days;
}

int getSolarAbsDays(int year, int month, int day) {
  var days = getSolarDayBeforeBaseYear(year - 1) + getSolarDaysBeforeBaseMonth(year, month - 1) + day;
  days -= SOLAR_LUNAR_DAY_DIFF;

  return days;
}

void setSolarDateByLunarDate(int lunarYear, int lunarMonth, int lunarDay, bool isIntercalation) {
  var absDays = getLunarAbsDays(lunarYear, lunarMonth, lunarDay, isIntercalation);

  if (absDays < getSolarAbsDays(lunarYear + 1, 1, 1)) {
    solarYear = lunarYear;
  } else {
    solarYear = lunarYear + 1;
  }

  for (int month = 12; month > 0; month--) {
    var absDaysByMonth = getSolarAbsDays(solarYear, month, 1);

    if (absDays >= absDaysByMonth) {
      solarMonth = month;
      solarDay = absDays - absDaysByMonth + 1;

      break;
    }
  }

  if (solarYear == 1582 && solarMonth == 10 && solarDay > 4) {
    solarDay += 10;
  }
}

void setLunarDateBySolarDate(int solarYear, int solarMonth, int solarDay) {
  var absDays = getSolarAbsDays(solarYear, solarMonth, solarDay);

  var isIntercalation = false;

  if (absDays >= getLunarAbsDays(solarYear, 1, 1, false)) {
    lunarYear = solarYear;
  } else {
    lunarYear = solarYear - 1;
  }

  for (int month = 12; month > 0; month--) {
    var absDaysByMonth = getLunarAbsDays(lunarYear, month, 1, false);

    if (absDays >= absDaysByMonth) {
      lunarMonth = month;

      if (getLunarIntercalationMonth(getLunarData(lunarYear)) == month) {
        isIntercalation = absDays >= getLunarAbsDays(lunarYear, month, 1, true);
      }

      lunarDay = absDays - getLunarAbsDays(lunarYear, lunarMonth, 1, isIntercalation) + 1;

      break;
    }
  }
}

bool isValidMin(bool isLunar, int dateValue) {
  if (isLunar) {
    return KOREAN_LUNAR_MIN_VALUE <= dateValue;
  } else {
    return KOREAN_SOLAR_MIN_VALUE <= dateValue;
  }
}

bool isValidMax(bool isLunar, int dateValue) {
  if (isLunar) {
    return KOREAN_LUNAR_MAX_VALUE >= dateValue;
  } else {
    return KOREAN_SOLAR_MAX_VALUE >= dateValue;
  }
}

bool checkValidDate(bool isLunar, bool isIntercalation, int year, int month, int day) {
  var isValid = false;
  var dateValue = year * 10000 + month * 100 + day;

  //1582. 10. 5 ~ 1582. 10. 14 is not enable
  if (isValidMin(isLunar, dateValue) && isValidMax(isLunar, dateValue)) {
    var dayLimit = 0;

    if (month > 0 && month < 13 && day > 0) {
      if (isLunar) {
        dayLimit = getLunarDays(year, month, isIntercalation);
      } else {
        dayLimit = getSolarDays(year, month);
      }

      if (!isLunar && year == 1582 && month == 10) {
        if (day > 4 && day < 15) {
          return false;
        } else {
          dayLimit += 10;
        }
      }

      if (day <= dayLimit) {
        isValid = true;
      }
    }
  }

  return isValid;
}

bool setLunarDate(int lunarYear, int lunarMonth, int lunarDay, bool isIntercalation) {
  var isValid = false;

  if (checkValidDate(true, isIntercalation, lunarYear, lunarMonth, lunarDay)) {
    isIntercalation = isIntercalation && (getLunarIntercalationMonth(getLunarData(lunarYear)) == lunarMonth);
    setSolarDateByLunarDate(lunarYear, lunarMonth, lunarDay, isIntercalation);
    isValid = true;
  }

  return isValid;
}

bool setSolarDate(int solarYear, int solarMonth, int solarDay) {
  var isValid = false;

  if (checkValidDate(false, false, solarYear, solarMonth, solarDay)) {
    setLunarDateBySolarDate(solarYear, solarMonth, solarDay);
    isValid = true;
  }

  return isValid;
}

getGapJa() {
  var absDays = getLunarAbsDays(lunarYear, lunarMonth, lunarDay, isIntercalation);

  if (absDays > 0) {
    gapjaYearInx[0] = ((lunarYear + 7) - KOREAN_LUNAR_BASE_YEAR) % KOREAN_CHEONGAN.length;
    gapjaYearInx[1] = ((lunarYear + 7) - KOREAN_LUNAR_BASE_YEAR) % KOREAN_GANJI.length;

    var monthCount = lunarMonth;
    monthCount += 12 * (lunarYear - KOREAN_LUNAR_BASE_YEAR);
    gapjaMonthInx[0] = (monthCount + 5) % KOREAN_CHEONGAN.length;
    gapjaMonthInx[1] = (monthCount + 1) % KOREAN_GANJI.length;

    gapjaDayInx[0] = (absDays + 4) % KOREAN_CHEONGAN.length;
    gapjaDayInx[1] = absDays % KOREAN_GANJI.length;
  }
}

String getGapjaString() {
  getGapJa();

  var gapjaString = "";
  gapjaString += String.fromCharCode(KOREAN_CHEONGAN[gapjaYearInx[0]]);
  gapjaString += String.fromCharCode(KOREAN_GANJI[gapjaYearInx[1]]);
  gapjaString += String.fromCharCode(KOREAN_GAPJA_UNIT[gapjaYearInx[2]]);
  gapjaString += " ";
  gapjaString += String.fromCharCode(KOREAN_CHEONGAN[gapjaMonthInx[0]]);
  gapjaString += String.fromCharCode(KOREAN_GANJI[gapjaMonthInx[1]]);
  gapjaString += String.fromCharCode(KOREAN_GAPJA_UNIT[gapjaMonthInx[2]]);
  gapjaString += " ";
  gapjaString += String.fromCharCode(KOREAN_CHEONGAN[gapjaDayInx[0]]);
  gapjaString += String.fromCharCode(KOREAN_GANJI[gapjaDayInx[1]]);
  gapjaString += String.fromCharCode(KOREAN_GAPJA_UNIT[gapjaDayInx[2]]);

  if (isIntercalation) {
    gapjaString += " (";
    gapjaString += String.fromCharCode(INTERCALATION_STR[0]);
    gapjaString += String.fromCharCode(KOREAN_GAPJA_UNIT[1]);
    gapjaString += ")";
  }

  return gapjaString;
}

String getChineseGapJaString() {
  getGapJa();

  var gapjaString = "";
  gapjaString += String.fromCharCode(CHINESE_CHEONGAN[gapjaYearInx[0]]);
  gapjaString += String.fromCharCode(CHINESE_GANJI[gapjaYearInx[1]]);
  gapjaString += String.fromCharCode(CHINESE_GAPJA_UNIT[gapjaYearInx[2]]);
  gapjaString += " ";
  gapjaString += String.fromCharCode(CHINESE_CHEONGAN[gapjaMonthInx[0]]);
  gapjaString += String.fromCharCode(CHINESE_GANJI[gapjaMonthInx[1]]);
  gapjaString += String.fromCharCode(CHINESE_GAPJA_UNIT[gapjaMonthInx[2]]);
  gapjaString += " ";
  gapjaString += String.fromCharCode(CHINESE_CHEONGAN[gapjaDayInx[0]]);
  gapjaString += String.fromCharCode(CHINESE_GANJI[gapjaDayInx[1]]);
  gapjaString += String.fromCharCode(CHINESE_GAPJA_UNIT[gapjaDayInx[2]]);

  if (isIntercalation) {
    gapjaString += " (";
    gapjaString += String.fromCharCode(INTERCALATION_STR[1]);
    gapjaString += String.fromCharCode(CHINESE_GAPJA_UNIT[1]);
    gapjaString += ")";
  }

  return gapjaString;
}

String getLunarIsoFormat() {
  var isoStr = sprintf("%04d-%02d-%02d", [lunarYear, lunarMonth, lunarDay]);

  if (isIntercalation) {
    isoStr += " Intercalation";
  }

  return isoStr;
}

String getSolarIsoFormat() {
  final isoStr = sprintf("%04d-%02d-%02d", [solarYear, solarMonth, solarDay]);

  return isoStr;
}

int getLunarYear() {
  return lunarYear;
}

int getLunarMonth() {
  return lunarMonth;
}

int getLunarDay() {
  return lunarDay;
}

int getSolarYear() {
  return solarYear;
}

int getSolarMonth() {
  return solarMonth;
}

int getSolarDay() {
  return solarDay;
}
