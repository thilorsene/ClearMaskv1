import 'package:flutter/material.dart';

class Temperature extends StatelessWidget {
  var tempe;
  Temperature(this.tempe);
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
                child: Image.asset('images/temperature.png'),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Temperature",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                tempe + '°C',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
