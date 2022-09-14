import 'dart:convert';
// import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bluetooth scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Bluetooth Scanner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothManager bluetoothManager = BluetoothManager.instance;

  bool _connected = false;
  BluetoothDevice _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothManager.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothManager.isConnected;

    bluetoothManager.state.listen((state) {
      print('cur device status: $state');

      switch (state) {
        case BluetoothManager.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothManager.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  void _onConnect() async {
    if (_device != null && _device.address != null) {
      await bluetoothManager.connect(_device);
    } else {
      setState(() {
        tips = 'please select device';
      });
      print('please select device');
    }
  }

  void _onDisconnect() async {
    await bluetoothManager.disconnect();
  }

  void _sendData() async {
    List<int> bytes = latin1.encode('Hello world!\n\n\n').toList();

    // Set codetable west. Add import 'dart:typed_data';
    // List<int> bytes = Uint8List.fromList(List.from('\x1Bt'.codeUnits)..add(6));
    // Text with special characters
    // bytes += latin1.encode('blåbærgrød\n\n\n');

    await bluetoothManager.writeData(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            bluetoothManager.startScan(timeout: Duration(seconds: 4)),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(tips),
                  ),
                ],
              ),
              Divider(),
              StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothManager.scanResults,
                initialData: [],
                builder: (c, snapshot) => Column(
                  children: snapshot.data
                      .map((d) => ListTile(
                            title: Text(d.name ?? ''),
                            subtitle: Text(d.address),
                            onTap: () async {
                              setState(() {
                                _device = d;
                              });
                            },
                            trailing:
                                _device != null && _device.address == d.address
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                          ))
                      .toList(),
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ElevatedButton(
                          child: Text('connect'),
                          onPressed: _connected ? null : _onConnect,
                        ),
                        SizedBox(width: 10.0),
                        ElevatedButton(
                          child: Text('disconnect'),
                          onPressed: _connected ? _onDisconnect : null,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      child: Text('Send test data'),
                      onPressed: _connected ? _sendData : null,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: bluetoothManager.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => bluetoothManager.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () =>
                    bluetoothManager.startScan(timeout: Duration(seconds: 4)));
          }
        },
      ),
    );
  }
}
