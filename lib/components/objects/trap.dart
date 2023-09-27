import 'package:flame/components.dart';
import 'package:pixeladventure/pixel_adventure.dart';

class Trap extends SpriteAnimationComponent with HasGameRef<PixelAdventure> {
  Trap({position, size}) : super(position: position, size: size) {
    priority = -1;
  }
}
