import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_coordinator.dart';
import 'lobby_screen.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Durak Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Provider.of<GameCoordinator>(context, listen: false).setHost(true);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LobbyScreen(isHost: true)),
                );
              },
              child: const Text('Host Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<GameCoordinator>(context, listen: false).setHost(false);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LobbyScreen(isHost: false)),
                );
              },
              child: const Text('Join Game'),
            ),
          ],
        ),
      ),
    );
  }
}
