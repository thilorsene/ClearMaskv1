import 'dart:typed_data';

import 'package:apptest/answer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'question.dart';
import 'answer.dart';
import 'package:firebase_database/firebase_database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final FirebaseApp app;
  MyApp({this.app});

  final FlutterBlue flutterBlue = FlutterBlue.instance;
  final List<BluetoothDevice> devicesList = new List<BluetoothDevice>();
  final Map<Guid, List<int>> readValues = new Map<Guid, List<int>>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var qi = 0;
  final databaseref = FirebaseDatabase.instance;

  void answerQuestion() {
    setState(() {
      qi += 1;
    });
    print(qi);
  }

  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = new List<Container>();
    for (BluetoothDevice device in widget.devicesList) {
      if (device.name == 'MASK-xx') {
        containers.add(
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                          device.name == '' ? '(unknown device)' : device.name),
                      Text(device.id.toString()),
                    ],
                  ),
                ),
                FlatButton(
                  color: Colors.blue,
                  child: Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    widget.flutterBlue.stopScan();
                    try {
                      await device.connect();
                    } catch (e) {
                      if (e.code != 'already_connected') {
                        throw e;
                      }
                    } finally {
                      _services = await device.discoverServices();
                    }
                    setState(() {
                      _connectedDevice = device;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();
    if (characteristic.properties.notify) {
      final ref = databaseref.reference();
      ShowCaracteristic(characteristic, ref);
    }
    return buttons;
  }

  static const String CHAR = "011c0000-0001-11e1-ac36-0002a5d5c51b";
//static const String CHAR = "";
  static const String SERV = "00000000-0001-11e1-9ab4-0002a5d5c51b";

  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();

    for (BluetoothService service in _services) {
      if (service.uuid.toString() == SERV) {
        List<Widget> characteristicsWidget = new List<Widget>();

        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.uuid.toString() == CHAR) {
            characteristicsWidget.add(
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(characteristic.uuid.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        ..._buildReadWriteNotifyButton(characteristic),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text('Value: ' +
                            widget.readValues[characteristic.uuid].toString()),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              ),
            );
          }
        }
        containers.add(
          Container(
            child: ExpansionTile(
                title: Text(service.uuid.toString()),
                children: characteristicsWidget),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) {
    final ref = databaseref.reference();
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('My First One'),
      ),
      body:
          _buildView(), /*
                Column(
              children: [
                Question(questions[qi]),
                ElevatedButton(
                  onPressed: () {
                    ref
                        .child('Data')
                        .push()
                        .child('Good')
                        .set('karma')
                        .asStream();
                    print('Saved Succesfully');
                  },
                  child: Text('Save'),
                ),
                Answer(answerQuestion),
                Answer(answerQuestion),
              ],
            )*/
    ));
  }

  ShowCaracteristic(characteristic, ref) async {
    characteristic.value.listen((value) {
      Uint8List bytes = Uint8List.fromList(value);
      ByteData bytes2 = ByteData.view(bytes.buffer);

      var timestamp = bytes2.getUint16(0, Endian.little);
      print('Timestamp : $timestamp');

      var tmp = new DateTime.now().microsecondsSinceEpoch;
      print('fulutter timestamp : $tmp');

      var duree = bytes2.getUint16(2, Endian.little);
      print('Durée : $duree');

      var pression = bytes2.getInt32(4, Endian.little);
      print('Pression : $pression');

      var amplitude = bytes2.getInt16(8, Endian.little);
      print('Amplitude : $amplitude');

      var temperature = bytes2.getUint16(10, Endian.little);
      print('Temperature : $temperature');

      /*var val1 = [
        duree.toString(),
        pression.toString(),
        amplitude.toString(),
        temperature.toString()
      ];
      this.val.add(val1);*/
      ref.child('Clear_Mask_Test').push().child('Thilor').set({
        'Timestamp': timestamp,
        'Durée': duree,
        'Pression': pression,
        'Amplitude': amplitude,
        'Temperature': temperature
      }).asStream();
    });
    await characteristic.setNotifyValue(true);
  }
}