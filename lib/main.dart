import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_control/detalhes.dart';
import 'package:my_control/routeGenerator.dart';

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
