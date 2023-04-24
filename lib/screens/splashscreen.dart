import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:healthsearch/helpers/hospitals.dart';
import 'package:healthsearch/helpers/directions_handler.dart';
import 'package:healthsearch/main.dart';
import 'package:healthsearch/screens/signin.dart';
import 'package:healthsearch/screens/home_management.dart';
import 'package:healthsearch/screens/signin.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:location/location.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initializeLocationAndSave();
  }

  Future<void> initializeLocationAndSave() async {
    // Ensure all permissions are collected for Locations
    Location location = Location();
    bool? serviceEnabled;
    PermissionStatus? permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }

    // Get capture the current user location
    LocationData locationData = await location.getLocation();
    LatLng currentLatLng =
        LatLng(locationData.latitude!, locationData.longitude!);

    // Store the user location in sharedPreferences
    sharedPreferences.setDouble("latitude", locationData.latitude!);
    sharedPreferences.setDouble("longitude", locationData.latitude!);

    // Get and store the directions API response in sharedPreferences

    for (int i = 0; i < hospitals.length; i++) {
      Map modifiedResponse = await getDirectionsAPIResponse(currentLatLng, i);
      saveDirectionsAPIResponse(i, json.encode(modifiedResponse));
    }

    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => SignIn()),
        (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/logo_app.png",
                height: 75,
                width: 75,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            const Text(
              "HEALTHLINE",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
