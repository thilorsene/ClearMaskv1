import 'package:apptest/AmpCard.dart';
import 'package:apptest/DurCard.dart';
import 'package:apptest/PressCard.dart';
import 'package:apptest/TempCard.dart';
import 'package:flutter/widgets.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:firebase_database/firebase_database.dart';

class Detail extends StatefulWidget {
  @override
  final List<BluetoothService> services;
  final ref;

  Detail(
    this.services,
    this.ref,
  );
  _DetailState createState() => _DetailState(services, ref);
}

class _DetailState extends State<Detail> {
  final databaseref = FirebaseDatabase.instance;
  final List<BluetoothService> services;
  final ref;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  final CHAR = "011c0000-0001-11e1-ac36-0002a5d5c51b";
//static const String CHAR = "";
  final SERV = "00000000-0001-11e1-9ab4-0002a5d5c51b";

  _DetailState(this.services, this.ref);

  String _selectedValuesJson = 'Nothing to show';

  bool startLog = false;
  var sessionId;
  var tmp = new DateTime.now().microsecondsSinceEpoch;
  var val1 = ['0', '0', '0', '0'];
  BluetoothCharacteristic characteristic;

  List<String> _selectedLanguages;

  String etat;
  /* Future<void> logDialog(BuildContext context, etat) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlutterTagging<Language>(
            initialItems: _selectedLanguages,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.green.withAlpha(30),
                hintText: 'Search Tags',
                labelText: 'Select Tags',
              ),
            ),
            findSuggestions: LanguageService.getLanguages,
            additionCallback: (value) {
              return Language(
                name: value,
                position: 0,
              );
            },
            onAdded: (language) {
              // api calls here, triggered when add to tag button is pressed
              return language;
            },
            configureSuggestion: (lang) {
              return SuggestionConfiguration(
                title: Text(lang.name),
                subtitle: Text(lang.position.toString()),
                additionWidget: Chip(
                  avatar: Icon(
                    Icons.add_circle,
                    color: Colors.white,
                  ),
                  label: Text('Add New Tag'),
                  labelStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w300,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
            configureChip: (lang) {
              return ChipConfiguration(
                label: Text(lang.name),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
                deleteIconColor: Colors.white,
              );
            },
            onChanged: () {
              setState(() {
                _selectedValuesJson = _selectedLanguages
                    .map<String>((lang) => '\n${lang.toJson()}')
                    .toList()
                    .toString();
                _selectedValuesJson =
                    _selectedValuesJson.replaceFirst('}]', '}\n]');
              });
            },
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
      ],
    );
            ),
          );
        });
  }
*/
  void initState() {
    super.initState();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == SERV) {
        List<Widget> characteristicsWidget = new List<Widget>();

        for (BluetoothCharacteristic characteristic1
            in service.characteristics) {
          if (characteristic1.uuid.toString() == CHAR) {
            setState(() {
              characteristic = characteristic1;
            });
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref1 = databaseref.reference();
    characteristic.setNotifyValue(true);
    //ShowCaracteristic(characteristic, ref1);
    print('CharTest : ${characteristic.uuid}');
    return Scaffold(
        appBar: AppBar(
          title: Text('Données'),
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: characteristic.value,
                builder: (context, snapshot) {
                  print('data : ${snapshot.data}');
                  var data = convertData(snapshot.data, ref1);
                  return Center(
                      child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Temperature(data[1]),
                        Pression(data[2])
                      ],
                    ),
                    //----------------------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Duree(data[3]),
                        Amplitude(data[4]),
                      ],
                    ),
                  ]));
                }),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: startLog
                            ? MaterialStateProperty.all(Colors.red)
                            : MaterialStateProperty.all(Colors.blue)),
                    onPressed: () {
                      setState(() {
                        startLog = !startLog;
                        sessionId = dateFormat.format(DateTime.now());
                      });
                      print('SessionId: $sessionId');
                    },
                    child: startLog ? Text('Arret log') : Text('Logger'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => {},
                    child: Text('Annoter'),
                  ),
                ])
          ],
        ));
  }

  Stream<List<String>> get valeurs async* {
    var timestamp;
    var duree;
    var pression;
    var amplitude;
    var temperature;

    characteristic.value.listen((value) {
      Uint8List bytes = Uint8List.fromList(value);
      ByteData bytes2 = ByteData.view(bytes.buffer);
      // Getdata(bytes2);
      timestamp = bytes2.getUint16(0, Endian.little);
      duree = bytes2.getUint16(2, Endian.little);
      pression = bytes2.getInt32(4, Endian.little);
      amplitude = bytes2.getInt16(8, Endian.little);
      temperature = bytes2.getUint16(10, Endian.little);

      print('Timestamp : $timestamp');
      print('Durée : $duree');
      print('Pression : $pression');
      print('Amplitude : $amplitude');
      print('Temperature : $temperature');

      setState(() {
        val1 = [
          (temperature / 10).toDouble().toString(),
          (pression / 10).toDouble().toString(),
          duree.toString(),
          amplitude.toString()
        ];
      });

      //if (startLog = true) {
      ref.child('Thilor').child('Thilor' + sessionId).push().set({
        'Timestamp': DateTime.now().microsecondsSinceEpoch,
        'Durée': duree,
        'Pression': pression,
        'Amplitude': amplitude,
        'Temperature': temperature
      }).asStream();
    });
    yield val1 = [
      (temperature / 10).toDouble().toString(),
      (pression / 10).toDouble().toString(),
      duree.toString(),
      amplitude.toString()
    ];
    await characteristic.setNotifyValue(true);
  }

  Future<List<String>> ShowCaracteristic(characteristic, ref) async {
    characteristic.value.listen((value) {
      Uint8List bytes = Uint8List.fromList(value);
      ByteData bytes2 = ByteData.view(bytes.buffer);
      // Getdata(bytes2);
      var timestamp = bytes2.getUint16(0, Endian.little);
      var duree = bytes2.getUint16(2, Endian.little);
      var pression = bytes2.getInt32(4, Endian.little);
      var amplitude = bytes2.getInt16(8, Endian.little);
      var temperature = bytes2.getUint16(10, Endian.little);

      print('Timestamp : $timestamp');
      print('Durée : $duree');
      print('Pression : $pression');
      print('Amplitude : $amplitude');
      print('Temperature : $temperature');

      val1 = [
        (temperature / 10).toDouble().toString(),
        (pression / 10).toDouble().toString(),
        duree.toString(),
        amplitude.toString()
      ];

      //if (startLog = true) {
      ref.child('Thilor').child('Thilor' + sessionId).push().set({
        'Timestamp': DateTime.now().microsecondsSinceEpoch,
        'Durée': duree,
        'Pression': pression,
        'Amplitude': amplitude,
        'Temperature': temperature,
      }).asStream();
    });
    await characteristic.setNotifyValue(true);
    return val1;
  }

  List<String> convertData(value, ref) {
    Uint8List bytes = Uint8List.fromList(value);
    ByteData bytes2 = ByteData.view(bytes.buffer);
    // Getdata(bytes2);
    var timestamp = bytes2.getUint16(0, Endian.little);
    var duree = (bytes2.getUint16(2, Endian.little) / 1000);
    var pression = (bytes2.getInt32(4, Endian.little) / 100);
    var amplitude = (bytes2.getInt16(8, Endian.little) / 100);
    var temperature = (bytes2.getUint16(10, Endian.little) / 10);

    print('Timestamp : $timestamp');
    print('Durée : $duree');
    print('Pression : $pression');
    print('Amplitude : $amplitude');
    print('Temperature : $temperature');
    if (startLog)
      ref.child('Thilor').child(sessionId).push().set({
        'Timestamp': DateTime.now().microsecondsSinceEpoch,
        'Durée': duree,
        'Pression': pression,
        'Amplitude': amplitude,
        'Temperature': temperature,
      });

    return [
      timestamp.toString(),
      temperature.toString(),
      pression.toString(),
      duree.toString(),
      amplitude.toString()
    ];
  }

  logData(data) {
    ref.child('Thilor').child(sessionId).push().set({
      'Timestamp': DateTime.now().microsecondsSinceEpoch,
      'Durée': data[3],
      'Pression': data[2],
      'Amplitude': data[4],
      'Temperature': data[1],
    }).asStream();
  }
}

/*
/// LanguageService
class Suggestion {
  /// Mocks fetching language from network API with delay of 500ms.
  static Future<List<Suggestion>> getLanguages(String query) async {
    await Future.delayed(Duration(milliseconds: 500), null);
    return <Suggestion>[
      Suggestion(name: 'JavaScript'),
      Suggestion(name: 'Python'),
      Suggestion(name: 'Java' ),
      Suggestion(name: 'PHP' ),
      Suggestion(name: 'C#'),
      Suggestion(name: 'C++'),
    ]
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

/// Language Class
class Language extends Taggable {
  ///
  final String name;

 

  /// Creates Language
  Language({
    this.name,
   });

  @override
  List<Object> get props => [name];

  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
  }''';
}
*/
