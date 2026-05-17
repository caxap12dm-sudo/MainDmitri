import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/main_menu.dart';
import 'logic/game_engine.dart';
import 'services/bluetooth_service.dart';
import 'logic/game_coordinator.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => BluetoothService()),
        ChangeNotifierProvider(create: (_) => GameEngineWrapper()),
        ChangeNotifierProxyProvider2<GameEngineWrapper, BluetoothService, GameCoordinator>(
          create: (context) => GameCoordinator(
            engine: Provider.of<GameEngineWrapper>(context, listen: false),
            bluetooth: Provider.of<BluetoothService>(context, listen: false),
          ),
          update: (context, engine, bluetooth, previous) => previous ?? GameCoordinator(engine: engine, bluetooth: bluetooth),
        ),
      ],
      child: const DurakApp(),
    ),
  );
}

class GameEngineWrapper extends GameEngine with ChangeNotifier {
  @override
  void startNewGame() {
    super.startNewGame();
    notifyListeners();
  }

  @override
  void playCard(dynamic card, bool isPlayer) {
    super.playCard(card, isPlayer);
    notifyListeners();
  }

  @override
  void endTurn() {
    super.endTurn();
    notifyListeners();
  }

  @override
  void takeCards(bool isPlayer) {
    super.takeCards(isPlayer);
    notifyListeners();
  }
}

class DurakApp extends StatelessWidget {
  const DurakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Durak Bluetooth',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MainMenu(),
    );
  }
}
