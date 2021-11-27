// ignore: import_of_legacy_library_into_null_safe
import 'package:adhan/adhan.dart';

class Salat {
  static bool init = false;
  static late PrayerTimes prayers;
  static String currentPrayer = '';
  static late DateTime currentPrayerDate;
  static Duration remainingTime = Duration();
  static String language = "en";
  static int salatindex = 0;
  static bool manualLocation = false;
  static String placename = '';
  static double locationLatitude = 0;
  static double locationLongitude = 0;
  static Map<String, List<String>> prayersnames = {
    "ar": ["الفجر", "الشروق", "الظهر", "العصر", "المغرب", "العشاء"],
    "en": ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"],
    "fr": ["Fajr", "Sunrise", "Dohr", "Asr", "Maghrib", "Isha"],
  };
  static List<bool> playsoundprayers = [true, false, true, true, true, true];

  static void calculatePrayers(int utcoffset, int year, int month, int day) {
    // print('My Prayer Times');
    final location = Coordinates(locationLatitude, locationLongitude);
    final nyUtcOffset = Duration(hours: utcoffset);
    final nyDate = DateComponents(year, month, day);
    final nyParams = CalculationMethod.muslim_world_league.getParameters();
    nyParams.madhab = Madhab.shafi;
    prayers = PrayerTimes(location, nyDate, nyParams, utcOffset: nyUtcOffset);
    //print(prayers.fajr.timeZoneOffset.inHours);
    // print(prayers.fajr.timeZoneName);
    // print(prayers.fajr);
    // print(prayers.sunrise);
    // print(prayers.dhuhr);
    // print(prayers.asr);
    // print(prayers.maghrib);
    // print(prayers.isha);

    // print('---');
  }

  static void getNextPrayerTime(DateTime currenttime) {
    calculatePrayers(currenttime.timeZoneOffset.inHours, currenttime.year,
        currenttime.month, currenttime.day);

    if ((currenttime.isAfter(prayers.fajr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) &&
        (currenttime.isBefore(prayers.sunrise
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours))))) {
      currentPrayer = prayersnames[language]![1];
      salatindex = 1;
      currentPrayerDate = prayers.sunrise;
    } else if ((currenttime.isAfter(prayers.sunrise
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) &&
        (currenttime.isBefore(prayers.dhuhr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours))))) {
      currentPrayer = prayersnames[language]![2];
      salatindex = 2;
      currentPrayerDate = prayers.dhuhr;
    } else if ((currenttime.isAfter(prayers.dhuhr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) &&
        (currenttime.isBefore(prayers.asr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours))))) {
      currentPrayer = prayersnames[language]![3];
      salatindex = 3;
      currentPrayerDate = prayers.asr;
    } else if ((currenttime.isAfter(prayers.asr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) &&
        (currenttime.isBefore(prayers.maghrib
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours))))) {
      currentPrayer = prayersnames[language]![4];
      salatindex = 4;
      currentPrayerDate = prayers.maghrib;
    } else if ((currenttime.isAfter(prayers.maghrib
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) &&
        (currenttime.isBefore(prayers.isha
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours))))) {
      currentPrayer = prayersnames[language]![5];
      salatindex = 5;
      currentPrayerDate = prayers.isha;
    } else {
      currentPrayer = prayersnames[language]![0];
      salatindex = 0;
      currentPrayerDate = prayers.fajr;
    }

    if (currenttime.hour > prayers.maghrib.hour &&
        currentPrayer == prayersnames[language]![0])
      remainingTime = Duration(hours: 24) -
          currenttime.difference(currentPrayerDate) -
          Duration(hours: currenttime.timeZoneOffset.inHours);
    else
      remainingTime = currentPrayerDate.difference(currenttime) -
          Duration(hours: currenttime.timeZoneOffset.inHours);
  }

  static void setInit(bool val) {
    init = val;
  }

  static void setLanguage(String l) {
    language = l;
    currentPrayer = prayersnames[l]![salatindex];
  }

  static void setLocation(double lat, double lng) {
    locationLatitude = lat;
    locationLongitude = lng;
  }

  static void setManualLocation(bool m) {
    manualLocation = m;
  }

  static void setPlaceName(String s) {
    placename = s;
  }

  static void setPrayerSounds(List<bool> ps) {
    playsoundprayers = ps;
  }
}
