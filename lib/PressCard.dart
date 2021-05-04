import 'package:flutter/material.dart';

class Pression extends StatelessWidget {
  var press;
  Pression(this.press);
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
              child: Image.asset('images/gauge.png'),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Pression",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(),
            ),
            Text(
              press + 'hPa',
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
