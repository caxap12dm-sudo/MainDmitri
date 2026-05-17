import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../logic/game_coordinator.dart';
import '../widgets/card_widget.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final coordinator = Provider.of<GameCoordinator>(context);
    final engine = coordinator.engine;

    return Scaffold(
      backgroundColor: Colors.green[800],
      appBar: AppBar(
        title: Text(coordinator.isHost ? 'Durak (Host)' : 'Durak (Client)'),
        actions: [
          if (coordinator.isHost)
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => coordinator.startHostGame(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Opponent hand
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 4,
              children: engine.opponentHand
                  .map((card) => CardWidget(card: card, isFaceUp: false))
                  .toList(),
            ),
          ),
          const Spacer(),
          // Table
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (engine.trumpCard != null)
                Column(
                  children: [
                    const Text('Trump', style: TextStyle(color: Colors.white)),
                    CardWidget(card: engine.trumpCard!),
                  ],
                ),
              const SizedBox(width: 20),
              Wrap(
                spacing: 10,
                children: engine.table.map((entry) {
                  return Column(
                    children: [
                      CardWidget(card: entry.key),
                      if (entry.value != null) CardWidget(card: entry.value!),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
          if (engine.winner != null)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Winner: ${engine.winner}',
                style: const TextStyle(fontSize: 24, color: Colors.yellow, fontWeight: FontWeight.bold),
              ),
            ),
          const Spacer(),
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: engine.isPlayerTurn && engine.table.isNotEmpty ? () => coordinator.endTurn() : null,
                child: const Text('End Turn'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: !engine.isPlayerTurn && engine.table.isNotEmpty ? () => coordinator.takeCards() : null,
                child: const Text('Take Cards'),
              ),
            ],
          ),
          // Player hand
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 4,
              children: engine.playerHand
                  .map((card) => CardWidget(
                        card: card,
                        onTap: () {
                          if (engine.isPlayerTurn && engine.canPlayCard(card)) {
                            coordinator.playCard(card);
                          } else if (!engine.isPlayerTurn && engine.canPlayCard(card)) {
                             // This is for defending
                             coordinator.playCard(card);
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
