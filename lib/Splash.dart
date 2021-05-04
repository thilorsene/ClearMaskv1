import 'package:apptest/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class Splash extends StatelessWidget {
  final FirebaseApp app;

  const Splash({Key key, this.app}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 5,
      backgroundColor: Colors.lightBlue[50],
      image: Image.asset('images/mask.png'),
      photoSize: 150,
      loadingText: Text('Clear Mask'),
      navigateAfterSeconds: MaterialApp(home: MyApp()),
    );
  }
}
