import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:liveloc/services/db_helper.dart';

class ListUser extends StatefulWidget {
  @override
  _ListUserState createState() => _ListUserState();
}

class _ListUserState extends State<ListUser> {
  List<Map<dynamic, dynamic>> lists = [];

  final dbHelper = new DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List users'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: StreamBuilder(
          stream: dbHelper.databaseReference.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              lists.clear();
              DataSnapshot dataValues = snapshot.data.snapshot;
              Map<dynamic, dynamic> values = dataValues.value;
              values.forEach((key, values) {
                lists.add(values);
              });

              return ListView.builder(
                shrinkWrap: true,
                itemCount: lists.length,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${lists[index]['name']}'),
                      Text('Latitude: ${lists[index]['latitude']}'),
                      Text('Longitude: ${lists[index]['longitude']}'),
                      Divider(),
                    ],
                  );
                },
              );
            }

            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
