import 'package:flutter/material.dart';

class Amplitude extends StatelessWidget {
  var ampli;
  Amplitude(this.ampli);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Card(
      child: Container(
        width: 150,
        height: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              width: 100,
              height: 100,
              child: Image.asset('images/breathing.png'),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Amplitude",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              ampli + 'Pa',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    ));
  }
}
