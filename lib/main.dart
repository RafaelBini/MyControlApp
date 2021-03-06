import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:my_control/detalhes.dart';
import 'package:my_control/routeGenerator.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyControl',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _messageText = "Waiting for message";
  String _tokenText = "Waiting for token";
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  void initState() {
    FlutterAppBadger.removeBadge();
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "$message";
        });
        print("OnMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "$message";
        });
        print("OnLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "$message";
        });
        print("OnResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) {
      assert(token != null);
      setState(() {
        _tokenText = "Push Message Token: $token";
      });
      print(_tokenText);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Hero(
          tag: "finha",
          child: GestureDetector(
            child: Image.asset("resources/icon.png"),
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => TestePage())),
          ),
        ),
        title: Text(
          'MyControl - Saldos',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder(
        stream: Firestore.instance.collection('contas').snapshots(),
        builder: (ctx, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );

          return ListView.separated(
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (ctx, index) {
              DocumentSnapshot doc = snapshot.data.documents[index];

              if (doc["notificar"] &&
                  (doc["saldo inicial"] == null
                      ? false
                      : doc["saldo inicial"] <= doc["saldo atual"])) {
                return Container(
                  color: Colors.orangeAccent,
                  child: ListTile(
                    leading: Icon(Icons.error),
                    title: Text(doc.documentID),
                    trailing: Text(
                      'R\$ ${(doc["saldo atual"] as double).toStringAsFixed(2)}',
                    ),
                    onTap: () {
                      var route = new MaterialPageRoute(
                        builder: (ctx) => new DetalhesPage(doc),
                      );
                      Navigator.of(context).push(route);
                    },
                  ),
                );
              } else {
                return ListTile(
                  title: Text(doc.documentID),
                  trailing: Text(
                    'R\$ ${(doc["saldo atual"] as double).toStringAsFixed(2)}',
                  ),
                  onTap: () {
                    var route = new MaterialPageRoute(
                      builder: (ctx) => new DetalhesPage(doc),
                    );
                    Navigator.of(context).push(route);
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}

class TestePage extends StatelessWidget {
  final Widget myLogo = Image.asset(
    "resources/icon.png",
    width: 100,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informações"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 50),
            child: Hero(
              tag: "finha",
              child: Center(
                child: Draggable(
                  feedbackOffset: Offset(-100, -110),
                  feedback: myLogo,
                  childWhenDragging: myLogo,
                  child: myLogo,
                ),
              ),
            ),
          ),
          Text(
            "MyControl",
            style: TextStyle(fontSize: 28),
          ),
          SizedBox(height: 100),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              "Rafael Bini",
              style: TextStyle(fontSize: 27),
            ),
          ),
        ),
      ),
    );
  }
}
