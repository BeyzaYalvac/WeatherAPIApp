import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'SearchPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String Location = "Ankara";
  double degree = 25;
  final String key = "80ffc111ac54e8213c0a40d6a531a5d0";
  var locationData;
  String Image = "Snow";
  Position? CurLocation;

  Future<void> getLocation() async {
    locationData = await http.get(Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$Location&appid=$key&units=metric"));
    final locationdataparsed = jsonDecode(locationData.body);
    print(locationdataparsed);

    setState(() {
      degree = locationdataparsed["main"]["temp"];
      Location = locationdataparsed["name"];
      print(locationdataparsed["weather"][0]["main"]);
      Image = locationdataparsed["weather"][0]["main"];
    });
  }

  Future<void> getLocationbyLatAndLon() async {
    if (CurLocation != null) {
      locationData = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${CurLocation!.latitude}&lon=${CurLocation!.longitude}&appid=$key&units=metric"));
      final locationdataparsed = jsonDecode(locationData.body);
      print(locationdataparsed);

      setState(() {
        degree = locationdataparsed["main"]["temp"];
        Location = locationdataparsed["name"];
        print(locationdataparsed["wheather"].first["main"]);
        Image = locationdataparsed["wheather"].first["main"];
      });
    } else {
      CircularProgressIndicator();
    }
  }

  Future<void> getCurrentLocation() async {
    CurLocation = await _determinePosition();
    print(CurLocation);
  }

  @override
  void getInitial() async {
    await getCurrentLocation();
    await getLocationbyLatAndLon();
  }

  @override
  void initState() {
    super.initState();
    getInitial();
    //getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("Assets/$Image.jpg"), fit: BoxFit.cover)),
      //if Temp == null
      child: (degree == null || CurLocation == null)
          ? const Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(color: Colors.black),
                Text(
                  "Lütfen biraz bekleyiniz.",
                  style: TextStyle(color: Colors.white, fontSize: 25),
                )
              ],
            ))
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () async {
                          await getLocation();
                        },
                        child: Text("Get location data"),
                      ),
                      Text(
                        "$degree C",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 48),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$Location",
                              style:
                                  TextStyle(fontSize: 25, color: Colors.white),
                            ),
                            IconButton(
                                onPressed: () async {
                                  final selectedCity = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SearchPage()));
                                  Location = selectedCity as String;
                                  getLocation();
                                  // veri geliyor mu onun test satırı
                                  // print(selectedCity);
                                },
                                icon: Icon(
                                  Icons.search,
                                  size: 30,
                                ))
                          ])
                    ],
                  ),
                ),
              ),
            ),
    );
  }
//ilk push denemesi
  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
