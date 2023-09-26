import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';
import 'package:pixeladventure/components/player.dart';
import 'package:pixeladventure/components/level.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, DragCallbacks, HasCollisionDetection {
  PixelAdventure({this.showJoystick = false});

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  Player player = Player(character: 'Mask Dude');
  late final CameraComponent cam;
  late JoystickComponent joystick;
  final bool showJoystick;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); //<- load all images in cache

    final world = Level(
      player: player,
      levelName: "Level_02",
    );

    cam = CameraComponent.withFixedResolution(
        world: world, width: 640, height: 360);

    cam.viewfinder.anchor = Anchor.topLeft;

    addAll([cam, world]);

    if (showJoystick) {
      addJoystick();
    }
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (showJoystick) {
      updateJoystick();
    }

    super.update(dt);
  }

  void addJoystick() {
    joystick = JoystickComponent(
      margin: const EdgeInsets.only(bottom: 32, left: 32),
      knob: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/knob.png'),
        ),
      ),
      knobRadius: 64,
      background: SpriteComponent(
        sprite: Sprite(
          images.fromCache('HUD/joystick.png'),
        ),
      ),
    );

    add(joystick);
  }

  void updateJoystick() {
    switch (joystick.direction) {
      case JoystickDirection.left:
      case JoystickDirection.upLeft:
      case JoystickDirection.downLeft:
        player.horizontalMovement = -1;
        break;
      case JoystickDirection.right:
      case JoystickDirection.upRight:
      case JoystickDirection.downRight:
        player.horizontalMovement = 1;
        break;
      case JoystickDirection.up:
        player.velocity.y -= 460;
        break;
      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}
