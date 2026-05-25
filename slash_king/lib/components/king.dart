import 'package:flame/components.dart';
import 'package:slash_king/game.dart';

class KingPlayer extends SpriteAnimationGroupComponent<KingState> with HasGameReference<SlashKingGame> {
  KingPlayer() : super(anchor: Anchor.center);

  Direction facing = Direction.right;
  double _slashTimer = 0;
  final double slashDuration = 0.15;

  @override
  Future<void> onLoad() async {
    final idleSheet = game.images.fromCache('king_idle.png');
    final slashSheet = game.images.fromCache('king_slash.png');

    final idleAnimation = SpriteAnimation.fromFrameData(
      idleSheet,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.5,
        textureSize: Vector2(64, 64),
      ),
    );

    final slashAnimation = SpriteAnimation.fromFrameData(
      slashSheet,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.05,
        textureSize: Vector2(64, 64),
        loop: false,
      ),
    );

    animations = {
      KingState.idle: idleAnimation,
      KingState.slash: slashAnimation,
    };

    current = KingState.idle;
    size = Vector2(128, 128);
    position = gameRef.size / 2;
  }

  void slash(Direction direction) {
    facing = direction;
    if (facing == Direction.left) {
      scale.x = -1;
    } else {
      scale.x = 1;
    }

    current = KingState.slash;
    animations![KingState.slash]!.reset();
    _slashTimer = slashDuration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_slashTimer > 0) {
      _slashTimer -= dt;
      if (_slashTimer <= 0) {
        current = KingState.idle;
      }
    }
  }
}

enum KingState { idle, slash }
