import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart' as Flame_Audio;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixeladventure/components/misc/jump_button.dart';
import 'package:pixeladventure/entities/player.dart';
import 'package:pixeladventure/components/level.dart';

class PixelAdventure extends FlameGame
    with
        HasKeyboardHandlerComponents,
        DragCallbacks,
        HasCollisionDetection,
        TapCallbacks {
  PixelAdventure({this.showJoystick = false});

  @override
  Color backgroundColor() => const Color(0xFF211F30);
  Player player = Player(character: 'Mask Dude');
  late CameraComponent cam;
  late JoystickComponent joystick;
  late JumpButton jumpbutton;
  final bool showJoystick;

  //sounds
  bool playSounds = false;
  double soundVolume = 0.4;
  double musicVolume = 0.2;

  late Flame_Audio.AudioPlayer musicPlayer;

  //levels
  List<String> levelNames = ['Level_01', 'Level_02'];
  int currentLevelIndex = 0;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages(); //<- load all images in cache
    musicPlayer =
        await Flame_Audio.FlameAudio.loop('music/01.mp3', volume: musicVolume);

    _loadLevel();

    if (showJoystick) {
      addJoystick();
    }
    return super.onLoad();
  }

  void loadNextLevel() {
    removeWhere((component) => component is Level);
    if (currentLevelIndex < levelNames.length - 1) {
      currentLevelIndex++;
      _loadLevel();
    } else {
      // no more levels;
      currentLevelIndex = 0;
      _loadLevel();
    }
  }

  void _loadLevel() {
    Future.delayed(const Duration(seconds: 2), () {
      Level world = Level(
        player: player,
        levelName: levelNames[currentLevelIndex],
      );

      cam = CameraComponent.withFixedResolution(
          world: world, width: 640, height: 360);

      cam.viewfinder.anchor = Anchor.topLeft;

      addAll([cam, world]);
    });
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
      priority: 10,
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

    jumpbutton = JumpButton();
    add(jumpbutton);
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyP)) {
      if (musicPlayer.state == Flame_Audio.PlayerState.playing) {
        musicPlayer.pause();
      } else {
        musicPlayer.resume();
      }
    }

    if (keysPressed.contains(LogicalKeyboardKey.f9)) {
      if (musicVolume > 0) {
        musicVolume -= 0.1;
        musicPlayer.setVolume(musicVolume);
      }
    }
    if (keysPressed.contains(LogicalKeyboardKey.f10)) {
      if (musicVolume < 0.5) {
        musicVolume += 0.1;
        musicPlayer.setVolume(musicVolume);
      }
    }

    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      if (paused) {
        resumeEngine();
      } else {
        pauseEngine();
      }
    }

    return super.onKeyEvent(event, keysPressed);
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

      default:
        player.horizontalMovement = 0;
        break;
    }
  }
}
