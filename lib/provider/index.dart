import 'package:flutter/material.dart';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:photo_view/photo_view.dart';
class MyProviderPage extends StatefulWidget {
  MyProviderPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLocationPageState createState() => new _MyLocationPageState();
}

class _MyLocationPageState extends State<MyProviderPage> {
  
  @override
  void initState(){
    super.initState();
    getLocations();
  }
 
  @override
  Widget build(BuildContext context) {
  
    return new Scaffold(
      appBar: new AppBar(
        
        title: new Text(widget.title),
      ),
      body: new Center(
       child: new ListView(
         children: _buildLocationListView("num_m", 2),
       )
      ),
    );
  } 
  List<Widget> _buildLocationListView(String type, int choose) {
    List<Widget> _list = [];
    for (int i = 0; i < locations.length; i++) {
      Map map = locations[i];
      Color dedctor = Colors.blue;
      if (map[type] >= map["can_handle"]) {
        dedctor = Colors.red;
      } else if (map["can_handle"] / 2 <= map[type])
        dedctor = Colors.deepOrange;
      else {
        dedctor = Colors.yellow;
      }
      ListTile tile = new ListTile(
        title: new Text(map["name"] + " - morning"),
        subtitle: new Text("40 meals"),
        leading: new CircleAvatar(
          child: new Text((i + 1).toString()),
          backgroundColor: dedctor,
        ),
      );
      _list.add(tile);
    }
    return _list;
  }



 List locations = [];
  List booking = [];
  void getLocations() async {
    locations = [];
    booking = [];
    FirebaseDatabase.instance
        .reference()
        .child("/locations")
        .once()
        .then((snapshot) {
      FirebaseDatabase.instance
          .reference()
          .child("/booking")
          .once()
          .then((val) {
        List temp = snapshot.value;
        print("books");
        print(val.value);
        List bo = val.value;
        bo.forEach((f){
          if (f != null) booking.add(f);
        });
        temp.forEach((t) {
          if (t == null) return;
          Map m = new Map();
          print("temp");
          print(t);
          if (t == null) return;
          int number_m = 0;
          int number_d = 0;
          int number_l = 0;

          booking.forEach((books) {
            if (books == null) return;
            if (books["location"] == t["code"]) {
              String string = books["type"];

              print(books["type"]);
              if (string.indexOf("m") != -1) number_m += books["number"];

              if (string.indexOf("l") != -1) number_l += books["number"];
              if (string.indexOf("d") != -1) number_d += books["number"];
            }
          });
          m["num_m"] = number_m;
          m["num_l"] = number_l;
          m["num_d"] = number_d;
          m["can_handle"] = t["can_handle"];
          m["name"] = t["name"];
          locations.add(m);
        });
        setState(() {
          print("refreshed");
        });
      });
    });
  }
}