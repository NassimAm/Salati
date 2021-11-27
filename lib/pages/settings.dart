import 'package:flutter/material.dart';
import 'package:adhan_app/services/prayer.dart';
import 'package:shared_preferences/shared_preferences.dart';

String? language = Salat.language;

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, List<List<String>>> options = {
    "en": [
      ["Language", "Set the app language"],
      ["Location", "Set your location automaticly or manually"],
      ["Notifications & Sounds", "Set your notifications and sounds"]
    ],
    "fr": [
      ["Langage", "Configurer le language de l'application"],
      [
        "Position GPS",
        "Configurer votre position GPS automatiquement ou manuellement"
      ],
      ["Nofications & Sons", "Configurer les notifications et les sons"]
    ],
    "ar": [
      ["اللغة", "تغيير لغة التطبيق"],
      ["الموقع الجيوغرافي", "ضبط الموقع الجيوغرافي ٱليا أو يدويا"],
      ["التنبيهات و الأصوات", "ضبط التنبيهات و الأصوات"]
    ]
  };
  List<IconData> optionsicons = [
    Icons.language,
    Icons.edit_location,
    Icons.notification_add
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[800],
        appBar: AppBar(
          title: Text('Settings'),
          backgroundColor: Colors.grey[900],
          centerTitle: true,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            if (index == 0) {
              Navigator.pop(context);
            }
          },
          currentIndex: 1,
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
        body: ListView.builder(
            itemCount: optionsicons.length,
            itemBuilder: (context, index) => Card(
                color: Colors.grey[700],
                child: ListTile(
                  onTap: () async {
                    if (index == 0) {
                      dynamic result = await Navigator.pushNamed(
                          context, '/settings/languages');
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString('language', Salat.language);
                      setState(() {
                        language = Salat.language;
                      });
                    } else if (index == 1) {
                      dynamic result = await Navigator.pushNamed(
                          context, '/settings/edit_location');
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('manuallocation', Salat.manualLocation);
                      prefs.setDouble('latitude', Salat.locationLatitude);
                      prefs.setDouble('longitude', Salat.locationLongitude);
                      prefs.setString('placename', Salat.placename);
                    } else if (index == 2) {
                      dynamic result = await Navigator.pushNamed(
                          context, '/settings/edit_notifs');
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setBool('prayersounds0', Salat.playsoundprayers[0]);
                      prefs.setBool('prayersounds1', Salat.playsoundprayers[1]);
                      prefs.setBool('prayersounds2', Salat.playsoundprayers[2]);
                      prefs.setBool('prayersounds3', Salat.playsoundprayers[3]);
                      prefs.setBool('prayersounds4', Salat.playsoundprayers[4]);
                      prefs.setBool('prayersounds5', Salat.playsoundprayers[5]);
                    }
                  },
                  leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Icon(optionsicons[index],
                          size: 30, color: Colors.white)),
                  title: Text(options[language]![index][0],
                      style: TextStyle(
                          color: Colors.yellow[600],
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.0),
                      Text(options[language]![index][1],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                    ],
                  ),
                ))));
  }
}
