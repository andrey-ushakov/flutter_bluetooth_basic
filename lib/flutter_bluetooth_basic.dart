import 'dart:async';

import 'package:flutter/services.dart';

class FlutterBluetoothBasic {
  static const MethodChannel _channel =
      const MethodChannel('flutter_bluetooth_basic');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
