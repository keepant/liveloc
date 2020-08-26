import 'package:firebase_database/firebase_database.dart';

class DBHelper {
  final databaseReference = FirebaseDatabase.instance.reference().child('users');

  void createUser({
    String id,
    String name,
    String email,
    bool isLocationShare,
    double latitude,
    double longitude,
  }) {
    databaseReference.child(id).set({
      'name': name,
      'email': email,
      'isLocationShare': true,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  void updateLocation({
    String id,
    double latitude,
    double longitude,
  }) {
    databaseReference.child(id).update({
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  void updateShareStatus({
    String id,
    bool isLocationShare,
  }) {
    databaseReference.child(id).update({
      'isLocationShare': isLocationShare,
    });
  }
}
