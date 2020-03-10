# flutter_bluetooth_basic

Flutter plugin that allows to find bluetooth devices & send raw bytes data.
Supports both Android and iOS.

Inspired by [bluetooth_print](https://github.com/thon-ju/bluetooth_print).


## Main Features
* Android and iOS support
* Scan for bluetooth devices
* Send raw `List<int> bytes` data to a device


## Getting Started

For a full example please check */example* folder. Here are only the most important parts of the code to illustrate how to use the library.

```dart
BluetoothManager bluetoothManager = BluetoothManager.instance;
BluetoothDevice _device;

bluetoothManager.startScan(timeout: Duration(seconds: 4));
bluetoothManager.state.listen((state) {
    switch (state) {
    case BluetoothManager.CONNECTED:
        // ...
        break;
    case BluetoothManager.DISCONNECTED:
        // ...
        break;
    default:
        break;
    }
});
// bluetoothManager.scanResults is a Stream<List<BluetoothDevice>> sending the found devices.

// _device = <from bluetoothManager.scanResults>

await bluetoothManager.connect(_device);

List<int> bytes = latin1.encode('Hello world!\n').toList();
await bluetoothManager.writeData(bytes);

await bluetoothManager.disconnect();
```

## See also
* Example of usage in a project: [esc_pos_printer](https://github.com/andrey-ushakov/esc_pos_printer)
