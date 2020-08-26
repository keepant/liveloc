import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:liveloc/services/db_helper.dart';
import 'package:liveloc/services/prefs.dart';
import 'package:location/location.dart';

class ShowMaps extends StatefulWidget {
  @override
  _ShowMapsState createState() => _ShowMapsState();
}

class _ShowMapsState extends State<ShowMaps> {
  final Location location = Location();
  LocationData _locationData;
  StreamSubscription<LocationData> _locationSubscription;
  final dbHelper = new DBHelper();
  final Set<Marker> _markers = {};
  GoogleMapController mapController;

  PermissionStatus _permissionStatus;

  Future<void> _checkPermissions() async {
    final PermissionStatus permissionStatusResult =
        await location.hasPermission();
    setState(() {
      _permissionStatus = permissionStatusResult;
    });
  }

  Future<void> _requestPermission() async {
    if (_permissionStatus != PermissionStatus.granted) {
      final PermissionStatus permissionRequestedResult =
          await location.requestPermission();
      setState(() {
        _permissionStatus = permissionRequestedResult;
      });
      if (permissionRequestedResult != PermissionStatus.granted) {
        return;
      }
    }
  }

  Future<void> _listenLocation() async {
    String id = await prefs.getUserId();
    _locationSubscription =
        location.onLocationChanged.listen((currentLocation) {
      dbHelper.updateLocation(
        id: id,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );
      if (mounted) {
        setState(() {
          _locationData = currentLocation;
          _markers.clear();
          final marker = Marker(
            markerId: MarkerId("curr_loc"),
            position:
                LatLng(currentLocation.latitude, currentLocation.longitude),
            infoWindow: InfoWindow(title: 'Your Location'),
          );
          _markers.add(marker);
        });
      }
    });
  }

  Future<void> stopListen() async {
    _locationSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    if (_permissionStatus != PermissionStatus.granted) {
      _requestPermission();
      _listenLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location on maps'),
      ),
      body: Center(
        child: _locationData == null
            ? CircularProgressIndicator()
            : GoogleMap(
                markers: _markers,
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    _locationData.latitude,
                    _locationData.longitude,
                  ),
                  zoom: 18.0,
                ),
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    controller.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            _locationData.latitude,
                            _locationData.longitude,
                          ),
                          zoom: 18.0,
                        ),
                      ),
                    );
                    controller.moveCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(
                            _locationData.latitude,
                            _locationData.longitude,
                          ),
                          zoom: 18.0,
                        ),
                      ),
                    );
                  });
                },
              ),
      ),
    );
  }
}
