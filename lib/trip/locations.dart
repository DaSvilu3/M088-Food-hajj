import 'package:flutter/material.dart';

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:photo_view/photo_view.dart';
class MyLocationPage extends StatefulWidget {
  MyLocationPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyLocationPageState createState() => new _MyLocationPageState();
}

class _MyLocationPageState extends State<MyLocationPage> {
  
  @override
  void initState(){
    super.initState();
  }

  var lang = 21.4154875;
  var lat  = 39.9;  

 
  @override
  Widget build(BuildContext context) {
  
    return new Scaffold(
      appBar: new AppBar(
        
        title: new Text(widget.title),
      ),
      body: new Center(
       child: new PhotoView(
          imageProvider: new ExactAssetImage("img/map.jpg"),
          backgroundColor: Colors.white,
          minScale: 0.1,
          maxScale: 4.0,
        )
      ),
       // This trailing comma makes auto-formatting nicer for build methods.
    );
  } 
}