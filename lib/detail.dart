import 'package:apptest/AmpCard.dart';
import 'package:apptest/DurCard.dart';
import 'package:apptest/PressCard.dart';
import 'package:apptest/Identification.dart';
import 'package:apptest/TempCard.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:typed_data';
import 'package:flutter_chips_input/flutter_chips_input.dart';
import 'appdata.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

class _DetailState extends State<Detail> with WidgetsBindingObserver {
  final databaseref = FirebaseDatabase.instance;
  final List<BluetoothService> services;
  final ref;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  var user;
  String _masque = 'FFP2';
  final CHAR = "011c0000-0001-11e1-ac36-0002a5d5c51b";
//static const String CHAR = "";
  final SERV = "00000000-0001-11e1-9ab4-0002a5d5c51b";

  _DetailState(this.services, this.ref);

  bool startLog = false;
  var sessionId;
  var tmp = new DateTime.now().microsecondsSinceEpoch;
  var val1 = ['0', '0', '0', '0'];
  BluetoothCharacteristic characteristic;

  var mockResults = <AppProfile>[
    AppProfile('En marche'),
    AppProfile('Au repos'),
    AppProfile('Course'),
    AppProfile('Marche rapide'),
    AppProfile('Escalier'),
    AppProfile('Tousser'),
    AppProfile('Forte respiration'),
    AppProfile('Port du masque Sous le nez'),
    AppProfile('Port du masque au dessu du menton'),
    AppProfile('Mauvais port'),
    AppProfile('Parler'),
    AppProfile('Capteur qui se decroche'),
    AppProfile('Masque non porte'),
  ];
  final _chipKey = GlobalKey<ChipsInputState>();
  var etat = [AppProfile('Au repos')];
  logDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
                scrollable: true,
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ChipsInput(
                      key: _chipKey,
                      initialValue: etat,
                      keyboardAppearance: Brightness.dark,
                      textCapitalization: TextCapitalization.words,
                      enabled: true,
                      maxChips: 7,
                      textStyle: const TextStyle(
                          height: 1.5, fontFamily: 'Roboto', fontSize: 16),
                      decoration: const InputDecoration(
                        labelText: 'Ajouter tag',
                      ),
                      findSuggestions: (String query) {
                        if (query.isNotEmpty) {
                          var lowercaseQuery = query.toLowerCase();
                          return mockResults.where((profile) {
                            return profile.name
                                .toLowerCase()
                                .contains(query.toLowerCase());
                          }).toList(growable: false)
                            ..sort((a, b) => a.name
                                .toLowerCase()
                                .indexOf(lowercaseQuery)
                                .compareTo(b.name
                                    .toLowerCase()
                                    .indexOf(lowercaseQuery)));
                        }
                        return mockResults;
                      },
                      onChanged: (data) {
                        etat = data;
                        print('Chips : $etat');
                        print('Chips2 : $data');
                      },
                      chipBuilder: (context, state, profile) {
                        return InputChip(
                          key: ObjectKey(profile),
                          label: Text(profile.name),
                          onDeleted: () => state.deleteChip(profile),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                      suggestionBuilder: (context, state, profile) {
                        return ListTile(
                          key: ObjectKey(profile),
                          title: Text(profile.name),
                          onTap: () {
                            state.selectSuggestion(profile);
                          },
                        );
                      },
                    ),
                    DropdownButton<String>(
                        value: _masque,
                        //elevation: 5,
                        style: TextStyle(color: Colors.black),
                        items: <String>[
                          'FFP2',
                          'Masque Churirgical',
                          'Masque en tissu',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text(
                          "Choix du masque",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onChanged: (String value) {
                          setState(() {
                            _masque = value;
                          });
                        }),
                    SizedBox(height: 15),
                    IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () => Navigator.pop(context))
                  ],
                ));
          });
        });
  }

  void initState() {
    super.initState();
    for (BluetoothService service in services) {
      if (service.uuid.toString() == SERV) {
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
    WidgetsBinding.instance.addObserver(this);
    user = appData.text;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print('Background');
      ShowCaracteristic();
    }
    if (state == AppLifecycleState.resumed) {
      // came back to Foreground
      print('Foreground');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref1 = databaseref.reference();
    characteristic.setNotifyValue(true);
    print('CharTest : ${characteristic.uuid}');
    //ShowCaracteristic(characteristic);
    //didChangeAppLifecycleState();
    return Scaffold(
        appBar: AppBar(
          title: Text('Donn??es'),
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
                        //sessionId = dateFormat.format(DateTime.now());
                        sessionId = DateTime.now().millisecondsSinceEpoch;
                      });
                      print('SessionId: $sessionId');
                    },
                    child: startLog
                        ? Text('Arret enregistrement')
                        : Text('Enregistrer'),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => {logDialog(context)},
                    child: Text('Annoter'),
                  ),
                ])
          ],
        ));
  }

  List<String> convertData(value, ref) {
    Uint8List bytes = Uint8List.fromList(value);
    ByteData bytes2 = ByteData.view(bytes.buffer);
    var timestamp = bytes2.getUint16(0, Endian.little);
    var duree = (bytes2.getUint16(2, Endian.little) / 1000);
    var pression = (bytes2.getInt32(4, Endian.little) / 100);
    var amplitude = (bytes2.getInt16(8, Endian.little) / 100);
    var temperature = (bytes2.getUint16(10, Endian.little) / 10);
/*
    print('Timestamp Bluetile : $timestamp');
    print('Timestamp Smartphone : ${DateTime.now().microsecondsSinceEpoch}');
    print('Dur??e : $duree');
    print('Pression : $pression');
    print('Amplitude : $amplitude');
    print('Temperature : $temperature');
    print('Etat : $etat');
    print('User : $user');
*/
    String added = '';
    for (var e in etat) {
      added += (e.name + ',');
    }

    if (startLog) {
      ref
          .child(user)
          .child(
              dateFormat.format(DateTime.fromMillisecondsSinceEpoch(sessionId)))
          .push()
          .set({
        'Moment': dateFormat.format(DateTime.now()),
        'Timestamp': timestamp,
        'Dur??e': duree,
        'Pression': pression,
        'Amplitude': amplitude,
        'Temperature': temperature,
        'Etat': added,
        'Type_masque': _masque
      });
    }

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
      'Dur??e': data[3],
      'Pression': data[2],
      'Amplitude': data[4],
      'Temperature': data[1],
    }).asStream();
  }

  ShowCaracteristic() async {
    characteristic.value.listen((value) {
      Uint8List bytes = Uint8List.fromList(value);
      ByteData bytes2 = ByteData.view(bytes.buffer);
      var timestamp = bytes2.getUint16(0, Endian.little);
      var duree = (bytes2.getUint16(2, Endian.little) / 1000);
      var pression = (bytes2.getInt32(4, Endian.little) / 100);
      var amplitude = (bytes2.getInt16(8, Endian.little) / 100);
      var temperature = (bytes2.getUint16(10, Endian.little) / 10);

      print('Timestamp Bluetile : $timestamp');
      print('Timestamp Smartphone : ${DateTime.now().microsecondsSinceEpoch}');
      print('Dur??e : $duree');
      print('Pression : $pression');
      print('Amplitude : $amplitude');
      print('Temperature : $temperature');
      print('Etat : $etat');
      print('User : $user');

      String added = '';
      for (var e in etat) {
        added += (e.name + ',');
      }

      if (startLog) {
        print('Log Start');
        ref
            .child(user)
            .child(dateFormat
                .format(DateTime.fromMillisecondsSinceEpoch(sessionId)))
            .push()
            .set({
          'Moment': dateFormat.format(DateTime.now()),
          'Timestamp': timestamp,
          'Dur??e': duree,
          'Pression': pression,
          'Amplitude': amplitude,
          'Temperature': temperature,
          'Etat': added,
          'Type_masque': _masque
        });
      }
    });
  }
}

class AppProfile {
  final String name;

  const AppProfile(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppProfile &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return name;
  }
}
