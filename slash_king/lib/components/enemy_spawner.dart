import 'dart:math';
import 'package:flame/components.dart';
import 'package:slash_king/game.dart';
import 'package:slash_king/components/enemy.dart';

class EnemySpawner extends Component with HasGameReference<SlashKingGame> {
  late Timer _timer;
  final Random _random = Random();

  EnemySpawner() {
    _timer = Timer(2.0, onTick: _spawn, repeat: true);
  }

  void _spawn() {
    if (game.state != GameState.playing) return;

    final side = _random.nextBool() ? Direction.left : Direction.right;
    game.add(Enemy(spawnSide: side));

    // Gradually decrease spawn interval
    double nextInterval = 2.0 - (game.score / 100);
    _timer.limit = max(0.5, nextInterval);
  }

  @override
  void update(double dt) {
    _timer.update(dt);
  }

  void reset() {
    _timer.reset();
    _timer.limit = 2.0;
  }
}
