import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:liveloc/pages/login/login.dart';
import 'package:liveloc/services/auth.dart';
import 'package:liveloc/services/db_helper.dart';
import 'package:liveloc/services/prefs.dart';
import 'package:location/location.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Location location = Location();
  LocationData _locationData;
  StreamSubscription<LocationData> _locationSubscription;
  final dbHelper = new DBHelper();

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
        });
      }
    });
  }

  Future<void> _stopListen() async {
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
        automaticallyImplyLeading: false,
        title: Text('Live Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are u sure?'),
                  actions: [
                    FlatButton(
                      onPressed: () async {
                        final auth = new Auth();
                        await auth.signOut();
                        Get.off(LoginPage());
                        Get.snackbar(
                          'Logout successfully!',
                          'Thanks for using app!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: Text('OK'),
                    ),
                    FlatButton(
                      onPressed: () => Get.back(),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: Center(
        child: _locationData == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Permission status: $_permissionStatus'),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    'Location Update: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.0,
                    ),
                  ),
                  Text('Lat: ${_locationData.latitude.toString()}'),
                  Text('Lat: ${_locationData.longitude.toString()}'),
                  SizedBox(
                    height: 10.0,
                  ),
                ],
              ),
      ),
    );
  }
}
