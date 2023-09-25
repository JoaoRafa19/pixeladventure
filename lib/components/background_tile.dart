import 'dart:async';

import 'package:flame/components.dart';

class BackgroundTile extends SpriteComponent with HasGameRef {
  final String color;
  BackgroundTile({position, this.color = "Gray"}) : super(position: position);

  final double scroolSpeed = 0.4;

  @override
  void update(double dt) {
    position.y += scroolSpeed;
    double tileSize = 64;
    int scroolHeight = (game.size.y / tileSize).floor();
    if (position.y >= scroolHeight * tileSize) {
      position.y = -tileSize;
    }

    super.update(dt);
  }

  @override
  FutureOr<void> onLoad() {
    priority = -1;
    size = Vector2.all(64.6);
    sprite = Sprite(game.images.fromCache(
        'Background/${color[0].toUpperCase()}${color.substring(1).toLowerCase()}.png'));

    return super.onLoad();
  }
}
