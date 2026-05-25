import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:slash_king/game.dart';

class Enemy extends SpriteAnimationComponent with HasGameReference<SlashKingGame> {
  final Direction spawnSide;
  double speed = 150;
  bool isSlashed = false;

  Enemy({required this.spawnSide}) : super(anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final runSheet = game.images.fromCache('enemy_run.png');
    animation = SpriteAnimation.fromFrameData(
      runSheet,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.1,
        textureSize: Vector2(64, 64),
      ),
    );

    size = Vector2(100, 100);

    if (spawnSide == Direction.left) {
      position = Vector2(-size.x, gameRef.size.y / 2);
      scale.x = -1; // Face right
    } else {
      position = Vector2(gameRef.size.x + size.x, gameRef.size.y / 2);
      scale.x = 1; // Face left
    }

    // Adjust speed based on score
    speed += (game.score / 10) * 10;

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isSlashed) return;

    if (spawnSide == Direction.left) {
      position.x += speed * dt;
      if (position.x >= game.size.x / 2 - 20) {
        game.gameOver();
      }
    } else {
      position.x -= speed * dt;
      if (position.x <= game.size.x / 2 + 20) {
        game.gameOver();
      }
    }
  }

  Future<void> slash() async {
    isSlashed = true;
    final slashedSheet = game.images.fromCache('enemy_slashed.png');
    animation = SpriteAnimation.fromFrameData(
      slashedSheet,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.2,
        textureSize: Vector2(64, 64),
        loop: false,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 200));
    removeFromParent();
  }
}
