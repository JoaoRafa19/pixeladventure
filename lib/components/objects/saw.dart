import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixeladventure/components/objects/trap.dart';

class Saw extends Trap {
  final bool? isVertical;
  final double? offNeg;
  final double? offPos;
  final double? moveSpeed;
  Saw({
    this.isVertical = false,
    this.moveSpeed = 50,
    this.offNeg = 0.0,
    this.offPos = 0.0,
    position,
    size,
  }) : super(position: position, size: size);

  double stepTime = 0.03;
  double tileSize = 16;

  double moveDirection = 1;
  double rangeNeg = 0;
  double rangePos = 0;

  @override
  FutureOr<void> onLoad() {
    if (isVertical!) {
      rangeNeg = position.y - offNeg! * tileSize;
      rangePos = position.y + offPos! * tileSize;
    } else {
      rangeNeg = position.x - offNeg! * tileSize;
      rangePos = position.x + offPos! * tileSize;
    }

    // debugMode = true;
    add(CircleHitbox());

    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache("Traps/Saw/On (38x38).png"),
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        loop: true,
        textureSize: Vector2.all(38),
      ),
    );

    return super.onLoad();
  }

  @override
  void update(double dt) {
    move(dt, isVertical);

    super.update(dt);
  }

  void move(double dt, bool? isVertical) {
    if (isVertical ?? false) {
      position.y += moveSpeed! * dt * moveDirection;
    } else {
      position.x += moveSpeed! * dt * moveDirection;
    }
    final newPos = isVertical ?? false ? position.y : position.x;
    if (newPos > rangePos || newPos < rangeNeg) moveDirection *= -1;
  }
}
