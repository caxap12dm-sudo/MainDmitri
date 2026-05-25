import 'package:flutter/material.dart';
import 'package:slash_king/game.dart';

class ScoreOverlay extends StatefulWidget {
  final SlashKingGame game;
  const ScoreOverlay({super.key, required this.game});

  @override
  State<ScoreOverlay> createState() => _ScoreOverlayState();
}

class _ScoreOverlayState extends State<ScoreOverlay> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Score: ${widget.game.score}',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Combo: x${widget.game.combo}',
                  style: const TextStyle(color: Colors.amber, fontSize: 18),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(
                widget.game.isMusicEnabled ? Icons.music_note : Icons.music_off,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                setState(() {
                  widget.game.toggleMusic();
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
