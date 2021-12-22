import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({Key? key}) : super(key: key);

  static String routeName = "/location-picker";

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  Completer<GoogleMapController> _controller = Completer();

  Map _data = {
    "subAdministrativeArea": "",
    "administrativeArea": "",
    "country": "",
    "street": "",
  };

  Set<Marker> _markers = {
    Marker(
      markerId: MarkerId("1"),
      position: LatLng(41.2995, 69.2401),
    )
  };

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.2995, 69.2401),
    zoom: 14.0,
  );

  Future _getLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
      return await location.getLocation();
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  Future<void> _goToMyPosition(myPosition) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(myPosition));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _data["position"] = _markers.firstWhere((element) => true).position;
        Navigator.pop(context, _data);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Choose location"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _data["position"] =
                  _markers.firstWhere((element) => true).position;
              Navigator.pop(context, _data);
            },
          ),
        ),
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kGooglePlex,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers,
          onTap: (pos) async {
            _markers.clear();
            _markers.add(
              Marker(
                markerId: MarkerId("1"),
                position: LatLng(pos.latitude, pos.longitude),
              ),
            );

            List<geocoding.Placemark> placemarks = await geocoding
                .placemarkFromCoordinates(pos.latitude, pos.longitude);

            print(placemarks[0]);
            final place = placemarks[0];

            _data["subAdministrativeArea"] = place.subAdministrativeArea != ""
                ? place.subAdministrativeArea
                : place.subLocality;
            _data["administrativeArea"] = place.administrativeArea != ""
                ? place.administrativeArea
                : place.locality;
            _data["country"] = place.country;
            _data["street"] =
                place.street != "" ? place.street : place.thoroughfare;

            setState(() {});
          },
        ),
      ),
    );
  }
}
