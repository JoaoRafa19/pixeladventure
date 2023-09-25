import 'dart:io';

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixeladventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  final showJoystick = Platform.isAndroid || Platform.isIOS ? true : false;

  PixelAdventure game = PixelAdventure(showJoystick: showJoystick);
  runApp(
    GameWidget(game: kDebugMode ? PixelAdventure(showJoystick: showJoystick) : game),
  );
}
