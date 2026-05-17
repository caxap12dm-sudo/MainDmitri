import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:async';
import 'dart:typed_data';

class BluetoothService {
  BluetoothConnection? connection;
  bool get isConnected => connection != null && connection!.isConnected;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  String _buffer = "";

  Future<void> connect(BluetoothDevice device) async {
    connection = await BluetoothConnection.toAddress(device.address);
    connection!.input!.listen((Uint8List data) {
      _buffer += utf8.decode(data);
      _processBuffer();
    }).onDone(() {
      connection = null;
      _buffer = "";
    });
  }

  void _processBuffer() {
    int delimiterIndex;
    while ((delimiterIndex = _buffer.indexOf('\n')) != -1) {
      String message = _buffer.substring(0, delimiterIndex);
      _buffer = _buffer.substring(delimiterIndex + 1);
      if (message.isNotEmpty) {
        try {
          _messageController.add(jsonDecode(message));
        } catch (e) {
          print('Error decoding message: $e');
        }
      }
    }
  }

  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (isConnected) {
      String encodedMessage = jsonEncode(message) + '\n';
      connection!.output.add(Uint8List.fromList(utf8.encode(encodedMessage)));
      await connection!.output.allSent;
    }
  }

  void disconnect() {
    connection?.dispose();
    connection = null;
    _buffer = "";
  }
}
