import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/services.dart';
import 'package:pixeladventure/components/objects/trap.dart';
import 'package:pixeladventure/components/objects/checkpoint.dart';
import 'package:pixeladventure/components/objects/collision_block.dart';
import 'package:pixeladventure/components/objects/fruit.dart';
import 'package:pixeladventure/components/player_hitbok.dart';
import 'package:pixeladventure/components/utils.dart';
import 'package:pixeladventure/pixel_adventure.dart';

enum PlayerState {
  idle,
  running,
  duobleJump,
  fall,
  hit,
  jump,
  wallJump,
  appearing,
  disappearing,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
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
  late final SpriteAnimation appearingAnimation;
  late final SpriteAnimation disappearingAnimation;
  final double stepTime = 0.05;

  PlayerHitbox hitbox = PlayerHitbox(
    offSetX: 10,
    offSetY: 4,
    width: 12,
    height: 28,
  );

  double fixedDeltatime = 1 / 60;
  double acumulatedTime = 0;
  final double _gravity = 9.8;
  final double _jumpForce = 260;
  final double _terminalVelocity = 250;

  double moveSpeed = 100;
  double horizontalMovement = 0.0;
  Vector2 velocity = Vector2.zero();
  Vector2 startingPosition = Vector2.zero();
  List<CollisionBlock> collisionBlocks = [];
  bool isOnGround = false;
  bool hasJumped = false;
  bool gotHit = false;
  bool reachedCheckpoint = false;

  @override
  FutureOr<void> onLoad() {
    startingPosition = position.clone();
    _loadAllAnimations();
    // debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offSetX, hitbox.offSetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    acumulatedTime += dt;

    while (acumulatedTime >= fixedDeltatime) {
      if (!gotHit && !reachedCheckpoint) {
        _updatePlayerMovement(fixedDeltatime);
        _updatePlayerState();
        _checkHorizontalCollisions();
        _applyGravity(fixedDeltatime);
        _checkVerticalCollisions();
      }
      acumulatedTime -= fixedDeltatime;
    }

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMovement = 0.0;

    final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyA) ||
        keysPressed.contains(LogicalKeyboardKey.arrowLeft);
    final isRightKeyPressed = keysPressed.contains(LogicalKeyboardKey.keyD) ||
        keysPressed.contains(LogicalKeyboardKey.arrowRight);

    horizontalMovement += isLeftKeyPressed ? -1 : 0;
    horizontalMovement += isRightKeyPressed ? 1 : 0;

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space) ||
        keysPressed.contains(LogicalKeyboardKey.keyW) ||
        keysPressed.contains(LogicalKeyboardKey.arrowUp);

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    if (hasJumped && isOnGround) {
      _playerJump(dt);
    }

    // Optional jump if player is not on ground
    // if (velocity.y > 0) isOnGround = false;

    velocity.x = horizontalMovement * moveSpeed;
    position.x += velocity.x * dt;
  }

  void _loadAllAnimations() {
    idleAnimation = _getAnimation(state: 'Idle', amount: 11);
    runnningAnimation = _getAnimation(state: 'Run', amount: 12);
    doubleJumpAnimation = _getAnimation(state: 'Double Jump', amount: 6);
    fallAnimation = _getAnimation(state: 'Fall', amount: 1);
    hitAnimation = _getAnimation(state: 'Hit', amount: 7)..loop = false;
    jumpAnimation = _getAnimation(state: 'Jump', amount: 1);
    wallJumpAnimation = _getAnimation(state: 'Wall Jump', amount: 5);

    appearingAnimation = _getSpecialAnimation(state: 'Appearing', amount: 7);
    disappearingAnimation =
        _getSpecialAnimation(state: 'Desappearing', amount: 7);

    //list of all animations
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.running: runnningAnimation,
      PlayerState.duobleJump: doubleJumpAnimation,
      PlayerState.fall: fallAnimation,
      PlayerState.hit: hitAnimation,
      PlayerState.appearing: appearingAnimation,
      PlayerState.jump: jumpAnimation,
      PlayerState.wallJump: wallJumpAnimation,
      PlayerState.disappearing: disappearingAnimation,
    };

    //set current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _getSpecialAnimation(
      {required String state, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$state (96x96).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        loop: false,
        textureSize: Vector2.all(96),
      ),
    );
  }

  SpriteAnimation _getAnimation({required String state, required int amount}) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache('Main Characters/$character/$state (32x32).png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: Vector2.all(32),
      ),
    );
  }

  void _updatePlayerState() {
    PlayerState playerState = PlayerState.idle;

    if (velocity.x < 0 && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (velocity.x > 0 && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }

    //is running
    if (velocity.x != 0) playerState = PlayerState.running;

    // check if is jumping
    if (velocity.y < 0) playerState = PlayerState.jump;

    //check if is falling
    if (velocity.y > 0) playerState = PlayerState.fall;

    current = playerState;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offSetX - hitbox.width;
          }
          if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offSetX;
          }
        }
      }
    }
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y.clamp(-_jumpForce, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _checkVerticalCollisions() {
    for (final block in collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offSetY;
            isOnGround = true;
            break;
          }
        }
      } else {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offSetY;
            isOnGround = true;
            break;
          }
          if (velocity.y < 0) {
            velocity.y = 0;
            position.y = block.y + block.height - hitbox.offSetY;
          }
        }
      }
    }
  }

  void _playerJump(double dt) async {
    if (game.playSounds) {
      await FlameAudio.play('sounds/jump.wav', volume: game.soundVolume);
    }

    velocity.y = -_jumpForce;

    position.y += velocity.y * dt;
    isOnGround = false;
    hasJumped = false;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!reachedCheckpoint) {
      if (other is Fruit) other.collidedWithPlayer();
      if (other is Trap) _respawn();
      if (other is Checkpoint) _reachCheckpoint();
    }
    super.onCollisionStart(intersectionPoints, other);
  }

  void _respawn() async {
    if (game.playSounds) {
      FlameAudio.play('sounds/hit.wav', volume: game.soundVolume);
    }
    const canMuveDuration = Duration(milliseconds: 500);
    gotHit = true;
    current = PlayerState.hit;
    await animationTicker?.completed;
    animationTicker?.reset();

    scale.x = 1;
    position = startingPosition;
    current = PlayerState.appearing;
    if (game.playSounds) {
      FlameAudio.play('sounds/desapear.wav', volume: game.soundVolume);
    }

    await animationTicker?.completed;
    animationTicker?.reset();

    velocity = Vector2.zero();
    position = startingPosition;
    _updatePlayerState();
    Future.delayed(canMuveDuration, () => gotHit = false);
  }

  void _reachCheckpoint() async {
    reachedCheckpoint = true;
    current = PlayerState.disappearing;

    await animationTicker?.completed;
    velocity = Vector2.zero();

    await Future.delayed(const Duration(seconds: 3), () {
      //switch level
      game.loadNextLevel();
    });
    reachedCheckpoint = false;
  }
}
