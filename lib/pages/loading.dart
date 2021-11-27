import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_app/services/prayer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:adhan_app/services/localisation.dart';

Position? currentPosition;
String currentAddress = '';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    final init = prefs.getBool('init') ?? false;
    final language = prefs.getString('language') ?? 'en';
    final placename = prefs.getString('placename') ?? '';
    final latitude = prefs.getDouble('latitude') ?? 0;
    final longitude = prefs.getDouble('longitude') ?? 0;
    final manuallocation = prefs.getBool('manuallocation') ?? false;
    final prayersounds0 = prefs.getBool('prayersounds0') ?? true;
    final prayersounds1 = prefs.getBool('prayersounds1') ?? false;
    final prayersounds2 = prefs.getBool('prayersounds2') ?? true;
    final prayersounds3 = prefs.getBool('prayersounds3') ?? true;
    final prayersounds4 = prefs.getBool('prayersounds4') ?? true;
    final prayersounds5 = prefs.getBool('prayersounds5') ?? true;

    Salat.setInit(init);
    Salat.setLanguage(language);
    Salat.setPlaceName(placename);
    Salat.setLocation(latitude, longitude);
    Salat.setManualLocation(manuallocation);
    Salat.setPrayerSounds([
      prayersounds0,
      prayersounds1,
      prayersounds2,
      prayersounds3,
      prayersounds4,
      prayersounds5
    ]);
    currentPosition = await determinePosition(manuallocation);
    if (currentPosition == null) {
      currentPosition = Position(
          longitude: longitude,
          latitude: latitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0);
    }
    Navigator.pushReplacementNamed(context, '/home', arguments: {
      "location": currentPosition,
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      body: Center(
        child: SpinKitChasingDots(
          color: Colors.yellow[600],
          size: 60,
        ),
      ),
    );
  }
}
