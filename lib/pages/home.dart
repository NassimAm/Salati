import 'dart:async';

import 'package:flutter/material.dart';
import 'package:adhan_app/services/prayer.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

String toISO(Duration d) {
  String result = '';
  if (d.inHours < 10) result += '0';
  result += d.inHours.toString() + ':';
  if (d.inMinutes - d.inHours * 60 < 10) result += '0';
  result += (d.inMinutes - d.inHours * 60).toString() + ':';
  if (d.inSeconds - d.inMinutes * 60 < 10) result += '0';
  result += (d.inSeconds - d.inMinutes * 60).toString();

  return result;
}

void scheduleAlarm(
    String eventname, DateTime dt, int id, bool playsound, bool issalat) async {
  Map<String, String> notifdesc = {
    "en": "Here is the Adhan! Time to Pray",
    "fr": "Voila le Adhan! Il est temps d'aller à la prière",
    "ar": "قد أذن! حان وقت الصلاة"
  };
  if (issalat == false) {
    notifdesc = {
      "en": "The Sun is up, time to wake up!",
      "fr": "C'est le lever de soleil, il est temps de se réveiller!",
      "ar": "قد أشرقت الشمس، حان وقت الإستيقاض!"
    };
  }
  var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'Adhan Channel', 'Adhan Channel', 'Channel for Adhan Alarm',
      sound: RawResourceAndroidNotificationSound('adhan_yacine'),
      playSound: playsound,
      importance: Importance.max,
      priority: Priority.high);

  var iOSPlatformChannelSpecifics = IOSNotificationDetails();

  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  // ignore: deprecated_member_use
  await flutterlocalnotificationplugin.schedule(
    id,
    eventname,
    notifdesc[Salat.language],
    dt,
    platformChannelSpecifics,
  );
}

void setPrayersNotifications() {
  DateTime currenttime = DateTime.now();
  if (currenttime.isBefore(Salat.prayers.fajr
      .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) {
    scheduleAlarm(
        Salat.prayersnames[Salat.language]![0],
        Salat.prayers.fajr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)),
        0,
        Salat.playsoundprayers[0],
        true);
  }
  if (currenttime.isBefore(Salat.prayers.sunrise
      .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) {
    scheduleAlarm(
        Salat.prayersnames[Salat.language]![1],
        Salat.prayers.sunrise
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)),
        1,
        Salat.playsoundprayers[1],
        false);
  }
  if (currenttime.isBefore(Salat.prayers.dhuhr
      .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) {
    scheduleAlarm(
        Salat.prayersnames[Salat.language]![2],
        Salat.prayers.dhuhr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)),
        2,
        Salat.playsoundprayers[2],
        true);
  }
  if (currenttime.isBefore(Salat.prayers.asr
      .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) {
    scheduleAlarm(
        Salat.prayersnames[Salat.language]![3],
        Salat.prayers.asr
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)),
        3,
        Salat.playsoundprayers[3],
        true);
  }
  if (currenttime.isBefore(Salat.prayers.maghrib
      .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) {
    scheduleAlarm(
        Salat.prayersnames[Salat.language]![4],
        Salat.prayers.maghrib
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)),
        4,
        Salat.playsoundprayers[4],
        true);
  }
  if (currenttime.isBefore(Salat.prayers.isha
      .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)))) {
    scheduleAlarm(
        Salat.prayersnames[Salat.language]![5],
        Salat.prayers.isha
            .subtract(Duration(hours: currenttime.timeZoneOffset.inHours)),
        5,
        Salat.playsoundprayers[5],
        true);
  }
}

void initSalat() async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('init', Salat.init);
}

//Initialise Notifications ======================================
final FlutterLocalNotificationsPlugin flutterlocalnotificationplugin =
    new FlutterLocalNotificationsPlugin();

void initNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});

  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterlocalnotificationplugin.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });

  if (Salat.init == false) {
    Salat.calculatePrayers(DateTime.now().timeZoneOffset.inHours,
        DateTime.now().year, DateTime.now().month, DateTime.now().day);
    setPrayersNotifications();
    Salat.setInit(true);
    initSalat();
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<String> options = [];
  Duration salatremainingtime = Duration(hours: 0, minutes: 0, seconds: 0);
  Map data = {};
  String placename = '';
  double prevlatitude = Salat.locationLatitude;
  double prevlongitude = Salat.locationLongitude;

  void countDownTimer() async {
    while (true) {
      await Future.delayed(Duration(seconds: 1)).then((_) {
        setState(() {
          salatremainingtime -= Duration(seconds: 1);
        });
      });
      if (salatremainingtime.inSeconds <= 0) {
        Salat.getNextPrayerTime(DateTime.now());
        salatremainingtime = Salat.remainingTime;
      }
    }
  }

  @override
  void initState() {
    initNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Salat.manualLocation == false) {
      data = data.isNotEmpty
          ? data
          : ModalRoute.of(context)!.settings.arguments as Map;
      Position? locationdata = data["location"];
      Salat.setLocation(locationdata!.latitude, locationdata.longitude);
      Salat.getNextPrayerTime(DateTime.now());
      placename = '';
    } else {
      Salat.setLocation(Salat.locationLatitude, Salat.locationLongitude);
      Salat.getNextPrayerTime(DateTime.now());
      placename = Salat.placename;
    }

    if ((prevlatitude != Salat.locationLatitude &&
            prevlongitude != Salat.locationLongitude) ||
        (prevlatitude == 0 && prevlongitude == 0)) {
      setPrayersNotifications();
      prevlatitude = Salat.locationLatitude;
      prevlongitude = Salat.locationLongitude;
    }

    salatremainingtime = Salat.remainingTime;
    countDownTimer();
    return Scaffold(
        backgroundColor: Colors.grey[800],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) async {
            if (index == 1) {
              dynamic result = await Navigator.pushNamed(context, '/settings');
            }
          },
          backgroundColor: Colors.grey[850],
          selectedItemColor: Colors.yellow[700],
          selectedIconTheme: IconThemeData(color: Colors.yellow[700]),
          selectedLabelStyle:
              TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          unselectedItemColor: Colors.white,
          unselectedLabelStyle:
              TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        body: SafeArea(
            child: ListView(
          children: <Widget>[
            Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                height: 200,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Color(0xFFFBC02D), width: 3)),
                    image: DecorationImage(
                        image: AssetImage('assets/home_head.jpg'),
                        fit: BoxFit.cover)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.edit_location,
                          color: Colors.white,
                        ),
                        SizedBox(width: 10.0),
                        Text(placename,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(Salat.currentPrayer,
                              style: TextStyle(
                                  color: Colors.yellow[600],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                          SizedBox(height: 10.0),
                          Text(DateFormat.jm().format(Salat.currentPrayerDate),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5)),
                          SizedBox(height: 10.0),
                          Text('(${toISO(salatremainingtime)})',
                              style: TextStyle(
                                  color: Colors.yellow[700],
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5))
                        ],
                      ),
                    ),
                  ],
                )),
            SizedBox(height: 5),
            //Fajr ====================================================================================
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                onTap: () {},
                tileColor: Colors.grey[700],
                leading: Image.asset('assets/Sun_set_rise.png', width: 55),
                title: Text(Salat.prayersnames[Salat.language]![0],
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(DateFormat.jm().format(Salat.prayers.fajr),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            //Sunrise ================================================================================================================
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                onTap: () {},
                tileColor: Colors.grey[700],
                leading: Image.asset('assets/Sun_set_rise.png', width: 55),
                title: Text(Salat.prayersnames[Salat.language]![1],
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(DateFormat.jm().format(Salat.prayers.sunrise),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            //Dohr ==================================================================================================================================
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                onTap: () {},
                tileColor: Colors.grey[700],
                leading: Image.asset('assets/Sun.png'),
                title: Text(Salat.prayersnames[Salat.language]![2],
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(DateFormat.jm().format(Salat.prayers.dhuhr),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            //Asr ==================================================================================================================================
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                onTap: () {},
                tileColor: Colors.grey[700],
                leading: Image.asset('assets/Sun.png'),
                title: Text(Salat.prayersnames[Salat.language]![3],
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(DateFormat.jm().format(Salat.prayers.asr),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            //Maghreb ================================================================================================================================
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                onTap: () {},
                tileColor: Colors.grey[700],
                leading: Image.asset('assets/Sun_set_rise.png', width: 55),
                title: Text(Salat.prayersnames[Salat.language]![4],
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(DateFormat.jm().format(Salat.prayers.maghrib),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
            //Isha =====================================================================================================================
            Card(
              margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: ListTile(
                onTap: () {},
                tileColor: Colors.grey[700],
                leading: Container(
                    padding: EdgeInsets.all(5.0),
                    child: Image.asset('assets/Moon.png')),
                title: Text(Salat.prayersnames[Salat.language]![5],
                    style: TextStyle(
                        color: Colors.yellow[600],
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 5.0),
                    Text(DateFormat.jm().format(Salat.prayers.isha),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ],
        )));
  }
}
