import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixeladventure/entities/player.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Checkpoint extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  Checkpoint({position, size}) : super(position: position, size: size);

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation appearingAnimation;
  final double stepTime = 0.05;

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
      position: Vector2(18, 56),
      size: Vector2(12, 8),
      collisionType: CollisionType.passive,
    ));
    idleAnimation = SpriteAnimation.fromFrameData(
      game.images
          .fromCache("Items/Checkpoints/Checkpoint/Checkpoint (No Flag).png"),
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );

    animation = idleAnimation;

    return super.onLoad();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Player) {
      _reachCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  Future<void> _reachCheckpoint() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          "Items/Checkpoints/Checkpoint/Checkpoint (Flag Out) (64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 26,
        stepTime: stepTime,
        loop: false,
        textureSize: Vector2.all(64),
      ),
    );
    await animationTicker?.completed;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache(
          "Items/Checkpoints/Checkpoint/Checkpoint (Flag Idle)(64x64).png"),
      SpriteAnimationData.sequenced(
        amount: 10,
        stepTime: stepTime,
        textureSize: Vector2.all(64),
      ),
    );
  }
}
