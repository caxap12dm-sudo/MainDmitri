import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../services/bluetooth_service.dart';
import 'game_screen.dart';

class LobbyScreen extends StatefulWidget {
  final bool isHost;
  const LobbyScreen({super.key, required this.isHost});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  List<BluetoothDevice> devices = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.bluetoothAdvertise,
      Permission.location,
    ].request();

    if (statuses.values.every((status) => status.isGranted)) {
      _scanDevices();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions required for Bluetooth')),
        );
      }
    }
  }

  void _scanDevices() async {
    setState(() => isScanning = true);
    FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        if (!devices.any((d) => d.address == r.device.address)) {
          devices.add(r.device);
        }
      });
    }).onDone(() {
      setState(() => isScanning = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothService = Provider.of<BluetoothService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHost ? 'Host Lobby' : 'Join Lobby'),
        actions: [
          if (isScanning)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return ListTile(
            title: Text(device.name ?? 'Unknown Device'),
            subtitle: Text(device.address),
            onTap: () async {
              try {
                await bluetoothService.connect(device);
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen()),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to connect: $e')),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
