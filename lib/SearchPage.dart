import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:alert_dialog/alert_dialog.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String selectedCity = "";
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("Assets/pexels-szabó-viktor-3227984.jpg"),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: TextField(
                  onChanged: (String value) {
                    selectedCity = value;
                  },
                  autofocus: false,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "Search place",
                      enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black12, width: 5),
                          borderRadius: BorderRadius.circular(5))),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    var response = await http.get(Uri.parse(
                        "https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=cf34373d45b6571e545c339502189e2c&units=metric"));
                    if (response.statusCode == 200) {
                      Navigator.pop(context, selectedCity);
                    } else {
                      alert(
                        context,
                        title: Text('Stop! '),
                        content: Text('Please enter valid city name'),
                        textOK: Text('Okey'),
                      );
                    }
                  },
                  icon: Icon(Icons.search_off_outlined))
            ],
          ),
        ),
      ),
    );
  }
}
