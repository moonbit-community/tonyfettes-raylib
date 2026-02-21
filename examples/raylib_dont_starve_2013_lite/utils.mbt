///|
fn absf(v : Float) -> Float {
  if v < 0.0 {
    -v
  } else {
    v
  }
}

///|
fn clampf(v : Float, low : Float, high : Float) -> Float {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
fn clampi(v : Int, low : Int, high : Int) -> Int {
  if v < low {
    low
  } else if v > high {
    high
  } else {
    v
  }
}

///|
fn rand_next(game : Game) -> Int {
  let mut x = game.rng_state
  x = x ^ (x << 13)
  x = x ^ (x >> 17)
  x = x ^ (x << 5)
  if x < 0 {
    x = -x
  }
  game.rng_state = x
  x
}

///|
fn rand_range(game : Game, low : Int, high : Int) -> Int {
  if high <= low {
    low
  } else {
    low + rand_next(game) % (high - low + 1)
  }
}

///|
fn rand_rangef(game : Game, low : Float, high : Float) -> Float {
  let n = Float::from_int(rand_next(game) % 10000) / 10000.0
  low + (high - low) * n
}

///|
fn tile_index(tx : Int, ty : Int) -> Int {
  ty * map_tiles_w + tx
}

///|
fn in_tile_bounds(tx : Int, ty : Int) -> Bool {
  tx >= 0 && ty >= 0 && tx < map_tiles_w && ty < map_tiles_h
}

///|
fn get_tile(game : Game, tx : Int, ty : Int) -> Int {
  if in_tile_bounds(tx, ty) {
    game.map_tiles[tile_index(tx, ty)]
  } else {
    tile_steel
  }
}

///|
fn set_tile(game : Game, tx : Int, ty : Int, tile : Int, hp : Int) -> Unit {
  if in_tile_bounds(tx, ty) {
    let idx = tile_index(tx, ty)
    game.map_tiles[idx] = tile
    game.map_hp[idx] = hp
  }
}

///|
fn world_x_to_tile(x : Float) -> Int {
  clampi((x / Float::from_int(tile_size)).to_int(), 0, map_tiles_w - 1)
}

///|
fn world_y_to_tile(y : Float) -> Int {
  clampi((y / Float::from_int(tile_size)).to_int(), 0, map_tiles_h - 1)
}

///|
fn tile_center_x(tx : Int) -> Float {
  Float::from_int(tx * tile_size + tile_size / 2)
}

///|
fn tile_center_y(ty : Int) -> Float {
  Float::from_int(ty * tile_size + tile_size / 2)
}

///|
fn world_to_screen_x(x : Float, shake_x : Float) -> Int {
  map_offset_x + x.to_int() + shake_x.to_int()
}

///|
fn world_to_screen_y(y : Float, shake_y : Float) -> Int {
  map_offset_y + y.to_int() + shake_y.to_int()
}

///|
fn tile_to_screen_x(tx : Int, shake_x : Float) -> Int {
  map_offset_x + tx * tile_size + shake_x.to_int()
}

///|
fn tile_to_screen_y(ty : Int, shake_y : Float) -> Int {
  map_offset_y + ty * tile_size + shake_y.to_int()
}

///|
fn dir_vector_x(dir : Int) -> Float {
  if dir == dir_left {
    -1.0
  } else if dir == dir_right {
    1.0
  } else {
    0.0
  }
}

///|
fn dir_vector_y(dir : Int) -> Float {
  if dir == dir_up {
    -1.0
  } else if dir == dir_down {
    1.0
  } else {
    0.0
  }
}

///|
fn tank_rect_at(x : Float, y : Float) -> @raylib.Rectangle {
  @raylib.Rectangle::new(x - tank_half, y - tank_half, tank_size, tank_size)
}

///|
fn tank_rect(tank : Tank) -> @raylib.Rectangle {
  tank_rect_at(tank.x, tank.y)
}

///|
fn rects_overlap(a : @raylib.Rectangle, b : @raylib.Rectangle) -> Bool {
  @raylib.check_collision_recs(a, b)
}

///|
fn distance_sq(ax : Float, ay : Float, bx : Float, by : Float) -> Float {
  let dx = ax - bx
  let dy = ay - by
  dx * dx + dy * dy
}

///|
fn is_tile_solid_for_tank(tile : Int) -> Bool {
  tile == tile_brick ||
  tile == tile_steel ||
  tile == tile_water ||
  tile == tile_base
}

///|
fn is_tile_solid_for_bullet(tile : Int) -> Bool {
  tile == tile_brick || tile == tile_steel || tile == tile_base
}

///|
fn enemy_score(kind : Int) -> Int {
  if kind == enemy_fast {
    200
  } else if kind == enemy_heavy {
    400
  } else if kind == enemy_sniper {
    300
  } else {
    100
  }
}

///|
fn enemy_color(kind : Int) -> @raylib.Color {
  if kind == enemy_fast {
    @raylib.orange
  } else if kind == enemy_heavy {
    @raylib.red
  } else if kind == enemy_sniper {
    @raylib.purple
  } else {
    @raylib.yellow
  }
}

///|
fn draw_centered_text(
  text : String,
  center_x : Int,
  y : Int,
  font_size : Int,
  color : @raylib.Color,
) -> Unit {
  let w = @raylib.measure_text(text, font_size)
  @raylib.draw_text(text, center_x - w / 2, y, font_size, color)
}

///|
fn draw_shadow_text(
  text : String,
  x : Int,
  y : Int,
  size : Int,
  color : @raylib.Color,
) -> Unit {
  @raylib.draw_text(text, x + 2, y + 2, size, @raylib.black)
  @raylib.draw_text(text, x, y, size, color)
}

///|
fn shake_offsets(game : Game) -> (Float, Float) {
  if game.camera_shake <= 0.0 {
    (0.0, 0.0)
  } else {
    game.camera_shake_phase += 0.12
    let sx = Float::from_double(@math.cos(game.camera_shake_phase.to_double()))
    let sy = Float::from_double(
      @math.sin((game.camera_shake_phase * 1.8).to_double()),
    )
    (sx * game.camera_shake, sy * game.camera_shake * 0.8)
  }
}

///|
fn update_camera_shake(game : Game, dt : Float) -> Unit {
  if game.camera_shake > 0.0 {
    game.camera_shake -= dt * camera_shake_decay * camera_shake_power
    if game.camera_shake < 0.0 {
      game.camera_shake = 0.0
    }
  }
}

///|
fn push_camera_shake(game : Game, amount : Float) -> Unit {
  let next = game.camera_shake + amount
  if next > camera_shake_power {
    game.camera_shake = camera_shake_power
  } else {
    game.camera_shake = next
  }
}

///|
fn pulse_color(base : @raylib.Color, phase : Float) -> @raylib.Color {
  let p = Float::from_double(@math.sin(phase.to_double())) * 0.5 + 0.5
  @raylib.color_lerp(base, @raylib.white, p * 0.4)
}
