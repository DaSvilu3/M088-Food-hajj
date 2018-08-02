import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'dart:convert';
import '../util/db_helper.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'locations.dart';
class MyProfilePage extends StatefulWidget {
  MyProfilePage({Key key, this.title, this.map}) : super(key: key);

  Map map;

  final String title;

  @override
  _MyProfilePageState createState() => new _MyProfilePageState(map: map);
}

class _MyProfilePageState extends State<MyProfilePage> {
  Map map;
  _MyProfilePageState({this.map});
  @override
  void initState() {
    super.initState();
    init_periods();
    getLocations();
  }

  @override
  Widget build(BuildContext context) {
    var ref = FirebaseDatabase.instance.reference();
    Size size = MediaQuery.of(context).size;
    return new DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "MORNING"),
              Tab(
                text: "LUNCH",
              ),
              Tab(text: "DINNER"),
            ],
          ),
          title: Text('CHOOSE TIMING'),
        ),
        body: TabBarView(
          children: [
            new Container(
              child: new ListView(
                children: _buildLocationListView("num_m", 0),
              ),
            ),
            new Container(
              child: new ListView(
                children: _buildLocationListView("num_l", 3),
              ),
            ),
            new Container(
              child: new ListView(
                children: _buildLocationListView("num_d", 6),
              ),
            ),
          ],
        ),
        floatingActionButton: new FloatingActionButton(
          child: new Icon(Icons.map),
          onPressed: (){
            Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new MyLocationPage(title: "Map",)));
          },
        ),
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
        title: new Text(map["name"]),
        subtitle: new Text(
          "still : " + 
         (map["can_handle"] - map[type]).toString() +
            " out " +
            map["can_handle"].toString() +
            " meals"),
        leading: new CircleAvatar(
          child: new Text((i + 1).toString()),
          backgroundColor: dedctor,
        ),
      );
      _list.add(tile);

      List<Widget> _sub_list = [];
      for (int i = choose; i < choose + 3; i++) {
        int number = 0;
        booking.forEach((book) {
          print("------");
          if (book == null) return;
          String t = book["type"];
          String code = book["trip"];
          String tes = type[type.length - 1];
          if (t.indexOf(tes) != -1 &&
              code.indexOf("OM_1333") != -1 &&
              book["p"] == i) {
            number = (book["number"]);
          } else if (t.indexOf(tes) != -1) {
            print("noo"); 
          }
        });
        _list.add(new ListTile(
            title: new Text(periods[i]["time"]),
            subtitle: new Text(number.toString()),
            leading: new FlatButton(
              child: new Icon(Icons.add, color: Colors.white,),
              color: Colors.blue,
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false, 
                  builder: (BuildContext context) {
                    return new AlertDialog(
                      title: new Text('Sure?'),
                      content: new SingleChildScrollView(
                        child: new Text("Are you sure to order in this time " + periods[i]["time"] +" ?"),
                      ),
                      actions: <Widget>[
                        new FlatButton(
                          child: new Text('No', style: new TextStyle(color: Colors.white),),
                          color: Colors.red,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        new FlatButton(
                          child: new Text('Yes', style: new TextStyle(color: Colors.white),),
                          color: Colors.blueAccent,
                          onPressed: () {
                            Map<String, dynamic> map2 = new Map<String, dynamic>();
                            map2["location"] = 3;
                            map2["number"] = 40;
                            map2["type"] = type[type.length - 1];
                            map2["trip"] = "OM_1333";
                            map2["p"]    = i;
                            var rng = new Random();
                           
                            var uuid = new Uuid().v1();
                            FirebaseDatabase.instance.reference().child("/booking/5/").set(map2).then((onValue){
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            });
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            )));
      }

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

  List periods = [];
  void init_periods() {
    String text = r'''
[{
  "id" : 1,
  "time" : "6:00-7:00",
  "type" : "m"
}, {
  "id" : 2,
  "time" : "7:00-8:00",
  "type" : "m"
}, {
  "id" : 3,
  "time" : "8:00-9:00",
  "type" : "m"
}, {
  "id" : 4,
  "time" : "11:30-12:30",
  "type" : "l"
}, {
  "id" : 5,
  "time" : "12:30-1:30",
  "type" : "l"
}, {
  "id" : 6,
  "time" : "1:30-2:30",
  "type" : "l"
}, {
  "id" : 7,
  "time" : "6:00:7:00",
  "type" : "d"
}, {
  "id" : 8,
  "time" : "7:00-8:00",
  "type" : "d"
}, {
  "id" : 9,
  "time" : "8:00-9:00",
  "type" : "d"
} ]
  ''';
    List prds = json.decode(text);
    periods.addAll(prds);
    print("objects");
  }
}
