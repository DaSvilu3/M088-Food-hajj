import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'code.dart';
import 'provider/index.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hajj',
      theme: new ThemeData(
        primarySwatch: Colors.red,
        primaryColor: Colors.green
      ),
      home: new MyCodePage(title: 'Hajj Food Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState(){
    super.initState();
    var obj = new GetFromFB();
    obj.getData();
  }

  void _incrementCounter() {
    setState(() {
    
      _counter++;
    });
  }

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

    var body = new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            new Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      );


    var progre = new Container(
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
                      color: Colors.blue[200],
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
      body: new Container( 
        decoration: new BoxDecoration(
                color: Colors.blue[200]
              ),
        child: _loading ? progre : body,
      ),
      floatingActionButton: new FloatingActionButton(
        tooltip: 'Increment',
        onPressed: (){
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new MyProviderPage(title: "PROVIDER",) ));
        },
        child: new Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  
}

class GetFromFB {

  Future<List> getData(){
    final ref = FirebaseDatabase.instance.reference();

    ref.child("/").once().then((val){
      print(val.value);
    });
  }
}