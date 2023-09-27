import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixeladventure/components/background_tile.dart';
import 'package:pixeladventure/components/objects/checkpoint.dart';
import 'package:pixeladventure/components/objects/collision_block.dart';
import 'package:pixeladventure/components/objects/fruit.dart';
import 'package:pixeladventure/entities/player.dart';

import 'objects/saw.dart';

class Level extends World {
  final String levelName;
  late TiledComponent level;
  final Player player;
  List<CollisionBlock> collisionBlocks = [];
  Level({required this.levelName, required this.player});
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("$levelName.tmx", Vector2.all(16));
    _scrollingBackground();
    add(level);
    _spawnObjects();
    _addCollisions();

    return super.onLoad();
  }

  void _scrollingBackground() {
    final backegroundLayer = level.tileMap.getLayer("Background");

    if (backegroundLayer != null) {
      var value = backegroundLayer.properties.getValue("BackgroundCollor");
      final backgroundTile = BackgroundTile(
        color: value ?? 'Gray',
        position: Vector2(0, 0),
      );
      add(backgroundTile);
    }
  }

  void _spawnObjects() {
    final spawnPointLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    if (spawnPointLayer != null) {
      for (final spawnPoint in spawnPointLayer.objects) {
        switch (spawnPoint.class_) {
          case 'Player':
            player
              ..position = Vector2(spawnPoint.x, spawnPoint.y)
              ..scale.x = 1
              ..startingPosition = Vector2(spawnPoint.x, spawnPoint.y);
              
            add(player);
            break;
          case 'Fruit':
            final fruit = Fruit(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              fruit: spawnPoint.name,
            );
            add(fruit);
            break;
          case 'Saw':
            final isVertical =
                spawnPoint.properties.getValue<bool?>("isVertical");
            final offNeg = spawnPoint.properties.getValue<double?>("offNeg");
            final offPos = spawnPoint.properties.getValue<double?>("offPos");
            final moveSpeed =
                spawnPoint.properties.getValue<double?>("moveSpeed");
            final saw = Saw(
              position: Vector2(
                spawnPoint.x,
                spawnPoint.y,
              ),
              size: Vector2(
                spawnPoint.width,
                spawnPoint.height,
              ),
              isVertical: isVertical,
              moveSpeed: moveSpeed,
              offNeg: offNeg,
              offPos: offPos,
            );
            add(saw);
            break;
          case 'Checkpoint':
            final checkpoint = Checkpoint(
              position: Vector2(spawnPoint.x, spawnPoint.y),
              size: Vector2(spawnPoint.width, spawnPoint.height),
            );
            add(checkpoint);
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
