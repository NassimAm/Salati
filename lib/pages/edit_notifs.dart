import 'package:flutter/material.dart';
import 'package:adhan_app/services/prayer.dart';

class EditNotifs extends StatefulWidget {
  const EditNotifs({Key? key}) : super(key: key);

  @override
  _EditNotifsState createState() => _EditNotifsState();
}

class _EditNotifsState extends State<EditNotifs> {
  IconData bellicon = Icons.notifications_on;
  Color? coloricon = Colors.yellow[600];
  Color? colortext = Colors.yellow[600];
  Color? prayercolor = Colors.white;
  bool all_on = true;
  void Function()? changeNotif;
  Map<String, List<String>> titletext = {
    "en": ["Adhan (enable adhan sound)", "Prayers"],
    "fr": ["Adhan (activer le son pour le adhan)", "Prières"],
    "ar": ["الآذان (تفعيل الصوت للآذان)", "الصلوات"]
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Notifications & Sounds'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: Salat.prayersnames[Salat.language]!.length + 1,
        itemBuilder: (context, index) {
          if (all_on == true) {
            colortext = Colors.yellow[600];
          } else {
            colortext = Colors.grey[700];
          }
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Colors.grey[700],
                  padding:
                      EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(titletext[Salat.language]![0],
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold)),
                      Switch(
                        value: all_on,
                        onChanged: (value) {
                          setState(() {
                            all_on = value;
                            if (all_on == false) {
                              for (int i = 0;
                                  i < Salat.playsoundprayers.length;
                                  i++) {
                                Salat.playsoundprayers[i] = false;
                              }
                            }
                          });
                        },
                        activeTrackColor: Colors.yellow,
                        activeColor: Colors.orangeAccent,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5.0),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15.0),
                  child: Text(
                    titletext[Salat.language]![1],
                    style: TextStyle(
                        color: colortext,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            );
          } else {
            if (Salat.playsoundprayers[index - 1] == true && all_on == true) {
              bellicon = Icons.notifications_on;
              coloricon = Colors.yellow[600];
            } else {
              bellicon = Icons.notifications_off;
              coloricon = Colors.grey[800];
            }

            if (all_on == true) {
              prayercolor = Colors.white;
              changeNotif = () {
                setState(() {
                  if (Salat.playsoundprayers[index - 1] == true) {
                    Salat.playsoundprayers[index - 1] = false;
                  } else {
                    Salat.playsoundprayers[index - 1] = true;
                  }
                });
              };
            } else {
              prayercolor = Colors.grey[800];
              changeNotif = () {};
            }
            return Card(
              color: Colors.grey[700],
              child: ListTile(
                onTap: changeNotif,
                leading: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                  child: Text(Salat.prayersnames[Salat.language]![index - 1],
                      style: TextStyle(
                          color: prayercolor,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
                title: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        bellicon,
                        size: 40,
                        color: coloricon,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
