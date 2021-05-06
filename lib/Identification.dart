import 'package:apptest/main.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'appdata.dart';

class Identification extends StatefulWidget {
  @override
  _IdentificationState createState() => _IdentificationState();
}

var user1;

class _IdentificationState extends State<Identification> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<String> _user;

  final myController = TextEditingController();

  Future<String> findUser() async {
    final SharedPreferences prefs = await _prefs;
    final String user = (prefs.getString('User') ?? '');
    return user;
  }

  Future<void> addUser(String user) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString("User", user);
  }

  Future<void> clearUser() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove("User");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clear Mask Test'),
      ),
      body: Center(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
            FutureBuilder<String>(
                future: findUser(),
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const CircularProgressIndicator();
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return snapshot.data.isNotEmpty
                            ? Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Column(children: <Widget>[
                                  SizedBox(height: 10),
                                  Icon(
                                    Icons.account_circle,
                                    size: 100,
                                    color: Colors.blue,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 20),
                                      Container(
                                        width: 250.0,
                                        child: Text('${snapshot.data}',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 25)),
                                      ),
                                      SizedBox(width: 25)
                                    ],
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      appData.text = snapshot.data;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyApp()));
                                    },
                                    child: Text('Continuer'),
                                  ),
                                  SizedBox(height: 20),
                                  RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10.0),
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: 'Changer de profil',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  clearUser();
                                                  setState(() {});
                                                })
                                        ]),
                                  )
                                ]))
                            : Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                child: Column(children: <Widget>[
                                  SizedBox(height: 15),
                                  Icon(
                                    Icons.account_circle,
                                    size: 100,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      SizedBox(width: 25),
                                      Container(
                                          width: 250.0,
                                          child: TextField(
                                            controller: myController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                              labelText: 'Entrez votre nom',
                                            ),
                                          )),
                                      SizedBox(width: 25)
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  ElevatedButton(
                                    onPressed: () {
                                      addUser(myController.text);
                                      appData.text = myController.text;
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MyApp()));
                                    },
                                    child: Text('Continuer'),
                                  ),
                                  SizedBox(height: 15)
                                ]));
                      }
                  }
                }),
          ])),
    );
  }
}
