import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixeladventure/components/collision_block.dart';
import 'package:pixeladventure/components/player.dart';

class Level extends World {
  final String levelName;
  late TiledComponent level;
  final Player player;
  List<CollisionBlock> collisionBlocks = [];
  Level({required this.levelName, required this.player});
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    add(level);

    _scrollingBackground();
    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backegroundLayer = level.tileMap.getLayer("Background");
    if (backegroundLayer != null){
      
    }
  }

  void _spawnObjects() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player.position = Vector2(spawnPoint.x, spawnPoint.y);
            add(player);
            break;
          default:
        }
      }
    }
  }

  void _addCollisions() {
    final collisionLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");
    if (collisionLayer != null) {
      for (final collision in collisionLayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
            break;

          default:
            final collitionBlock = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
            );
            collisionBlocks.add(collitionBlock);
            add(collitionBlock);
        }
      }
    }
    player.collisionBlocks = collisionBlocks;
  }
}
