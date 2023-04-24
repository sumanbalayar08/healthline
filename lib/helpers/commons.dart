import 'package:mapbox_gl/mapbox_gl.dart';

import 'hospitals.dart';

LatLng getLatLngFromHospitalData(int index) {
  return LatLng(double.parse(hospitals[index]['coordinates']['latitude']),
      double.parse(hospitals[index]['coordinates']['longitude']));
}
