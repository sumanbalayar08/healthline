import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:healthsearch/helpers/hospitals.dart';
import 'package:healthsearch/helpers/shared_prefs.dart';
import 'package:healthsearch/widgets/carousel_card.dart';
import 'package:healthsearch/helpers/commons.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

class Hospital_Map extends StatefulWidget {
  const Hospital_Map({Key? key}) : super(key: key);

  @override
  State<Hospital_Map> createState() => _Hospital_MapState();
}

class _Hospital_MapState extends State<Hospital_Map> {
  // Mapbox related
  LatLng latLng = getLatLngFromSharedPrefs();
  late CameraPosition _initialCameraPosition;
  late MapboxMapController controller;
  late List<CameraPosition> _kHospitalList;

  List<Map> carouselData = [];

  // Carousel related
  int pageindex = 0;
  late List<Widget> carouselItems;

  @override
  void initState() {
    super.initState();
    _initialCameraPosition = CameraPosition(target: latLng, zoom: 500);

    // Calculate the distance and time from data in SharedPreferences
    for (int index = 0; index < hospitals.length; index++) {
      num distance = getDistanceFromSharedPrefs(index) / 1000;
      num duration = getDurationFromSharedPrefs(index) / 60;
      carouselData
          .add({'index': index, 'distance': distance, 'duration': duration});
    }
       carouselData.sort((a, b) => a['duration'] < b['duration'] ? 0 : 1);

       //generate carousel widgets on the top of the map section
        carouselItems = List<Widget>.generate(
        hospitals.length,
        (index) => carouselCard(carouselData[index]['index'],
            carouselData[index]['distance'], carouselData[index]['duration']));


    // initialize map symbols in the same order as carousel widgets
    _kHospitalList = List<CameraPosition>.generate(
        hospitals.length,
        (index) => CameraPosition(
            target: getLatLngFromHospitalData(carouselData[index]['index']),
            zoom: 15));
  }

  _addSourceAndLineLayer(int index, bool removeLayer) async {
    // Can animate camera to focus on the item
   controller.animateCamera(CameraUpdate.newCameraPosition(_kHospitalList[index]));

    // Add a polyLine between source and destination
      Map geometry = getGeometryFromSharedPrefs(carouselData[index]['index']);
    final _fills = {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": 0,
          "properties": <String, dynamic>{},
          "geometry": geometry,
        },
      ],
    };

    // Remove lineLayer and source if it exists
    if (removeLayer == true) {
      await controller.removeLayer("lines");
      await controller.removeSource("fills");
    }

    // Add new source and lineLayer
       await controller.addSource("fills", GeojsonSourceProperties(data: _fills));
    await controller.addLineLayer(
      "fills",
      "lines",
      LineLayerProperties(
        lineColor: Colors.blue.toHexStringRGB(),
        lineCap: "round",
        lineJoin: "round",
        lineWidth: 6,
      ),
    );
  
  }

  _onMapCreated(MapboxMapController controller) async {
    this.controller = controller;
  }

  _onStyleLoadedCallback() async {
    for (CameraPosition _kHospital in _kHospitalList) {
      await controller.addSymbol(
        SymbolOptions(
          geometry: _kHospital.target,
          iconSize: 0.5,
          iconImage: "assets/images/hospital.png",
        ),
      );
    }
    _addSourceAndLineLayer(0, false);
   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hospital Location"),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 1,
              child: MapboxMap(
                accessToken: dotenv.env['MAPBOX_ACCESS_TOKEN'],
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.TrackingGPS,
                minMaxZoomPreference: const MinMaxZoomPreference(14, 17),
              ),
            ),
           CarouselSlider(
              items: carouselItems,
              options: CarouselOptions(
                height: 100,
                viewportFraction: 0.6,
                initialPage: 0,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
                onPageChanged:
                    (int index, CarouselPageChangedReason reason) async {
                  setState(() {
                    pageindex = index;
                  });
                  _addSourceAndLineLayer(index, true);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.animateCamera(
            CameraUpdate.newCameraPosition(_initialCameraPosition),
          );
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
