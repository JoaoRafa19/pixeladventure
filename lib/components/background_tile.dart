import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class BackgroundTile extends ParallaxComponent<PixelAdventure> {
  final String color;
  BackgroundTile({position, this.color = "Gray"}) : super(position: position);

  final double scroolSpeed = 40;

  @override
  FutureOr<void> onLoad() async {
    priority = -10;
    size = Vector2.all(64.6);
    parallax = await game.loadParallax([
      ParallaxImageData(
          "Background/${color[0].toUpperCase()}${color.substring(1).toLowerCase()}.png"),
    ],
        baseVelocity: Vector2(0, -scroolSpeed),
        fill: LayerFill.none,
        repeat: ImageRepeat.repeat);
    return super.onLoad();
  }
}
