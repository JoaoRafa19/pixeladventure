import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixeladventure/components/misc/custom_hitbox.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Fruit extends SpriteAnimationComponent
    with HasGameRef<PixelAdventure>, CollisionCallbacks {
  final String fruit;
  Fruit({position, size, this.fruit = "Cherries"})
      : super(position: position, size: size);

  final double stepTime = 0.05;

  CustomHitbox hitbox = CustomHitbox(
    width: 10,
    height: 10,
    offsetX: 12,
    offsetY: 12,
  );

  @override
  FutureOr<void> onLoad() {
    // debugMode = true;
    priority = -1;

    //Hitbox
    add(
      RectangleHitbox(
        position: Vector2(hitbox.offsetX, hitbox.offsetY),
        size: Vector2(hitbox.width, hitbox.height),
        collisionType: CollisionType.passive,
      ),
    );

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/$fruit.png"),
      SpriteAnimationData.sequenced(
        amount: 17,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );

    return super.onLoad();
  }

  void collidedWithPlayer() async {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Items/Fruits/Collected.png"),
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
    await animationTicker?.completed;
    removeFromParent();
  }
}
