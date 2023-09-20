import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixeladventure/pixel_adventure.dart';

enum PlayerState { idle, running, duobleJump, fall, hit, jump, wallJump }

enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  String character;

  Player({this.character = 'Ninja Frog', Vector2? position})
      : super(position: position, size: Vector2.all(32));

  late final SpriteAnimation idleAnimation;
  late final SpriteAnimation runnningAnimation;
  late final SpriteAnimation doubleJumpAnimation;
  late final SpriteAnimation fallAnimation;
  late final SpriteAnimation hitAnimation;
  late final SpriteAnimation jumpAnimation;
  late final SpriteAnimation wallJumpAnimation;
  final double stepTime = 0.05;

  PlayerDirection playerDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();

    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    if (isLeftKeyPressed && isRightKeyPressed) {
      playerDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      playerDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      playerDirection = PlayerDirection.right;
    } else {
      playerDirection = PlayerDirection.none;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    double dirX = 0.0;
    switch (playerDirection) {
      case PlayerDirection.left:
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.running;
        dirX -= moveSpeed;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        current = PlayerState.running;
        dirX += moveSpeed;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        dirX = 0.0;
        break;
    }
    velocity = Vector2(dirX, 0.0);

    position += velocity * dt;
  }

  void _loadAllAnimations() {
    idleAnimation = _getAnimation(animation: 'Idle', amount: 11);
    runnningAnimation = _getAnimation(animation: 'Run', amount: 12);
    doubleJumpAnimation = _getAnimation(animation: 'Double Jump', amount: 6);
    fallAnimation = _getAnimation(animation: 'Fall', amount: 1);
    hitAnimation = _getAnimation(animation: 'Hit', amount: 7);
    jumpAnimation = _getAnimation(animation: 'Jump', amount: 1);
    wallJumpAnimation = _getAnimation(animation: 'Wall Jump', amount: 5);

    //list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runnningAnimation,
      PlayerState.duobleJump: doubleJumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
    };

    //set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _getAnimation(
      {required String animation, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images
          .fromCache('Main Characters/$character/$animation (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: 7,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }
}
