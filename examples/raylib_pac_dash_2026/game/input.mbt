///|
fn try_set_player_wanted_dir(game : @types.Game) -> Unit {
  if @raylib.is_key_pressed(@raylib.KeyUp) ||
    @raylib.is_key_pressed(@raylib.KeyW) {
    game.want_x = 0
    game.want_y = -1
  }
  if @raylib.is_key_pressed(@raylib.KeyDown) ||
    @raylib.is_key_pressed(@raylib.KeyS) {
    game.want_x = 0
    game.want_y = 1
  }
  if @raylib.is_key_pressed(@raylib.KeyLeft) ||
    @raylib.is_key_pressed(@raylib.KeyA) {
    game.want_x = -1
    game.want_y = 0
  }
  if @raylib.is_key_pressed(@raylib.KeyRight) ||
    @raylib.is_key_pressed(@raylib.KeyD) {
    game.want_x = 1
    game.want_y = 0
  }
}
