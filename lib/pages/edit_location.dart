import 'package:adhan_app/pages/loading.dart';
import 'package:flutter/material.dart';
import 'package:adhan_app/services/prayer.dart';
import 'package:adhan_app/services/localisation.dart';

class EditLocation extends StatefulWidget {
  const EditLocation({Key? key}) : super(key: key);

  @override
  _EditLocationState createState() => _EditLocationState();
}

class _EditLocationState extends State<EditLocation> {
  List<List> places = [
    ["Adrar", 27.8742, -0.2939],
    ["Aïn Defla", 36.2583, 1.9583],
    ["Aïn Temouchent", 35.3044, -1.14],
    ["Algiers", 36.7764, 3.0586],
    ["Annaba", 36.9, 7.7667],
    ["Batna", 35.55, 6.1667],
    ["Béchar", 31.6333, -2.2],
    ["Bejaïa", 36.7511, 5.0642],
    ["Biskra", 34.85, 5.7333],
    ["Blida", 36.4722, 2.8333],
    ["Bordj Bou Arreridj", 36.0667, 4.7667],
    ["Bouira", 36.3783, 3.8925],
    ["Boumerdes", 36.7594, 3.4728],
    ["Chlef", 36.1647, 1.3317],
    ["Constantine", 36.365, 6.6147],
    ["Djelfa", 34.6667, 3.25],
    ["El Bayadh", 33.6831, 1.0192],
    ["El Oued", 33.3683, 6.8675],
    ["El Tarf", 36.7669, 8.3136],
    ["Ghardaïa", 32.4833, 3.6667],
    ["Guelma", 36.4619, 7.4258],
    ["Illizi", 26.508, 8.4829],
    ["Jijel", 36.8206, 5.7667],
    ["Khenchela", 35.4167, 7.1333],
    ["Laghouat", 33.8, 2.865],
    ["M’Sila", 35.7058, 4.5419],
    ["Mascara", 35.4, 0.1333],
    ["Médéa", 36.2675, 2.75],
    ["Mila", 36.4481, 6.2622],
    ["Mostaganem", 35.9333, 0.0903],
    ["Naama", 33.2678, -0.3111],
    ["Oran", 35.6969, -0.6331],
    ["Ouargla", 31.95, 5.3167],
    ["Oum el Bouaghi", 35.8706, 7.115],
    ["Relizane", 35.7372, 0.5558],
    ["Saïda", 34.8303, 0.1517],
    ["Sétif", 36.19, 5.41],
    ["Sidi Bel Abbès", 35.2, -0.6333],
    ["Skikda", 36.8667, 6.9],
    ["Souk Ahras", 36.2864, 7.9511],
    ["Tamanrasset", 22.785, 5.5228],
    ["Tébessa", 35.4, 8.1167],
    ["Tiaret", 35.3667, 1.3167],
    ["Tindouf", 27.6753, -8.1286],
    ["Tipasa", 36.5942, 2.443],
    ["Tissemsilt", 35.6072, 1.8106],
    ["Tizi Ouzou", 36.7169, 4.0497],
    ["Tlemcen", 34.8828, -1.3167]
  ];
  bool automaticLocation = !Salat.manualLocation;
  Color? titlecolor;
  Color? placescolor;
  void Function()? changeLocation;
  Map<String, List<String>> titletext = {
    "en": ["GPS Location", "Places"],
    "fr": ["Localisation GPS", "Places"],
    "ar": ["نظام التموضع العالمي (GPS)", "المواقع"]
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Edit Location'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: places.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            if (automaticLocation == true) {
              titlecolor = Colors.grey;
            } else {
              titlecolor = Colors.yellow[600];
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        value: automaticLocation,
                        onChanged: (value) async {
                          setState(() {
                            automaticLocation = value;
                            Salat.setManualLocation(!value);
                          });
                          if (value == true) {
                            dynamic currentPosition =
                                await determinePosition(false);
                            if (currentPosition != null)
                              Salat.setLocation(currentPosition!.latitude,
                                  currentPosition!.longitude);
                          }
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
                        color: titlecolor,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            );
          } else {
            if (automaticLocation == true) {
              placescolor = Colors.grey;
              changeLocation = () {};
            } else {
              placescolor = Colors.white;
              changeLocation = () {
                setState(() {
                  Salat.setLocation(places[index - 1][1], places[index - 1][2]);
                  Salat.setPlaceName(places[index - 1][0]);
                  Navigator.popUntil(context, (route) => route.isFirst);
                });
              };
            }
            return Card(
                color: Colors.grey[700],
                child: ListTile(
                  enabled: !automaticLocation,
                  onTap: changeLocation,
                  title: Text(places[index - 1][0].toString(),
                      style: TextStyle(
                          color: placescolor,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold)),
                ));
          }
        },
      ),
    );
  }
}
