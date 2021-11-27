import 'package:flutter/material.dart';
import 'package:adhan_app/services/prayer.dart';

class Language extends StatefulWidget {
  const Language({Key? key}) : super(key: key);

  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  List<List<String>> languages = [
    ["Arabic", "ar"],
    ["English", "en"],
    ["French", "fr"]
  ];
  String? language = Salat.language;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text('Edit Language'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          return ListTile(
            tileColor: Colors.grey[700],
            leading: Radio<String>(
              value: languages[index][1],
              groupValue: language,
              onChanged: (String? value) {
                setState(() {
                  Salat.setLanguage(value!);
                  language = value;
                });
              },
            ),
            title: Text(
              languages[index][0],
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
            ),
          );
        },
      ),
    );
  }
}
