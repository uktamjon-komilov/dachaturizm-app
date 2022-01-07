import 'dart:async';
import 'package:dachaturizm/components/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
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
  bool _isInit = true;
  Completer<GoogleMapController> _controller = Completer();

  Map _data = {
    "subAdministrativeArea": "",
    "administrativeArea": "",
    "country": "",
    "street": "",
  };

  Set<Marker> _markers = {};

  CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.2995, 69.2401),
    zoom: 14.0,
  );

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Map? data = ModalRoute.of(context)!.settings.arguments as Map?;
      if (data != null) {
        if (data["latitute"] != 0.0 && data["longtitude"] != 0.0) {
          _markers.add(
            Marker(
              markerId: MarkerId("1"),
              position: LatLng(data["latitute"], data["longtitude"]),
            ),
          );
        }
      } else {
        _markers.add(
          Marker(
            markerId: MarkerId("1"),
            position: LatLng(41.2995, 69.2401),
          ),
        );
      }
      setState(() {
        _isInit = false;
      });
    }
    super.didChangeDependencies();
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
        appBar: buildNavigationalAppBar(
          context,
          Locales.string(context, "choose_location"),
          () {
            _data["position"] = _markers.firstWhere((element) => true).position;
            Navigator.pop(context, _data);
          },
        ),
        body: _isInit
            ? Center(
                child: CircularProgressIndicator(),
              )
            : GoogleMap(
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

                  final place = placemarks[0];

                  _data["subAdministrativeArea"] =
                      place.subAdministrativeArea != ""
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
