import 'package:flutter/material.dart';
import 'package:adhan_app/services/prayer.dart';
import 'package:cron/cron.dart';

import 'package:adhan_app/pages/home.dart';
import 'package:adhan_app/pages/settings.dart';
import 'package:adhan_app/pages/language.dart';
import 'package:adhan_app/pages/loading.dart';
import 'package:adhan_app/pages/edit_location.dart';
import 'package:adhan_app/pages/edit_notifs.dart';

//Main Script =======================================================================================================================
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    routes: {
      '/': (context) => Loading(),
      '/home': (context) => Home(),
      '/settings': (context) => Settings(),
      '/settings/languages': (context) => Language(),
      '/settings/edit_location': (context) => EditLocation(),
      '/settings/edit_notifs': (context) => EditNotifs(),
    },
    initialRoute: '/',
  ));
  var cron = new Cron();
  cron.schedule(new Schedule.parse('0 0 * * *'), () async {
    Salat.calculatePrayers(DateTime.now().timeZoneOffset.inHours,
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    setPrayersNotifications();
  });
}
