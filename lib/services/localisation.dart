import 'package:geolocator/geolocator.dart';

Future<Position?> determinePosition(bool manuallocation) async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled && manuallocation) {
    return null;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return null;
  }
  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  //If the user refuse for any reason to activate his location we try and catch the error
  try {
    return await Geolocator.getCurrentPosition();
  } catch (e) {
    return null;
  }
}
