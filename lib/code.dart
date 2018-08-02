
import 'package:flutter/material.dart';
import 'trip/locations.dart';
import 'trip/profile.dart';
import 'util/db_helper.dart';
import 'provider/index.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
class MyCodePage extends StatefulWidget {
  MyCodePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyCodePageState createState() => new _MyCodePageState();
}

class _MyCodePageState extends State<MyCodePage> {
  
  @override
  void initState(){
    super.initState();
  }
  String key = "";
bool _loading = false;

      void _onLoading() {
        setState(() {
          _loading = true;
          new Future.delayed(new Duration(seconds: 3), _login);
        });
      }


      Future _login() async{
        setState((){
          _loading = false;
        });
      }
 
  @override
  Widget build(BuildContext context) {

    var body = new Container(
        margin: new EdgeInsets.only(top: 40.0, right: 20.0, left: 20.0),
        child: new Column(
         
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Text(
              'Please Enter your campaign code here : ',
              style: new TextStyle(fontSize: 25.0),
            ),
            new Text("No need for debuging"),
            new Container(
              margin: new EdgeInsets.all(10.0),
              padding: new EdgeInsets.all(10.0),
              child: new TextField (  
                decoration: new InputDecoration(
                  labelText: "CODE",
                  hintText: "NO need of code while debuging"
                ),
                onChanged: (str){
                  setState(() {
                    key = str;                 
                  });
                },
              ) ,
            ),
            new FlatButton(
              
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.bookmark_border, color: Colors.white, size: 25.0,),
                  new Text("Book Now", style: new TextStyle(color: Colors.white, fontSize: 20.0),)
                ],
              ),
              color: Colors.green,
              onPressed: (){
                _onLoading();
                FirebaseDatabase.instance.reference().child("/trips/"+key).once().then((val){
                  if (val.value != null){
                    Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new MyProfilePage(map: val.value,)));
                  }
                });
              },
            )
          ],
        ),
      );

      var bodyProgress = new Container(
            child: new Stack(
              children: <Widget>[
                body,
                new Container(
                  alignment: AlignmentDirectional.center,
                  decoration: new BoxDecoration(
                    color: Colors.white70,
                  ),
                  child: new Container(
                    decoration: new BoxDecoration(
                      color: Colors.green[200],
                      borderRadius: new BorderRadius.circular(10.0)
                    ),
                    width: 300.0,
                    height: 200.0,
                    alignment: AlignmentDirectional.center,
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Center(
                          child: new SizedBox(
                            height: 50.0,
                            width: 50.0,
                            child: new CircularProgressIndicator(
                              value: null,
                              strokeWidth: 7.0,
                            ),
                          ),
                        ),
                        new Container(
                          margin: const EdgeInsets.only(top: 25.0),
                          child: new Center(
                            child: new Text(
                              "loading.. wait...",
                              style: new TextStyle(
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );  
    return new Scaffold(
      appBar: new AppBar(
        
        title: new Text(widget.title),
      ),
      body: _loading ? bodyProgress : body,
      floatingActionButton: new FloatingActionButton(
        child: new Icon(Icons.monetization_on),
        
        onPressed: (){
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new MyProviderPage(title: "PROVIDER",) ));
        },
      )
      
      );
  }

  void get_profile() async{
    final ref = FirebaseDatabase.instance.reference().child("/trips/"+key);
    ref.once().then((val){
      if (val.value == null) {
        print("Not good code.\n enter new code");
      }
      else {
        print("Good");
        Map map = val.value;
        print(map["number"]);
        LocalDBHelper helper = new LocalDBHelper();
        String key = "profile";
        String json = helper.convertMapToJSON(map);
        helper.saveJSON(key, json).then((onValue){
          Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> new MyProfilePage(title: "PROFILE",map: map)));
        });
      }
    });
  }
}
