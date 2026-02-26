///|
let sw : Int = 1366

///|
let sh : Int = 768

///|
let grid_w : Int = 42

///|
let grid_h : Int = 28

///|
let tile_sz : Int = 24

///|
let world_x : Int = 24

///|
let world_y : Int = 72

///|
let world_w : Int = grid_w * tile_sz

///|
let world_h : Int = grid_h * tile_sz

///|
let world_l : Float = Float::from_int(world_x)

///|
let world_t : Float = Float::from_int(world_y)

///|
let world_r : Float = Float::from_int(world_x + world_w)

///|
let world_b : Float = Float::from_int(world_y + world_h)

///|
let panel_x : Int = world_x + world_w + 18

///|
let panel_w : Int = sw - panel_x - 20

///|
let max_particles : Int = 420

///|
let tile_empty : Int = 0

///|
let tile_dirt : Int = 1

///|
let tile_rock : Int = 2

///|
let tile_gas : Int = 3

///|
let tile_crystal : Int = 4

///|
let tile_miner : Int = 5

///|
let tile_base : Int = 6

///|
struct Player {
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut fuel : Float
  fuel_max : Float
  mut oxygen : Float
  oxygen_max : Float
  mut hull : Float
  hull_max : Float
  mut heat : Float
  heat_max : Float
  mut bombs : Int
  mut bomb_cd : Float
  mut rescue_cd : Float
  mut sonar_cd : Float
  mut sonar_t : Float
  mut sonar_tx : Float
  mut sonar_ty : Float
  mut carried : Int
  carry_max : Int
  wobble : Float
}

///|
struct Particle {
  mut active : Bool
  mut kind : Int
  mut x : Float
  mut y : Float
  mut vx : Float
  mut vy : Float
  mut size : Float
  mut life : Float
  mut pulse : Float
}

///|
fn clampf(v : Float, lo : Float, hi : Float) -> Float {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn clampi(v : Int, lo : Int, hi : Int) -> Int {
  if v < lo {
    lo
  } else if v > hi {
    hi
  } else {
    v
  }
}

///|
fn maxf(a : Float, b : Float) -> Float {
  if a > b {
    a
  } else {
    b
  }
}

///|
fn minf(a : Float, b : Float) -> Float {
  if a < b {
    a
  } else {
    b
  }
}

///|
fn randf(lo : Float, hi : Float) -> Float {
  let r : Float = Float::from_int(@raylib.get_random_value(0, 10000)) / 10000.0
  lo + (hi - lo) * r
}

///|
fn dist2(x0 : Float, y0 : Float, x1 : Float, y1 : Float) -> Float {
  let dx : Float = x1 - x0
  let dy : Float = y1 - y0
  dx * dx + dy * dy
}

///|
fn idx(gx : Int, gy : Int) -> Int {
  gy * grid_w + gx
}

///|
fn in_bounds(gx : Int, gy : Int) -> Bool {
  gx >= 0 && gx < grid_w && gy >= 0 && gy < grid_h
}

///|
fn get_tile(tiles : Array[Int], gx : Int, gy : Int) -> Int {
  if in_bounds(gx, gy) {
    tiles[idx(gx, gy)]
  } else {
    tile_rock
  }
}

///|
fn set_tile(tiles : Array[Int], gx : Int, gy : Int, t : Int) -> Unit {
  if in_bounds(gx, gy) {
    tiles[idx(gx, gy)] = t
  }
}

///|
fn world_to_gx(x : Float) -> Int {
  ((x - world_l) / Float::from_int(tile_sz)).to_int()
}

///|
fn world_to_gy(y : Float) -> Int {
  ((y - world_t) / Float::from_int(tile_sz)).to_int()
}

///|
fn cell_center_x(gx : Int) -> Float {
  world_l + Float::from_int(gx * tile_sz + tile_sz / 2)
}

///|
fn cell_center_y(gy : Int) -> Float {
  world_t + Float::from_int(gy * tile_sz + tile_sz / 2)
}

///|
fn inside_rect(
  px : Float,
  py : Float,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
) -> Bool {
  px >= Float::from_int(x) &&
  px <= Float::from_int(x + w) &&
  py >= Float::from_int(y) &&
  py <= Float::from_int(y + h)
}

///|
fn clear_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    parts[i].active = false
    parts[i].kind = 0
    parts[i].x = 0.0
    parts[i].y = 0.0
    parts[i].vx = 0.0
    parts[i].vy = 0.0
    parts[i].size = 0.0
    parts[i].life = 0.0
    parts[i].pulse = 0.0
  }
}

///|
fn add_particle(
  parts : Array[Particle],
  x : Float,
  y : Float,
  kind : Int,
) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      parts[i].active = true
      parts[i].kind = kind
      parts[i].x = x
      parts[i].y = y
      let a : Float = randf(0.0, 6.28318)
      let s : Float = randf(20.0, 220.0)
      parts[i].vx = @math.cosf(a) * s
      parts[i].vy = @math.sinf(a) * s
      parts[i].size = randf(2.0, 8.0)
      parts[i].life = randf(0.2, 1.0)
      parts[i].pulse = randf(0.0, 12.0)
      return
    }
  }
}

///|
fn burst_particles(
  parts : Array[Particle],
  x : Float,
  y : Float,
  n : Int,
  kind : Int,
) -> Unit {
  for _i = 0; _i < n; _i = _i + 1 {
    add_particle(parts, x, y, kind)
  }
}

///|
fn update_particles(parts : Array[Particle], dt : Float) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    parts[i].life = parts[i].life - dt
    if parts[i].life <= 0.0 {
      parts[i].active = false
      continue
    }

    parts[i].pulse = parts[i].pulse + dt
    parts[i].x = parts[i].x + parts[i].vx * dt
    parts[i].y = parts[i].y + parts[i].vy * dt
    parts[i].vx = parts[i].vx * (1.0 - dt * 2.3)
    parts[i].vy = parts[i].vy * (1.0 - dt * 2.1) + 6.0 * dt
  }
}

///|
fn draw_particles(parts : Array[Particle]) -> Unit {
  for i = 0; i < parts.length(); i = i + 1 {
    if not(parts[i].active) {
      continue
    }

    let c = if parts[i].kind == 0 {
      @raylib.Color::new(184, 126, 92, 230)
    } else if parts[i].kind == 1 {
      @raylib.Color::new(140, 214, 252, 236)
    } else if parts[i].kind == 2 {
      @raylib.Color::new(132, 238, 156, 236)
    } else if parts[i].kind == 3 {
      @raylib.Color::new(246, 232, 134, 236)
    } else {
      @raylib.Color::new(244, 132, 144, 236)
    }

    @raylib.draw_circle(
      parts[i].x.to_int(),
      parts[i].y.to_int(),
      parts[i].size * parts[i].life * 2.0,
      c,
    )
  }
}

///|
fn setup_map(tiles : Array[Int], target_miners : Int) -> Int {
  for gy = 0; gy < grid_h; gy = gy + 1 {
    for gx = 0; gx < grid_w; gx = gx + 1 {
      let i : Int = idx(gx, gy)

      if gx == 0 || gx == grid_w - 1 || gy == grid_h - 1 {
        tiles[i] = tile_rock
        continue
      }

      if gy <= 2 {
        tiles[i] = tile_empty
        continue
      }

      let r : Int = @raylib.get_random_value(0, 99)
      if r < 50 {
        tiles[i] = tile_dirt
      } else if r < 76 {
        tiles[i] = tile_rock
      } else if r < 85 {
        tiles[i] = tile_gas
      } else if r < 92 {
        tiles[i] = tile_crystal
      } else {
        tiles[i] = tile_empty
      }
    }
  }

  // base platform near top center
  let base_cx : Int = grid_w / 2
  for gy = 0; gy <= 2; gy = gy + 1 {
    for gx = base_cx - 2; gx <= base_cx + 2; gx = gx + 1 {
      if in_bounds(gx, gy) {
        set_tile(tiles, gx, gy, tile_base)
      }
    }
  }

  // ensure tunnels around base
  for gx = base_cx - 1; gx <= base_cx + 1; gx = gx + 1 {
    for gy = 2; gy <= 4; gy = gy + 1 {
      if in_bounds(gx, gy) {
        set_tile(tiles, gx, gy, tile_empty)
      }
    }
  }

  let mut miners_placed : Int = 0
  let mut tries : Int = 0
  while miners_placed < target_miners && tries < 4000 {
    tries = tries + 1
    let gx : Int = @raylib.get_random_value(2, grid_w - 3)
    let gy : Int = @raylib.get_random_value(8, grid_h - 3)
    let t : Int = get_tile(tiles, gx, gy)
    if t == tile_empty || t == tile_dirt {
      set_tile(tiles, gx, gy, tile_miner)
      miners_placed = miners_placed + 1
    }
  }

  // extra crystals deeper
  for _i = 0; _i < 34; _i = _i + 1 {
    let gx : Int = @raylib.get_random_value(2, grid_w - 3)
    let gy : Int = @raylib.get_random_value(6, grid_h - 3)
    if get_tile(tiles, gx, gy) == tile_empty {
      set_tile(tiles, gx, gy, tile_crystal)
    }
  }

  miners_placed
}

///|
fn count_tiles(tiles : Array[Int], kind : Int) -> Int {
  let mut n : Int = 0
  for i = 0; i < tiles.length(); i = i + 1 {
    if tiles[i] == kind {
      n = n + 1
    }
  }
  n
}

///|
fn base_bounds() -> (Int, Int, Int, Int) {
  let base_cx : Int = grid_w / 2
  let x : Int = world_x + (base_cx - 2) * tile_sz
  let y : Int = world_y
  let w : Int = 5 * tile_sz
  let h : Int = 3 * tile_sz
  (x, y, w, h)
}

///|
fn is_in_base(px : Float, py : Float) -> Bool {
  let (x, y, w, h) = base_bounds()
  inside_rect(px, py, x, y, w, h)
}

///|
fn gas_near_count(tiles : Array[Int], px : Float, py : Float) -> Int {
  let gx : Int = world_to_gx(px)
  let gy : Int = world_to_gy(py)

  let mut c : Int = 0
  for oy = -1; oy <= 1; oy = oy + 1 {
    for ox = -1; ox <= 1; ox = ox + 1 {
      let tx : Int = gx + ox
      let ty : Int = gy + oy
      if get_tile(tiles, tx, ty) == tile_gas {
        c = c + 1
      }
    }
  }
  c
}

///|
fn try_move_axis(
  player : Player,
  tiles : Array[Int],
  nx : Float,
  ny : Float,
  parts : Array[Particle],
) -> (Float, Float, Bool) {
  let gx : Int = world_to_gx(nx)
  let gy : Int = world_to_gy(ny)
  let t : Int = get_tile(tiles, gx, gy)

  if t == tile_dirt {
    if player.fuel > 0.15 && player.heat < player.heat_max * 0.96 {
      set_tile(tiles, gx, gy, tile_empty)
      player.fuel = player.fuel - 0.18
      player.heat = player.heat + 1.2
      burst_particles(parts, cell_center_x(gx), cell_center_y(gy), 6, 0)
      (nx, ny, true)
    } else {
      (player.x, player.y, false)
    }
  } else if t == tile_rock {
    (player.x, player.y, false)
  } else {
    (nx, ny, false)
  }
}

///|
fn drop_bomb(
  player : Player,
  tiles : Array[Int],
  parts : Array[Particle],
  casualties_ref : Int,
  crystals_ref : Int,
) -> (Int, Int) {
  if player.bombs <= 0 || player.bomb_cd > 0.0 {
    return (casualties_ref, crystals_ref)
  }

  player.bombs = player.bombs - 1
  player.bomb_cd = 0.38

  let gx : Int = world_to_gx(player.x)
  let gy : Int = world_to_gy(player.y)

  let mut casualties : Int = casualties_ref
  let mut crystals : Int = crystals_ref

  for oy = -2; oy <= 2; oy = oy + 1 {
    for ox = -2; ox <= 2; ox = ox + 1 {
      let tx : Int = gx + ox
      let ty : Int = gy + oy
      if not(in_bounds(tx, ty)) {
        continue
      }

      let d2 : Int = ox * ox + oy * oy
      if d2 > 5 {
        continue
      }

      let t : Int = get_tile(tiles, tx, ty)
      if t == tile_rock || t == tile_dirt || t == tile_gas || t == tile_crystal {
        if t == tile_crystal {
          crystals = crystals + 1
        }
        set_tile(tiles, tx, ty, tile_empty)
      } else if t == tile_miner {
        casualties = casualties + 1
        set_tile(tiles, tx, ty, tile_empty)
      }

      burst_particles(parts, cell_center_x(tx), cell_center_y(ty), 6, 4)
    }
  }

  burst_particles(parts, player.x, player.y, 22, 3)
  (casualties, crystals)
}

///|
fn nearest_miner(
  tiles : Array[Int],
  px : Float,
  py : Float,
) -> (Int, Int, Float) {
  let mut best_x : Int = -1
  let mut best_y : Int = -1
  let mut best_d2 : Float = 99999999.0

  for gy = 0; gy < grid_h; gy = gy + 1 {
    for gx = 0; gx < grid_w; gx = gx + 1 {
      if get_tile(tiles, gx, gy) != tile_miner {
        continue
      }

      let cx : Float = cell_center_x(gx)
      let cy : Float = cell_center_y(gy)
      let d2 : Float = dist2(px, py, cx, cy)
      if d2 < best_d2 {
        best_d2 = d2
        best_x = gx
        best_y = gy
      }
    }
  }

  (best_x, best_y, best_d2)
}

///|
fn apply_hazard_events(
  tiles : Array[Int],
  tier : Int,
  parts : Array[Particle],
) -> (Int, Int) {
  let mut caveins : Int = 0
  let mut gas_pockets : Int = 0

  let event_n : Int = 1 + @raylib.get_random_value(0, tier / 2)
  for _e = 0; _e < event_n; _e = _e + 1 {
    let gx : Int = @raylib.get_random_value(2, grid_w - 3)
    let gy : Int = @raylib.get_random_value(5, grid_h - 3)

    if get_tile(tiles, gx, gy) == tile_empty {
      set_tile(tiles, gx, gy, tile_rock)
      caveins = caveins + 1
      burst_particles(parts, cell_center_x(gx), cell_center_y(gy), 8, 0)
    }
  }

  let gas_n : Int = @raylib.get_random_value(1, 2 + tier / 3)
  for _g = 0; _g < gas_n; _g = _g + 1 {
    let gx : Int = @raylib.get_random_value(2, grid_w - 3)
    let gy : Int = @raylib.get_random_value(5, grid_h - 3)
    let t : Int = get_tile(tiles, gx, gy)
    if t == tile_dirt || t == tile_empty {
      set_tile(tiles, gx, gy, tile_gas)
      gas_pockets = gas_pockets + 1
      burst_particles(parts, cell_center_x(gx), cell_center_y(gy), 7, 1)
    }
  }

  (caveins, gas_pockets)
}

///|
fn draw_world_bg(t : Float) -> Unit {
  @raylib.draw_rectangle_gradient_v(
    world_x - 12,
    world_y - 12,
    world_w + 24,
    world_h + 24,
    @raylib.Color::new(24, 32, 50, 255),
    @raylib.Color::new(16, 22, 36, 255),
  )

  for i = 0; i < 28; i = i + 1 {
    let fi : Float = Float::from_int(i)
    let x : Int = (fi * 72.0 + t * (14.0 + Float::from_int(i % 5) * 4.0)).to_int() %
      world_w +
      world_x
    let y : Int = (fi * 133.0 + t * 18.0).to_int() % world_h + world_y
    @raylib.draw_circle(
      x,
      y,
      1.0 + Float::from_int(i % 3),
      @raylib.Color::new(102, 138, 198, 88),
    )
  }
}

///|
fn draw_tiles(tiles : Array[Int], t : Float) -> Unit {
  for gy = 0; gy < grid_h; gy = gy + 1 {
    for gx = 0; gx < grid_w; gx = gx + 1 {
      let tx : Int = world_x + gx * tile_sz
      let ty : Int = world_y + gy * tile_sz
      let tile : Int = get_tile(tiles, gx, gy)

      let fill = if tile == tile_empty {
        @raylib.Color::new(20, 28, 44, 246)
      } else if tile == tile_dirt {
        @raylib.Color::new(98, 76, 56, 246)
      } else if tile == tile_rock {
        @raylib.Color::new(94, 98, 118, 248)
      } else if tile == tile_gas {
        @raylib.Color::new(70, 134, 92, 220)
      } else if tile == tile_crystal {
        @raylib.Color::new(86, 168, 214, 244)
      } else if tile == tile_miner {
        @raylib.Color::new(126, 116, 180, 246)
      } else {
        @raylib.Color::new(80, 146, 208, 246)
      }
      @raylib.draw_rectangle(tx, ty, tile_sz, tile_sz, fill)

      if tile == tile_dirt {
        @raylib.draw_circle(
          tx + 8,
          ty + 8,
          3.0,
          @raylib.Color::new(136, 112, 84, 218),
        )
        @raylib.draw_circle(
          tx + 15,
          ty + 13,
          2.0,
          @raylib.Color::new(126, 102, 78, 218),
        )
      } else if tile == tile_rock {
        @raylib.draw_rectangle(
          tx + 4,
          ty + 5,
          7,
          6,
          @raylib.Color::new(124, 128, 148, 222),
        )
        @raylib.draw_rectangle(
          tx + 13,
          ty + 11,
          6,
          5,
          @raylib.Color::new(124, 128, 148, 222),
        )
      } else if tile == tile_gas {
        for i = 0; i < 3; i = i + 1 {
          let fx : Int = tx + 6 + i * 6
          let fy : Int = ty +
            8 +
            (@math.sinf(t * 4.0 + Float::from_int(gx + gy + i)) * 3.0).to_int()
          @raylib.draw_circle(
            fx,
            fy,
            4.0,
            @raylib.Color::new(124, 206, 142, 144),
          )
        }
      } else if tile == tile_crystal {
        @raylib.draw_triangle(
          @raylib.Vector2::new(
            Float::from_int(tx + tile_sz / 2),
            Float::from_int(ty + 4),
          ),
          @raylib.Vector2::new(
            Float::from_int(tx + 5),
            Float::from_int(ty + tile_sz - 4),
          ),
          @raylib.Vector2::new(
            Float::from_int(tx + tile_sz - 5),
            Float::from_int(ty + tile_sz - 4),
          ),
          @raylib.Color::new(154, 226, 255, 248),
        )
      } else if tile == tile_miner {
        @raylib.draw_circle(
          tx + tile_sz / 2,
          ty + tile_sz / 2,
          7.0,
          @raylib.Color::new(246, 236, 154, 248),
        )
        @raylib.draw_rectangle(
          tx + tile_sz / 2 - 4,
          ty + tile_sz / 2 + 5,
          8,
          7,
          @raylib.Color::new(238, 198, 126, 246),
        )
      } else if tile == tile_base {
        @raylib.draw_rectangle(
          tx + 4,
          ty + 4,
          tile_sz - 8,
          tile_sz - 8,
          @raylib.Color::new(132, 220, 252, 220),
        )
      }

      @raylib.draw_rectangle_lines(
        tx,
        ty,
        tile_sz,
        tile_sz,
        @raylib.Color::new(26, 34, 48, 150),
      )
    }
  }
}

///|
fn draw_player(player : Player, t : Float) -> Unit {
  let bob : Float = @math.sinf(t * 8.0 + player.wobble) * 2.0
  let x : Float = player.x
  let y : Float = player.y + bob

  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    14.0,
    @raylib.Color::new(248, 204, 102, 250),
  )
  @raylib.draw_circle(
    x.to_int(),
    y.to_int(),
    9.0,
    @raylib.Color::new(64, 82, 122, 252),
  )

  let drill_len : Float = 18.0 + @math.sinf(t * 20.0) * 2.0
  @raylib.draw_line_ex(
    @raylib.Vector2::new(x, y),
    @raylib.Vector2::new(x + drill_len, y),
    4.0,
    @raylib.Color::new(218, 228, 244, 248),
  )

  if player.carried > 0 {
    @raylib.draw_text(
      "\{player.carried}",
      (x + 14.0).to_int(),
      (y - 9.0).to_int(),
      20,
      @raylib.Color::new(248, 246, 236, 252),
    )
  }
}

///|
fn draw_touch_ui() -> Unit {
  let pad_x : Int = 28
  let pad_y : Int = sh - 196

  @raylib.draw_rectangle(
    pad_x + 86,
    pad_y,
    78,
    58,
    @raylib.Color::new(84, 108, 160, 164),
  )
  @raylib.draw_rectangle(
    pad_x,
    pad_y + 68,
    78,
    58,
    @raylib.Color::new(84, 108, 160, 164),
  )
  @raylib.draw_rectangle(
    pad_x + 86,
    pad_y + 68,
    78,
    58,
    @raylib.Color::new(84, 108, 160, 164),
  )
  @raylib.draw_rectangle(
    pad_x + 172,
    pad_y + 68,
    78,
    58,
    @raylib.Color::new(84, 108, 160, 164),
  )
  @raylib.draw_rectangle(
    pad_x + 86,
    pad_y + 136,
    78,
    58,
    @raylib.Color::new(84, 108, 160, 164),
  )

  @raylib.draw_text(
    "UP",
    pad_x + 110,
    pad_y + 16,
    24,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "LT",
    pad_x + 26,
    pad_y + 84,
    24,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "RT",
    pad_x + 191,
    pad_y + 84,
    24,
    @raylib.Color::new(236, 244, 255, 244),
  )
  @raylib.draw_text(
    "DN",
    pad_x + 106,
    pad_y + 152,
    24,
    @raylib.Color::new(236, 244, 255, 244),
  )

  let bomb_x : Int = sw - 290
  let bomb_y : Int = sh - 176
  @raylib.draw_circle(
    bomb_x,
    bomb_y,
    62.0,
    @raylib.Color::new(242, 132, 108, 172),
  )
  @raylib.draw_text(
    "BOMB",
    bomb_x - 40,
    bomb_y - 14,
    30,
    @raylib.Color::new(252, 246, 246, 248),
  )

  let sonar_x : Int = sw - 154
  let sonar_y : Int = sh - 248
  @raylib.draw_circle(
    sonar_x,
    sonar_y,
    54.0,
    @raylib.Color::new(122, 206, 136, 174),
  )
  @raylib.draw_text(
    "SON",
    sonar_x - 24,
    sonar_y - 14,
    30,
    @raylib.Color::new(246, 252, 246, 248),
  )
}

///|
fn draw_ui(
  player : Player,
  timer : Float,
  rescued : Int,
  target : Int,
  casualties : Int,
  crystals : Int,
  tier : Int,
  miners_left : Int,
  score : Int,
  impossible : Bool,
) -> Unit {
  @raylib.draw_rectangle(
    panel_x,
    20,
    panel_w,
    728,
    @raylib.Color::new(16, 22, 34, 246),
  )
  @raylib.draw_rectangle_lines(
    panel_x,
    20,
    panel_w,
    728,
    @raylib.Color::new(164, 188, 234, 242),
  )

  @raylib.draw_text(
    "DEEP TUNNEL DRILL RESCUE",
    panel_x + 14,
    42,
    34,
    @raylib.Color::new(236, 246, 255, 252),
  )
  @raylib.draw_text(
    "Dig, rescue, return to base",
    panel_x + 16,
    80,
    22,
    @raylib.Color::new(192, 216, 252, 238),
  )

  @raylib.draw_text(
    "Timer",
    panel_x + 16,
    126,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{timer.to_int()}s",
    panel_x + 130,
    126,
    30,
    @raylib.Color::new(248, 228, 150, 252),
  )

  @raylib.draw_text(
    "Rescued",
    panel_x + 16,
    162,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{rescued}/\{target}",
    panel_x + 130,
    162,
    30,
    @raylib.Color::new(136, 226, 162, 252),
  )

  @raylib.draw_text(
    "Miners left",
    panel_x + 16,
    198,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{miners_left}",
    panel_x + 170,
    198,
    30,
    @raylib.Color::new(228, 238, 252, 252),
  )

  @raylib.draw_text(
    "Casualties",
    panel_x + 16,
    234,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{casualties}",
    panel_x + 150,
    234,
    30,
    @raylib.Color::new(244, 132, 150, 252),
  )

  @raylib.draw_text(
    "Tier",
    panel_x + 16,
    270,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{tier}",
    panel_x + 80,
    270,
    30,
    @raylib.Color::new(248, 216, 126, 252),
  )

  @raylib.draw_text(
    "Crystals",
    panel_x + 156,
    270,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{crystals}",
    panel_x + 262,
    270,
    30,
    @raylib.Color::new(132, 214, 252, 252),
  )

  @raylib.draw_text(
    "Score",
    panel_x + 16,
    306,
    24,
    @raylib.Color::new(220, 236, 252, 246),
  )
  @raylib.draw_text(
    "\{score}",
    panel_x + 94,
    306,
    30,
    @raylib.Color::new(236, 230, 162, 252),
  )

  fn draw_bar(
    y : Int,
    label : String,
    value : Float,
    maxv : Float,
    col : @raylib.Color,
  ) -> Unit {
    @raylib.draw_text(
      label,
      panel_x + 16,
      y,
      24,
      @raylib.Color::new(220, 236, 252, 246),
    )
    @raylib.draw_rectangle(
      panel_x + 16,
      y + 30,
      panel_w - 32,
      22,
      @raylib.Color::new(24, 32, 46, 255),
    )
    let p01 : Float = clampf(value / maxv, 0.0, 1.0)
    let fw : Int = (Float::from_int(panel_w - 32) * p01).to_int()
    @raylib.draw_rectangle(panel_x + 16, y + 30, fw, 22, col)
    @raylib.draw_rectangle_lines(
      panel_x + 16,
      y + 30,
      panel_w - 32,
      22,
      @raylib.Color::new(182, 206, 246, 248),
    )
    @raylib.draw_text(
      "\{value.to_int()}/\{maxv.to_int()}",
      panel_x + panel_w - 130,
      y + 56,
      20,
      @raylib.Color::new(228, 242, 255, 244),
    )
  }

  draw_bar(
    352,
    "Fuel",
    player.fuel,
    player.fuel_max,
    @raylib.Color::new(246, 210, 130, 252),
  )
  draw_bar(
    430,
    "Oxygen",
    player.oxygen,
    player.oxygen_max,
    @raylib.Color::new(138, 214, 252, 252),
  )
  draw_bar(
    508,
    "Hull",
    player.hull,
    player.hull_max,
    @raylib.Color::new(132, 236, 162, 252),
  )
  draw_bar(
    586,
    "Heat",
    player.heat,
    player.heat_max,
    @raylib.Color::new(244, 136, 146, 252),
  )

  @raylib.draw_text(
    "Bombs \{player.bombs}",
    panel_x + 16,
    666,
    28,
    @raylib.Color::new(242, 226, 150, 248),
  )
  @raylib.draw_text(
    "Carried \{player.carried}/\{player.carry_max}",
    panel_x + 170,
    666,
    26,
    @raylib.Color::new(218, 236, 252, 246),
  )

  if impossible {
    @raylib.draw_text(
      "Target impossible: too many losses",
      panel_x + 16,
      702,
      22,
      @raylib.Color::new(252, 176, 188, 248),
    )
  } else {
    @raylib.draw_text(
      "Base converts 3 crystals -> +1 bomb",
      panel_x + 16,
      702,
      22,
      @raylib.Color::new(194, 220, 252, 238),
    )
  }
}

///|
fn main {
  @raylib.init_window(sw, sh, "raylib [game] deep tunnel drill rescue 2026")
  @raylib.set_target_fps(60)

  let tiles : Array[Int] = Array::make(grid_w * grid_h, tile_empty)

  let parts : Array[Particle] = Array::makei(max_particles, fn(_i) {
    {
      active: false,
      kind: 0,
      x: 0.0,
      y: 0.0,
      vx: 0.0,
      vy: 0.0,
      size: 0.0,
      life: 0.0,
      pulse: 0.0,
    }
  })

  let player : Player = {
    x: cell_center_x(grid_w / 2),
    y: cell_center_y(1),
    vx: 0.0,
    vy: 0.0,
    fuel: 100.0,
    fuel_max: 100.0,
    oxygen: 100.0,
    oxygen_max: 100.0,
    hull: 100.0,
    hull_max: 100.0,
    heat: 0.0,
    heat_max: 100.0,
    bombs: 4,
    bomb_cd: 0.0,
    rescue_cd: 0.0,
    sonar_cd: 0.0,
    sonar_t: 0.0,
    sonar_tx: 0.0,
    sonar_ty: 0.0,
    carried: 0,
    carry_max: 4,
    wobble: randf(0.0, 20.0),
  }

  let target_miners : Int = 16

  let mut state : Int = 0 // 0 menu 1 play 2 win 3 lose
  let mut timer : Float = 360.0
  let mut rescued_total : Int = 0
  let mut casualties_total : Int = 0
  let mut crystals_total : Int = 0
  let mut tier : Int = 1
  let mut score : Int = 0

  let mut msg : String = ""
  let mut msg_t : Float = 0.0
  let mut scene_t : Float = 0.0

  let mut event_cd : Float = 9.0

  fn reset_run() -> Unit {
    let miners_placed : Int = setup_map(tiles, target_miners)
    ignore(miners_placed)

    clear_particles(parts)

    player.x = cell_center_x(grid_w / 2)
    player.y = cell_center_y(1)
    player.vx = 0.0
    player.vy = 0.0
    player.fuel = 100.0
    player.oxygen = 100.0
    player.hull = 100.0
    player.heat = 0.0
    player.bombs = 4
    player.bomb_cd = 0.0
    player.rescue_cd = 0.0
    player.sonar_cd = 0.0
    player.sonar_t = 0.0
    player.sonar_tx = player.x
    player.sonar_ty = player.y
    player.carried = 0

    timer = 360.0
    rescued_total = 0
    casualties_total = 0
    crystals_total = 0
    tier = 1
    score = 0

    event_cd = 9.0

    msg = "Rescue drill initialized"
    msg_t = 2.0
  }

  reset_run()

  while not(@raylib.window_should_close()) {
    let mut dt : Float = @raylib.get_frame_time()
    if dt > 0.033 {
      dt = 0.033
    }

    if @raylib.is_key_pressed(@raylib.KeyF11) {
      @raylib.toggle_fullscreen()
    }

    let mouse = @raylib.get_mouse_position()
    let click : Bool = @raylib.is_mouse_button_pressed(@raylib.MouseButtonLeft)
    let hold : Bool = @raylib.is_mouse_button_down(@raylib.MouseButtonLeft)

    scene_t = scene_t + dt
    while scene_t > 100000.0 {
      scene_t = scene_t - 100000.0
    }

    if msg_t > 0.0 {
      msg_t = msg_t - dt
      if msg_t < 0.0 {
        msg_t = 0.0
      }
    }

    update_particles(parts, dt)

    if state == 0 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        reset_run()
        state = 1
      }
    } else if state == 1 {
      timer = timer - dt
      if timer < 0.0 {
        timer = 0.0
      }

      tier = 1 + rescued_total / 5
      if tier > 10 {
        tier = 10
      }

      if player.bomb_cd > 0.0 {
        player.bomb_cd = player.bomb_cd - dt
        if player.bomb_cd < 0.0 {
          player.bomb_cd = 0.0
        }
      }

      if player.rescue_cd > 0.0 {
        player.rescue_cd = player.rescue_cd - dt
        if player.rescue_cd < 0.0 {
          player.rescue_cd = 0.0
        }
      }

      if player.sonar_cd > 0.0 {
        player.sonar_cd = player.sonar_cd - dt
        if player.sonar_cd < 0.0 {
          player.sonar_cd = 0.0
        }
      }

      if player.sonar_t > 0.0 {
        player.sonar_t = player.sonar_t - dt
        if player.sonar_t < 0.0 {
          player.sonar_t = 0.0
        }
      }

      // input
      let mut move_l : Bool = @raylib.is_key_down(@raylib.KeyA) ||
        @raylib.is_key_down(@raylib.KeyLeft)
      let mut move_r : Bool = @raylib.is_key_down(@raylib.KeyD) ||
        @raylib.is_key_down(@raylib.KeyRight)
      let mut move_u : Bool = @raylib.is_key_down(@raylib.KeyW) ||
        @raylib.is_key_down(@raylib.KeyUp)
      let mut move_d : Bool = @raylib.is_key_down(@raylib.KeyS) ||
        @raylib.is_key_down(@raylib.KeyDown)

      let mut bomb_action : Bool = @raylib.is_key_pressed(@raylib.KeyJ) ||
        @raylib.is_key_pressed(@raylib.KeySpace)
      let mut sonar_action : Bool = @raylib.is_key_pressed(@raylib.KeyK) ||
        @raylib.is_key_pressed(@raylib.KeyH)
      let mut rescue_action : Bool = @raylib.is_key_pressed(@raylib.KeyL)

      if hold {
        let pad_x : Int = 28
        let pad_y : Int = sh - 196

        if inside_rect(mouse.x, mouse.y, pad_x + 86, pad_y, 78, 58) {
          move_u = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x, pad_y + 68, 78, 58) {
          move_l = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 172, pad_y + 68, 78, 58) {
          move_r = true
        }
        if inside_rect(mouse.x, mouse.y, pad_x + 86, pad_y + 136, 78, 58) {
          move_d = true
        }

        let bomb_x : Float = Float::from_int(sw - 290)
        let bomb_y : Float = Float::from_int(sh - 176)
        if dist2(mouse.x, mouse.y, bomb_x, bomb_y) <= 62.0 * 62.0 {
          bomb_action = true
        }
      }

      if click {
        let sonar_x : Float = Float::from_int(sw - 154)
        let sonar_y : Float = Float::from_int(sh - 248)
        if dist2(mouse.x, mouse.y, sonar_x, sonar_y) <= 54.0 * 54.0 {
          sonar_action = true
        }
      }

      if @raylib.is_key_pressed(@raylib.KeyR) {
        rescue_action = true
      }

      // movement
      let acc : Float = 380.0
      if move_l {
        player.vx = player.vx - acc * dt
      }
      if move_r {
        player.vx = player.vx + acc * dt
      }
      if move_u {
        player.vy = player.vy - acc * dt
      }
      if move_d {
        player.vy = player.vy + acc * dt
      }

      let drag : Float = 5.4
      player.vx = player.vx * (1.0 - dt * drag)
      player.vy = player.vy * (1.0 - dt * drag)

      let sp2 : Float = player.vx * player.vx + player.vy * player.vy
      let speed_max : Float = 210.0
      if sp2 > speed_max * speed_max {
        let inv : Float = speed_max / sp2.sqrt()
        player.vx = player.vx * inv
        player.vy = player.vy * inv
      }

      let mut nx : Float = player.x + player.vx * dt
      let mut ny : Float = player.y
      nx = clampf(nx, world_l + 8.0, world_r - 8.0)
      let (rx, _ry, dug_x) = try_move_axis(player, tiles, nx, ny, parts)
      player.x = rx
      if not(dug_x) && (move_l || move_r) {
        player.fuel = player.fuel - dt * 0.08
      }

      nx = player.x
      ny = player.y + player.vy * dt
      ny = clampf(ny, world_t + 8.0, world_b - 8.0)
      let (_rx2, ry2, dug_y) = try_move_axis(player, tiles, nx, ny, parts)
      player.y = ry2
      if not(dug_y) && (move_u || move_d) {
        player.fuel = player.fuel - dt * 0.08
      }

      if dug_x || dug_y {
        player.fuel = player.fuel - dt * 0.06
      }

      if player.fuel < 0.0 {
        player.fuel = 0.0
      }

      // environment
      let gas_n : Int = gas_near_count(tiles, player.x, player.y)
      let oxy_loss : Float = dt *
        (0.92 + Float::from_int(tier) * 0.08 + Float::from_int(gas_n) * 0.20)
      player.oxygen = player.oxygen - oxy_loss
      if player.oxygen < 0.0 {
        player.oxygen = 0.0
      }

      if gas_n > 0 {
        player.hull = player.hull - dt * Float::from_int(gas_n) * 0.45
      }

      player.heat = player.heat - dt * 6.2
      if player.heat < 0.0 {
        player.heat = 0.0
      }

      if player.heat > player.heat_max {
        player.hull = player.hull - dt * 5.0
      }

      if player.hull < 0.0 {
        player.hull = 0.0
      }

      // collect crystals by contact
      let cgx : Int = world_to_gx(player.x)
      let cgy : Int = world_to_gy(player.y)
      let tile_here : Int = get_tile(tiles, cgx, cgy)
      if tile_here == tile_crystal {
        set_tile(tiles, cgx, cgy, tile_empty)
        crystals_total = crystals_total + 1
        score = score + 24
        burst_particles(parts, player.x, player.y, 8, 1)
      }

      // rescue miners by action near tile
      if player.rescue_cd <= 0.0 &&
        (
          rescue_action ||
          (tile_here == tile_miner && player.carried < player.carry_max)
        ) {
        let mut rescued_now : Int = 0
        for oy = -1; oy <= 1; oy = oy + 1 {
          for ox = -1; ox <= 1; ox = ox + 1 {
            let gx : Int = cgx + ox
            let gy : Int = cgy + oy
            if get_tile(tiles, gx, gy) == tile_miner {
              if player.carried < player.carry_max {
                set_tile(tiles, gx, gy, tile_empty)
                player.carried = player.carried + 1
                rescued_now = rescued_now + 1
                burst_particles(
                  parts,
                  cell_center_x(gx),
                  cell_center_y(gy),
                  6,
                  2,
                )
              }
            }
          }
        }

        if rescued_now > 0 {
          score = score + rescued_now * 32
          msg = "Picked up \{rescued_now} miner(s)"
          msg_t = 1.0
          player.rescue_cd = 0.35
        }
      }

      // base behaviors
      if is_in_base(player.x, player.y) {
        player.fuel = minf(player.fuel + dt * 34.0, player.fuel_max)
        player.oxygen = minf(player.oxygen + dt * 46.0, player.oxygen_max)
        player.hull = minf(player.hull + dt * 12.0, player.hull_max)
        player.heat = maxf(0.0, player.heat - dt * 18.0)

        if player.carried > 0 {
          rescued_total = rescued_total + player.carried
          score = score + player.carried * 58
          msg = "Delivered \{player.carried} rescued"
          msg_t = 1.2
          burst_particles(parts, player.x, player.y, 14, 2)
          player.carried = 0
        }

        while crystals_total >= 3 && player.bombs < 6 {
          crystals_total = crystals_total - 3
          player.bombs = player.bombs + 1
          msg = "Converted crystals into bomb"
          msg_t = 0.9
        }
      }

      // bomb action
      if bomb_action {
        let (new_cas, new_crystals) = drop_bomb(
          player, tiles, parts, casualties_total, crystals_total,
        )
        if new_cas > casualties_total {
          msg = "Bomb caused casualties"
          msg_t = 1.0
          score = score - (new_cas - casualties_total) * 40
        }
        casualties_total = new_cas
        crystals_total = new_crystals
      }

      // sonar action
      if sonar_action && player.sonar_cd <= 0.0 {
        let (mx, my, d2) = nearest_miner(tiles, player.x, player.y)
        if mx >= 0 {
          player.sonar_tx = cell_center_x(mx)
          player.sonar_ty = cell_center_y(my)
          player.sonar_t = 2.0
          player.sonar_cd = 2.2

          let d : Int = d2.sqrt().to_int()
          msg = "Sonar ping: nearest miner \{d}m"
          msg_t = 1.1
          burst_particles(parts, player.x, player.y, 10, 3)
        } else {
          msg = "No miners detected"
          msg_t = 0.9
          player.sonar_cd = 1.2
        }
      }

      // periodic hazard events
      event_cd = event_cd - dt
      if event_cd <= 0.0 {
        event_cd = randf(5.2, 9.2) - Float::from_int(tier) * 0.1
        if event_cd < 2.0 {
          event_cd = 2.0
        }

        let (caveins, gas_added) = apply_hazard_events(tiles, tier, parts)
        if caveins + gas_added > 0 {
          msg = "Hazard: +\{caveins} cave-in, +\{gas_added} gas"
          msg_t = 1.2
        }
      }

      let miners_left : Int = count_tiles(tiles, tile_miner)
      let impossible : Bool = rescued_total + player.carried + miners_left <
        target_miners

      if rescued_total >= target_miners {
        state = 2
        msg = "All rescue targets secured"
        msg_t = 3.0
        burst_particles(parts, player.x, player.y, 60, 2)
      } else if timer <= 0.0 {
        state = 3
        msg = "Shift ended"
        msg_t = 3.0
      } else if player.oxygen <= 0.0 {
        state = 3
        msg = "Oxygen depleted"
        msg_t = 3.0
      } else if player.hull <= 0.0 {
        state = 3
        msg = "Drill destroyed"
        msg_t = 3.0
      } else if impossible {
        state = 3
        msg = "Mission target no longer reachable"
        msg_t = 3.0
      }
    } else if state == 2 {
      if click || @raylib.is_key_pressed(@raylib.KeyEnter) {
        state = 0
      }
    } else if click ||
      @raylib.is_key_pressed(@raylib.KeyEnter) ||
      @raylib.is_key_pressed(@raylib.KeyR) {
      state = 0
    }

    @raylib.begin_drawing()
    @raylib.clear_background(@raylib.Color::new(8, 12, 22, 255))

    draw_world_bg(scene_t)
    draw_tiles(tiles, scene_t)

    // base marker and support areas
    let (base_x, base_y, base_w, base_h) = base_bounds()
    @raylib.draw_rectangle(
      base_x,
      base_y,
      base_w,
      base_h,
      @raylib.Color::new(70, 136, 208, 120),
    )
    @raylib.draw_rectangle_lines(
      base_x,
      base_y,
      base_w,
      base_h,
      @raylib.Color::new(196, 224, 252, 236),
    )
    @raylib.draw_text(
      "BASE",
      base_x + 28,
      base_y + 22,
      28,
      @raylib.Color::new(236, 246, 255, 248),
    )

    draw_player(player, scene_t)

    if player.sonar_t > 0.0 {
      let alpha : Int = clampi((player.sonar_t * 130.0).to_int(), 0, 220)
      @raylib.draw_line_ex(
        @raylib.Vector2::new(player.x, player.y),
        @raylib.Vector2::new(player.sonar_tx, player.sonar_ty),
        4.0,
        @raylib.Color::new(132, 246, 154, alpha),
      )
      @raylib.draw_circle(
        player.sonar_tx.to_int(),
        player.sonar_ty.to_int(),
        10.0,
        @raylib.Color::new(132, 246, 154, alpha),
      )
    }

    draw_particles(parts)

    let miners_left_ui : Int = count_tiles(tiles, tile_miner)
    let impossible_ui : Bool = rescued_total + player.carried + miners_left_ui <
      target_miners
    draw_ui(
      player, timer, rescued_total, target_miners, casualties_total, crystals_total,
      tier, miners_left_ui, score, impossible_ui,
    )

    draw_touch_ui()

    @raylib.draw_text(
      "Tap tiles by moving through dirt. Base refills + unloads.",
      world_x + 6,
      30,
      28,
      @raylib.Color::new(214, 232, 252, 242),
    )

    if msg_t > 0.0 {
      let bw : Int = @raylib.measure_text(msg, 30) + 44
      let bx : Int = sw / 2 - bw / 2
      @raylib.draw_rectangle(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(12, 18, 30, 224),
      )
      @raylib.draw_rectangle_lines(
        bx,
        16,
        bw,
        52,
        @raylib.Color::new(186, 210, 248, 246),
      )
      @raylib.draw_text(
        msg,
        bx + 22,
        28,
        30,
        @raylib.Color::new(236, 244, 255, 252),
      )
    }

    if state == 0 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(10, 14, 24, 206))
      @raylib.draw_text(
        "DEEP TUNNEL DRILL RESCUE",
        sw / 2 - 410,
        150,
        76,
        @raylib.Color::new(236, 246, 255, 255),
      )
      @raylib.draw_text(
        "Underground rescue + drilling roguelite",
        sw / 2 - 268,
        242,
        38,
        @raylib.Color::new(194, 220, 252, 252),
      )

      @raylib.draw_rectangle(
        sw / 2 - 470,
        314,
        940,
        246,
        @raylib.Color::new(18, 26, 42, 236),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 470,
        314,
        940,
        246,
        @raylib.Color::new(166, 196, 246, 246),
      )

      @raylib.draw_text(
        "Desktop",
        sw / 2 - 436,
        346,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- WASD/Arrows move and drill dirt",
        sw / 2 - 436,
        386,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- J/Space bomb, K/H sonar, R rescue",
        sw / 2 - 436,
        420,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Return to base to refill and unload",
        sw / 2 - 436,
        454,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_text(
        "Mobile",
        sw / 2 + 74,
        346,
        32,
        @raylib.Color::new(242, 246, 255, 252),
      )
      @raylib.draw_text(
        "- Hold D-pad to move",
        sw / 2 + 74,
        386,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Tap BOMB / SON buttons",
        sw / 2 + 74,
        420,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )
      @raylib.draw_text(
        "- Fully touch playable",
        sw / 2 + 74,
        454,
        28,
        @raylib.Color::new(210, 228, 252, 248),
      )

      @raylib.draw_rectangle(
        sw / 2 - 204,
        604,
        408,
        92,
        @raylib.Color::new(96, 138, 216, 246),
      )
      @raylib.draw_rectangle_lines(
        sw / 2 - 204,
        604,
        408,
        92,
        @raylib.Color::new(230, 240, 255, 252),
      )
      @raylib.draw_text(
        "START DRILL SHIFT",
        sw / 2 - 158,
        638,
        42,
        @raylib.Color::new(246, 248, 255, 252),
      )
    } else if state == 2 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(8, 20, 10, 194))
      @raylib.draw_text(
        "MISSION SUCCESS",
        sw / 2 - 298,
        186,
        86,
        @raylib.Color::new(164, 246, 182, 252),
      )
      @raylib.draw_text(
        "Rescued \{rescued_total}/\{target_miners}",
        sw / 2 - 176,
        324,
        42,
        @raylib.Color::new(232, 248, 236, 252),
      )
      @raylib.draw_text(
        "Score \{score}",
        sw / 2 - 84,
        376,
        38,
        @raylib.Color::new(244, 232, 160, 248),
      )
      @raylib.draw_text(
        "Tap or Enter",
        sw / 2 - 94,
        456,
        34,
        @raylib.Color::new(216, 234, 252, 246),
      )
    } else if state == 3 {
      @raylib.draw_rectangle(0, 0, sw, sh, @raylib.Color::new(24, 8, 14, 206))
      @raylib.draw_text(
        "MISSION FAILED",
        sw / 2 - 266,
        194,
        86,
        @raylib.Color::new(252, 164, 178, 252),
      )
      @raylib.draw_text(
        "Rescued \{rescued_total}/\{target_miners}",
        sw / 2 - 176,
        326,
        42,
        @raylib.Color::new(242, 232, 236, 252),
      )
      @raylib.draw_text(
        "Casualties \{casualties_total}  Score \{score}",
        sw / 2 - 236,
        378,
        36,
        @raylib.Color::new(244, 216, 154, 248),
      )
      @raylib.draw_text(
        "Tap or Enter to retry",
        sw / 2 - 164,
        456,
        34,
        @raylib.Color::new(218, 234, 252, 246),
      )
    }

    @raylib.end_drawing()
  }

  @raylib.close_window()
}
