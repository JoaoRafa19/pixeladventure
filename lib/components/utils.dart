bool checkCollision(player, block) {
  final hitbox = player.hitbox;
  final playerx = player.position.x + hitbox.offSetX;
  final playery = player.position.y + hitbox.offSetY;
  final playerWidth = hitbox.width;
  final playerHeight = hitbox.height;

  final blockx = block.x;
  final blocky = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  final fixedx = player.scale.x < 0
      ? playerx - (hitbox.offSetX * 2) - playerWidth
      : playerx ;
  final fixedy = block.isPlatform ? playery + playerHeight : playery;

  return (fixedy < blocky + blockHeight &&
      playery + playerHeight > blocky &&
      fixedx < blockx + blockWidth &&
      fixedx + playerWidth > blockx);
}
