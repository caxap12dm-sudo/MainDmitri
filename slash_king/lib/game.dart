import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/king.dart';
import 'components/enemy.dart';
import 'components/enemy_spawner.dart';

enum GameState { menu, playing, gameOver }

class SlashKingGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  GameState state = GameState.menu;
  int score = 0;
  int combo = 0;
  int highScore = 0;
  bool isMusicEnabled = true;

  late SharedPreferences _prefs;
  late KingPlayer player;
  late EnemySpawner spawner;

  // Hitbox range for slash
  final double slashRange = 150.0;

  @override
  Future<void> onLoad() async {
    _prefs = await SharedPreferences.getInstance();
    highScore = _prefs.getInt('highScore') ?? 0;

    await images.loadAll([
      'bg.png',
      'king_idle.png',
      'king_slash.png',
      'enemy_run.png',
      'enemy_slashed.png',
    ]);

    await FlameAudio.audioCache.loadAll([
      'slash.wav',
      'miss.wav',
      'game_over.wav',
      'music.wav',
    ]);

    add(SpriteComponent(
      sprite: Sprite(images.fromCache('bg.png')),
      size: size,
    ));

    player = KingPlayer();
    spawner = EnemySpawner();

    add(player);
    add(spawner);
  }

  void startGame() {
    state = GameState.playing;
    score = 0;
    combo = 0;

    // Clear existing enemies if any
    children.whereType<Enemy>().forEach((e) => e.removeFromParent());

    overlays.remove('MainMenu');
    overlays.remove('GameOver');
    overlays.add('Score');

    if (isMusicEnabled) {
      FlameAudio.bgm.play('music.wav');
    }
  }

  void onEnemySlashed() {
    score += 1 * (combo ~/ 10 + 1);
    combo++;
    if (score > highScore) {
      highScore = score;
      _prefs.setInt('highScore', highScore);
    }
    FlameAudio.play('slash.wav');
  }

  void onMiss() {
    combo = 0;
    FlameAudio.play('miss.wav');
  }

  void gameOver() {
    if (state == GameState.gameOver) return;
    state = GameState.gameOver;
    overlays.remove('Score');
    overlays.add('GameOver');
    FlameAudio.play('game_over.wav');
    FlameAudio.bgm.stop();
  }

  void toggleMusic() {
    isMusicEnabled = !isMusicEnabled;
    if (isMusicEnabled) {
      if (state == GameState.playing) {
        FlameAudio.bgm.play('music.wav');
      }
    } else {
      FlameAudio.bgm.stop();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (state != GameState.playing) return;

    final touchPoint = event.canvasPosition;
    if (touchPoint.x < size.x / 2) {
      _handleSlash(Direction.left);
    } else {
      _handleSlash(Direction.right);
    }
  }

  void _handleSlash(Direction direction) {
    player.slash(direction);

    bool hit = false;
    final enemies = children.whereType<Enemy>().where((e) => !e.isSlashed);

    for (final enemy in enemies) {
      final distance = (enemy.position.x - size.x / 2).abs();
      if (distance <= slashRange) {
        if ((direction == Direction.left && enemy.position.x < size.x / 2) ||
            (direction == Direction.right && enemy.position.x > size.x / 2)) {
          enemy.slash();
          hit = true;
          onEnemySlashed();
          break; // Hit one enemy at a time
        }
      }
    }

    if (!hit) {
      onMiss();
    }
  }
}

enum Direction { left, right }
