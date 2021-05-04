import 'package:flutter/material.dart';

class Duree extends StatelessWidget {
  var duree;
  Duree(this.duree);

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
                child: Image.asset('images/time.png'),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Durée",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Container(),
              ),
              Text(
                duree + 's',
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
