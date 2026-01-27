import 'package:latlong2/latlong.dart';

final Distance _distance = const Distance();

double distanceMeters(LatLng a, LatLng b) {
  return _distance.as(LengthUnit.Meter, a, b);
}
