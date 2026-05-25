import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:slash_king/game.dart';
import 'package:slash_king/overlays/game_over.dart';
import 'package:slash_king/overlays/main_menu.dart';
import 'package:slash_king/overlays/score.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slash King',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.amber,
      ),
      home: const GameWidgetWrapper(),
    );
  }
}

class GameWidgetWrapper extends StatefulWidget {
  const GameWidgetWrapper({super.key});

  @override
  State<GameWidgetWrapper> createState() => _GameWidgetWrapperState();
}

class _GameWidgetWrapperState extends State<GameWidgetWrapper> {
  late SlashKingGame _game;

  @override
  void initState() {
    super.initState();
    _game = SlashKingGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<SlashKingGame>(
        game: _game,
        overlayBuilderMap: {
          'MainMenu': (context, game) => MainMenuOverlay(game: game),
          'Score': (context, game) => ScoreOverlay(game: game),
          'GameOver': (context, game) => GameOverOverlay(game: game),
        },
        initialActiveOverlays: const ['MainMenu'],
      ),
    );
  }
}
